#!/bin/bash
set -e

# Base iso image
ISO_MIRROR="http://mirrors.kernel.org/centos/7/isos/x86_64"
ISO_FILE="CentOS-7-x86_64-Minimal-1503-01.iso"

# Directories
BASE_DIR="$(dirname "$(readlink -f "${0}")")"
STAGE_DIR="${BASE_DIR}/stage"
CACHE_DIR="${BASE_DIR}/cache"
ARTIFACT_DIR="${BASE_DIR}/artifacts"
PKG_CACHE_DIR="${CACHE_DIR}/packages"
ISO_CACHE_DIR="${CACHE_DIR}/isos"
ISO_STAGE_DIR="${STAGE_DIR}/${BUILD}/${SPEC}/isos"
PKG_STAGE_DIR="${STAGE_DIR}/${BUILD}/${SPEC}/packages"
TMP_STAGE_DIR="${STAGE_DIR}/${BUILD}/${SPEC}/tmp"
IMAGE_STAGE_DIR="${STAGE_DIR}/${BUILD}/${SPEC}/images"

usage() {
    echo "usage: ${0##*/} [ -b buildnumber ] [ -s specfile ]"
    exit 0
}

log() {
    tput setaf 4
    echo "$(date +%Y-%m-%d) $(date +%H:%M:%S) - ${1}"
    tput sgr0
}

prep() {
    # Set default specs if undefined
    [[ -z "${SPECS[@]}" ]] && SPECS=(controller resource vagrant)

    # Auto-generate build version number if undefined
    [[ -z "${BUILD}" ]] && BUILD="$(date +1.%Y%m%d.%H%M)"

    # Insure dependencies installed
    # Format is 'DEPS[command]=providing-package'
    declare -A DEPS
    DEPS[docker]=docker
    DEPS[createrepo]=createrepo
    DEPS[genisoimage]=genisoimage
    DEPS[yumdownloader]=yum-utils

    log "Checking for missing script dependencies"
    for DEP in "${!DEPS[@]}"
    do
        command -v "${DEP}" > 2&>1 /dev/null || MISSING_DEPS+=("${DEPS[$DEP]}")
    done

    if [[ ! -z "${MISSING_DEPS[@]}" ]]
    then
        log "Installing missing script dependencies"
        sudo yum install -y "${MISSING_DEPS[@]}"
    fi

    # Insure spec files exist
    for SPEC in "${SPECS[@]}"
    do
        log "Checking for ${BASE_DIR}/specs/${SPEC}"
        if [[ ! -s "${BASE_DIR}/specs/${SPEC}" ]]
        then
            log "Error: ${BASE_DIR}/specs/${SPEC} not found."
            exit 1
        fi
    done

    # Insure /mnt free
    sudo umount /mnt > /dev/null 2>&1 || true
}

clean() {
    # Delete stage directory
    log "Deleting ${STAGE_DIR}"
    sudo rm -rf "${STAGE_DIR}"
}

fetch_iso() {
    log "Creating ${ISO_CACHE_DIR}"
    mkdir -p "${ISO_CACHE_DIR}"

    # Fetch sha256sum.txt
    until [[ -f "${ISO_CACHE_DIR}/sha256sum.txt" ]]
    do
        log "Downloading ${ISO_MIRROR}/sha256sum.txt"
        curl -o "${ISO_CACHE_DIR}/sha256sum.txt" "${ISO_MIRROR}/sha256sum.txt"
    done

    # Fetch iso if sha256 does not match sha256sum.txt
    local SHA256="$(awk '$2 == "'"${ISO_FILE}"'" { print $1 }' "${ISO_CACHE_DIR}/sha256sum.txt")"
    until [[ "$(sha256sum "${ISO_CACHE_DIR}/${ISO_FILE}" 2>/dev/null | cut -f1 -d' ')" == "${SHA256}" ]]
    do
        log "Downloading ${ISO_MIRROR}/${ISO_FILE} to cache"
        curl -o "${ISO_CACHE_DIR}/${ISO_FILE}" "${ISO_MIRROR}/${ISO_FILE}"
    done
}

fetch_specs() {
    # Load spec files
    for SPEC in "${SPECS[@]}"
    do
        log "Loading spec ${BASE_DIR}/specs/${SPEC}"
        source "${BASE_DIR}/specs/${SPEC}"
    done
    local PKGS=("$(printf "%s\n" "${PKGS[@]}" | sort -u)")
    local IMAGES=("$(printf "%s\n" "${IMAGES[@]}" | sort -u)")

    # Download Docker images
    log "Creating ${IMAGE_STAGE_DIR}"
    mkdir -p "${IMAGE_STAGE_DIR}"
    for IMAGE in ${IMAGES[@]}
    do
        log "Pulling docker image ${IMAGE}"
        docker pull "${IMAGE}"
        NAME="$(awk -F/ '{ print $2 }' <<<"${IMAGE}")"
        log "Saving docker image ${IMAGE} to "${IMAGE_STAGE_DIR}/${NAME}.tar""
        docker save -o "${IMAGE_STAGE_DIR}/${NAME}.tar" "${IMAGE}"
        [[ -f "${IMAGE_STAGE_DIR}/${NAME}.tar" ]] || exit 1 
    done

    # Configuring chroot yum repos
    log "Creating ${TMP_STAGE_DIR} directories"
    mkdir -p "${TMP_STAGE_DIR}"{/etc/yum.repos.d,/var/cache/yum}

    log "Configuring yum repos"
    ( IFS=$'\n'; echo "${REPOS[*]}" > "${TMP_STAGE_DIR}/etc/yum.repos.d/yum.repo" )

    # Download packages to repo cache directory
    log "Creating ${PKG_CACHE_DIR}"
    mkdir -p "${PKG_CACHE_DIR}"

    log "Downloading packages to cache"
    yumdownloader ${PKGS[@]} \
        --resolve \
        --config="${BASE_DIR}/files/yum.conf" \
        --installroot="${TMP_STAGE_DIR}" \
        --destdir="${PKG_CACHE_DIR}"

    log "Creating/updating yum repodata for ${PKG_CACHE_DIR}"
    createrepo "${PKG_CACHE_DIR}"
} 

