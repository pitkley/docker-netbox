#!/bin/bash
set -e

manage() {
    sudo -HEu netbox ./manage.py "$@"
}

setup_environment_variables() {
    ALLOWED_HOSTS=${ALLOWED_HOSTS:-localhost}

    DB_NAME=${DB_NAME:-netbox}
    DB_USER=${DB_USER:-netbox}
    DB_PASS=${DB_PASS:-netbox}
    DB_HOST=${DB_HOST:-db}
    DB_PORT=${DB_PORT:-5432}

    LOGIN_REQUIRED=${LOGIN_REQUIRED:-False}

    BASE_PATH=${BASE_PATH:-''}
    METRICS_ENABLED=${METRICS_ENABLED:-False}

    : "${SECRET_KEY:?SECRET_KEY needs to be set}"
}

initialize_config() {
    pushd netbox/ 2>&1 > /dev/null
    cp configuration{.example,}.py

    # Update allowed hosts
    local allowed_hosts_raw="$ALLOWED_HOSTS"
    read -ra allowed_hosts_raw <<<"$allowed_hosts_raw"

    local allowed_hosts=""

    for host in "${allowed_hosts_raw[@]}"; do
        allowed_hosts="$allowed_hosts '$host',"
    done

    sed -i "/^ALLOWED_HOSTS =/c\\ALLOWED_HOSTS = [$allowed_hosts ]" configuration.py

    # Update DB configuration
    sed -i "/# Database name/c\\    'NAME': '$DB_NAME'," configuration.py
    sed -i "/# PostgreSQL username/c\\    'USER': '$DB_USER'," configuration.py
    sed -i "/# PostgreSQL password/c\\    'PASSWORD': '$DB_PASS'," configuration.py
    sed -i "/# Database server/c\\    'HOST': '$DB_HOST'," configuration.py
    sed -i "/# Database port/c\\    'PORT': '$DB_PORT'," configuration.py

    # Update secret key
    sed -i "/^SECRET_KEY = '/c\\SECRET_KEY = '$SECRET_KEY'" configuration.py

    # Login required
    sed -i "/^LOGIN_REQUIRED = /c\\LOGIN_REQUIRED = $LOGIN_REQUIRED" configuration.py

    # Base path
    sed -i "/^BASE_PATH = /c\\BASE_PATH = '$BASE_PATH'" configuration.py

    # Metrics enabled
    sed -i "/^METRICS_ENABLED = /c\\METRICS_ENABLED = '$METRICS_ENABLED'" configuration.py

    popd 2>&1 > /dev/null
}

# Adapted from: https://github.com/sameersbn/docker-gitlab
check_db_connection() {
    cmd=$(find /usr/lib/postgresql/ -name pg_isready)
    cmd="$cmd -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t 1"

    timeout=60
    while ! $cmd >/dev/null 2>&1; do
        timeout=$(expr $timeout - 1)
        if [[ $timeout -eq 0 ]]; then
            echo
            echo "Could not connect to database server. Aborting..."
            return 1
        fi
        echo -n "."
        sleep 1
    done
    echo
}

# Setup
setup_environment_variables
initialize_config

if [[ "$1" != "/"* ]]; then
    # Check for database
    check_db_connection

    # Migrate database
    manage migrate

    # Collect static files
    manage collectstatic --no-input

    exec sudo -HEu netbox ./manage.py "$@"
fi

exec "$@"
