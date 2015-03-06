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
}

function launch() {
    curl -s -X POST -H "Content-Type: application/json" "$MARATHON:8080/v2/apps" -d@"$CONFIG" | python -m json.tool
}

[[ "$#" -ne 4 ]] && usage
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

        -h|--help)
            usage
            exit 0
            ;;

        *)
            echo "Invalid argument: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

launch

# EOF
