#!/bin/bash
set -e

usage() {
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
    echo "    User for Marathon server (default: admin)"
    echo
    echo "  -p, --password"
    echo "    Password for Marathon server (see 'nginx_admin_password' in security.yml)"
    echo
    
    exit 0
}

launch() {
    curl -k -X POST -H "Content-Type: application/json" "https://$MARATHON_URL" -d@"$CONFIG"
}

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
            PASSWORD="$1"
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

# test for mandatory arguments
[[ -n "$CONFIG" ]] || usage
[[ -n "$MARATHON" ]] || usage

# construct marathon url
[[ -n "$USER" && -n "$PASSWORD" ]] && MARATHON_URL="$USER:$PASSWORD@$MARATHON" || MARATHON_URL="$MARATHON"
MARATHON_URL+=":8080/v2/apps"

launch

# EOF