build_specs() {
    for SPEC in "${SPECS[@]}"
    do
        log "Building spec ${SPEC}-${BUILD}" 
        build_iso
        log "Successfully built spec ${SPEC}-${BUILD}"
    done
}

build_iso() {
    # Load spec file
    log "Loading ${BASE_DIR}/specs/${SPEC}"
    unset PKGS && unset REPOS && unset IMAGES
    source "${BASE_DIR}/specs/${SPEC}"
    local PKGS=("$(printf "%s\n" "${PKGS[@]}" | sort -u)")
    local IMAGES=("$(printf "%s\n" "${IMAGES[@]}" | sort -u)")

    # Move packages to stage directory
    log "Configuring local yum repo"
    echo -e "[local]\nname=local\nbaseurl=file://${PKG_CACHE_DIR}" > \
        "${TMP_STAGE_DIR}/etc/yum.repos.d/yum.repo"

    log "Creating ${PKG_STAGE_DIR}"
    mkdir -p "${PKG_STAGE_DIR}"

    log "Moving packages to stage directory"
    yumdownloader ${PKGS[@]} \
        --resolve \
        --config="${BASE_DIR}/files/yum.conf" \
        --installroot="${TMP_STAGE_DIR}" \
        --destdir="${PKG_STAGE_DIR}"

    # Mount base iso
    log "Mounting ${ISO_CACHE_DIR}/${ISO_FILE} to /mnt"
    sudo mount -o loop "${ISO_CACHE_DIR}/${ISO_FILE}" /mnt > /dev/null 2>&1

    # Rsync all base iso contents other than packages and repodata to iso stage directory
    log "Rsyncing base iso contents to iso stage directory"
    rsync -av /mnt/ "${ISO_STAGE_DIR}" --exclude=Packages --exclude=repodata --exclude=.repodata

    # Rsync docker images to iso stage directory
    log "Creating ${ISO_STAGE_DIR}/software/images"
    mkdir -p "${ISO_STAGE_DIR}/software/images"

    log "Rsyncing docker images to iso stage directory"
    rsync -av "${IMAGE_STAGE_DIR}/" "${ISO_STAGE_DIR}/software/images"

    # Rsync packages to iso stage directory
    log "Creating ${ISO_STAGE_DIR}/software/packages"
    mkdir -p "${ISO_STAGE_DIR}/software/packages"

    log "Rsyncing packages to iso stage directory"
    rsync -av "${PKG_STAGE_DIR}/" "${ISO_STAGE_DIR}/software/packages"

    log "Creating yum repodata"
    createrepo -g "$(find /mnt/repodata -name "*comps.xml")" "${ISO_STAGE_DIR}"

    # Copy kickstart and config to new iso
    log "Copying kickstart to iso stage directory"
    cp "${BASE_DIR}/files/isolinux.cfg" "${ISO_STAGE_DIR}/isolinux"
    cp "${BASE_DIR}/files/ks.cfg" "${ISO_STAGE_DIR}/isolinux/ks.cfg"

    # Set build version number in ks.cfg
    log "Setting build version to ${BUILD} in ks.cfg"
    sed -i "s/BUILD_TOKEN/${BUILD}/g" "${ISO_STAGE_DIR}/isolinux/ks.cfg"

    # Unmount base iso
    log "Unmounting ${ISO_CACHE_DIR}/${ISO_FILE}"
    sudo umount /mnt

    # Build iso artifact
    log "Creating ${ARTIFACT_DIR}"
    mkdir -p "${ARTIFACT_DIR}"

    log "Building iso artifact ${SPEC}-${BUILD}.iso"
    mkisofs -r -R -J -T -v \
        -input-charset utf-8 -no-emul-boot \
        -boot-load-size 4 -boot-info-table \
        -b isolinux/isolinux.bin -c isolinux/boot.cat \
        -o "${ARTIFACT_DIR}/${SPEC}-${BUILD}.iso" "${ISO_STAGE_DIR}"
    ARTIFACTS+=("${ARTIFACT_DIR}/${SPEC}-${BUILD}.iso")
}

summary() {
    log "Built the following artifacts"
    for ARTIFACT in "${ARTIFACTS[@]}"
    do
        local SHA256="$(sha256sum "${ARTIFACT}")"
        log "${SHA256}"
    done

    log "Complete in ${SECONDS} seconds"
}

main() {
    while getopts "h :b:s:" OPTIONS
    do
        case "${OPTIONS}" in
            h) usage ;;
            b) BUILD="${OPTARG}" ;;
            s) SPECS+=("${OPTARG}") ;;
            *) usage ;;
        esac
    done

    prep
    fetch_iso
    fetch_specs
    build_specs
    clean
    summary
}

main "${@}"

# EOF
