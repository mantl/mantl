#!/bin/bash
set -e

function usage() {
    echo "$0 - Launch application with Marathon"
    echo
    echo "Options:"
    echo
    echo "  -h, --help"
    echo "    Display this message"
    echo
    echo "  -c, --config"
    echo "    Application JSON config file"
    echo
    echo "  -m, --marathon"
    echo "    IP address or FQDN of the Marathon server"
    echo
    echo "  -u, --user"
    echo "    User for Marathon server (see 'marathon_http_credentials' in security.json)"
    echo
    echo "  -p, --password"
    echo "    Password for Marathon server (see 'marathon_http_credentials' security.json)"
    echo

    exit 0
}

function launch() {
    curl -s -X POST -H "Content-Type: application/json" "$MARATHON_URL" -d@"$CONFIG" | python -m json.tool
}

[[ "$#" -ne 8 ]] && usage
until [[ "$*" == "" ]]
do
    case "$1" in
        -c|--config)
            shift
            CONFIG="$1"
            ;;

        -m|--marathon)
            shift
            MARATHON="$1"
            ;;

        -u|--user)
            shift
            USER="$1"
            ;;

        -p|--password)
            shift
            PASS="$1"
            ;;

        -h|--help)
            usage
            ;;

        *)
            echo "Invalid argument: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

MARATHON_URL=$MARATHON
if [[ "0$USER" != "0" && "0$PASS" != "0" ]]; then
    MARATHON_URL="${USER}:${PASS}@${MARATHON}"
fi
MARATHON_URL+=":8080/v2/apps"

launch

# EOF
