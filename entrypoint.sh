#!/bin/bash
set -e

manage() {
    sudo -HEu netbox ./manage.py "$@"
}

initialize_config() {
    pushd netbox/ 2>&1 > /dev/null
    cp configuration{.docker,}.py
    popd 2>&1 > /dev/null
}

# Adapted from: https://github.com/sameersbn/docker-gitlab
check_db_connection() {
    DB_PORT=${DB_PORT:-5432}

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
