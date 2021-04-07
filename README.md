# Netbox docker image

Docker image for [NetBox][gh-nb].

![maintenance-status](https://img.shields.io/badge/maintenance-as--is-yellow.svg)

<sub>There are no plans for new features, issues that get filed are responded to on a best-effort basis.</sub>

## Using docker-compose

1. Create a copy of [`docker-compose.example.yml`](docker-compose.example.yml) to [`docker-compose.prod.yml`](docker-compose.prod.yml)
2. Create .env containing:

    ```
    COMPOSE_FILE=docker-compose.prod.yml
    
    #TZ= #Set me to your timezone i.e. Europe/Stockholm
    DB_HOST=db
    DB_NAME=netbox
    DB_USER=netbox
    DB_PASS=netbox
    ```

3. Create .env.app containing:

    ```
    SECRET_KEY=CHANGE_ME
    ALLOWED_HOSTS=['netbox.dev', 'localhost']
    ```

4. Change settings specifically for this instance:

    * `ALLOWED_HOSTS`: accepts multiple hostnames separated using spaces, you should add the hostname which the installation will be reached at
    * `SECRET_KEY`: required, should be randomly generated and [50 characters or more][gh-nb-secret-key]

    Optionally you can also change the database password by modifying `POSTGRES_PASSWORD` and `DB_PASS`.

3. Create a new superuser using the following command:

    ```console
    $ sudo docker-compose run --rm netbox createsuperuser
    ```

4. Start the service stack:

    ```console
    $ sudo docker-compose up -d
    ```

NetBox will be available under port 8000.

## Additional configuration

* `BASE_PATH`: set this if netbox is running behind a reverse proxy and you need the URL to be rewritten, for example if you want to reach your netbox via example.com/netbox/, set BASE_PATH='netbox/'

[gh-nb]: https://github.com/digitalocean/netbox
[gh-nb-secret-key]: https://github.com/digitalocean/netbox/blob/8563e2aca30fd160b62bbf1f734b2b3b0cf24cfe/docs/configuration.md#secret_key

