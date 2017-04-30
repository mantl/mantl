#!/bin/bash
set -e

echo "#################################"
echo "Hello,"
echo "This is automated release making,"
echo "it'll ask for auth input,"
echo "stay sharp."
echo "#################################"

MANTL_REPO=${MANTL_REPO:-`pwd`/mantl-tmp}
PACKAGES_REPO=${PACKAGES_REPO:-`pwd`/mantl-packaging-tmp}
RELEASE=${RELEASE:?Please set release version}

# If Mantl repo not provided, lets git clone it
if [ ! -e $MANTL_REPO ] ; then
  echo "MANTL_REPO env var not provided, cloning the Mantl master branch"
  git clone https://github.com/ciscocloud/mantl.git $MANTL_REPO
fi

# If packages repo not provided, lets git clone it
if [ ! -e $PACKAGES_REPO ] ; then
  echo "PACKAGES_REPO env var not provided, cloning the mantl-packaging master branch"
  git clone https://github.com/asteris-llc/mantl-packaging.git $PACKAGES_REPO
fi

echo "#############################"
echo "These credentials will be used"
echo "to push git PRs into github."
echo
echo "~ Enter your GitHub username:"
read GITHUB_USERNAME
echo "~ Enter your GitHub password:"
read -s GITHUB_PASSWORD

# Update Mantl's yum repositories
pushd $MANTL_REPO
git checkout master
git checkout -b feature/release-$RELEASE-repo-update
sed -i "s/\:[^\/]*$/\: ${RELEASE}/g" ./roles/repos/defaults/main.yml
git add roles/repos/defaults/main.yml
git commit -m "AUTOMATED RELEASE UPDATE: Mantl yum repo points to $RELEASE packages repo"
git push https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/ciscocloud/mantl feature/release-$RELEASE-repo-update
curl -u $GITHUB_USERNAME:$GITHUB_PASSWORD -X POST --data '{"title":"AUTO-RELEASE: '"$RELEASE"'","head":"feature/release-'"$RELEASE"'-repo-update","base":"master","body":"Set the new yum repositories into action"}' --header "Content-Type:application/json" https://api.github.com/repos/CiscoCloud/mantl/pulls >> release-debug
popd

# Update packaging repo
pushd $PACKAGES_REPO
OLD_RELEASE=`cat .bintray | awk -F\- '{print $2}'`

git checkout master
git checkout -b release/$OLD_RELEASE

git checkout master
git checkout -b feature/release-$RELEASE
sed -i "s/\/.*/\/mantl-${RELEASE}/g" .bintray
git add .bintray
git commit -m "Auto-Release: ${RELEASE}"

git push https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/asteris-llc/mantl-packaging release/$OLD_RELEASE
git push https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/asteris-llc/mantl-packaging feature/release-$RELEASE
curl -u $GITHUB_USERNAME:$GITHUB_PASSWORD -X POST --data '{"title":"AUTO-RELEASE: '"$RELEASE"'","head":"feature/release-'"$RELEASE"'","base":"master","body":"Push packages into new bintray repo"}' --header "Content-Type:application/json" https://api.github.com/repos/asteris-llc/mantl-packaging/pulls >> release-debug
popd

# Explain next steps to be taken to conclude the release
echo "Now accept PR in asteris-llc/mantl-packaging in order to upload packages into new repo,"
echo "and then accept PR in ciscocloud/mantl repo."

# Cleanup
if [ -e `pwd`/mantl-tmp ]; then
  rm -rf `pwd`/mantl-tmp
fi

if [ -e `pwd`/mantl-tmp ]; then
  rm -rf `pwd`/mantl-packaging-tmp
fi
