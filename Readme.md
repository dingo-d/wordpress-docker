[![License: MIT](https://img.shields.io/github/license/dingo-d/wordpress-docker.svg?style=for-the-badge)](https://github.com/dingo-d/wordpress-docker/blob/master/LICENSE)
[![GitHub All Releases](https://img.shields.io/github/downloads/dingo-d/wordpress-docker/total.svg?style=for-the-badge)](https://github.com/dingo-d/wordpress-docker/releases/)

# WordPress on Docker

A blueprint Docker configuration used for WordPress development on Docker.

This is a repository for testing out working with WordPress on Docker. You can use it as a base for your project, to play and to use as you wish.

## :books: Table of contents
- [:school_satchel: Requirements](#school_satchel-requirements)
- [:rocket: Development setup](#rocket-development-setup)
- [:scroll: License](#scroll-license)

## :school_satchel: Requirements

* [Docker](https://www.docker.com/)

#### Optional

* [Node.js](https://nodejs.org/en/)
* [Composer](https://getcomposer.org/)

## :rocket: Development setup

Development is done locally, using Docker for quick starting the application. In order to start working on the app, once you've cloned the repository locally you should use the `make` command. This will:

1. Copy the `.env.example` to `.env`
2. List all the useful commands you might want to use for kick-starting your project

You'll need to fill the created `.env` file with the necessary data.

### SSL setup

This setup uses locally self signed SSL certificate to make your site run on HTTPS. In order to enable the SSL locally you'll need to set it up first.

Add the value of the `APP_HOST` variable from the `.env` file to you hosts file using `vim`, `nano` or what ever editor you like. The following is an example how to add it on MacOS using terminal

```bash
sudo nano /etc/hosts
```

Then add

```bash
0.0.0.0 APP_HOST GOES HERE
```

And save it. On Windows, the hosts is located in `C:\windows\system32\drivers\etc\hosts`.

Generate an openssl key/cert pair from your development folder:

```bash
make create-certificate
```

You will have to fill in the following questions;

```bash
* Country Name (2 letter code)
* State or Province Name (full name)
* Locality Name (eg, city)
* Organization Name (eg, company)
* Organizational Unit Name (eg, section)
* Common Name (eg, fully qualified host name) -> APP_HOST
* Email Address
```

Once this is done, you should have 2 files in the `config/certs` folder

```bash
APP_HOST.crt
APP_HOST.key
```

Add the `.crt` file to your keychain access and change the `Trust` settings to `Always Trust` (on MacOS).

### WordPress setup

Before starting the docker up, you'll need to copy the `wp-config.php.tmpl` to `wp-config.php`, and `ngixn.conf.tmpl` to `ngixn.conf`. If you have set up the `.env` file type

```bash
make copy-configs
```

You can test if everything is set up correctly for your `docker-compose.yml` with

```bash
make docker-config
```

This will prefill all the values with environment variables from `.env` file and resolve the paths.

After all has been set up in the environment file run

```bash
make docker-build
```

This will create the containers for the app. To run them (in a detached state) you need to type

```bash
make docker-up
```

### Production settings

Some settings like `nginx.conf` and `php.ini` (especially the opcache settings) need to be modified for production. You should coordinate with your devops when working on production environment.

## :bullseye: Additional services

You can add additional services in your `docker-compose.yml` if you want to. The `.env.example` contains the environment variables for `redis` and `mailhog` services. To use them, add them to your `docker-compose.yml` file under `services` like

```yml
  redis:
    image: redis
    container_name: ${REDIS_CONTAINER_NAME}
    environment:
      REDIS_SCHEME: ${REDIS_SCHEME}
      REDIS_HOST: ${REDIS_HOST}
      REDIS_PORT: ${REDIS_PORT}
    expose:
      - ${REDIS_PORT}
    ports:
      - ${REDIS_PORT}:${REDIS_PORT}

  mailhog:
    image: mailhog/mailhog
    container_name: docker-mailhog
    ports:
      - "${MAILHOG_HOST_PORT_SMTP}:1025"
      - "${MAILHOG_HOST_PORT_WEB}:8025"
```

## :scroll: License

WordPress on Docker is free software, and may be redistributed under the terms specified in the LICENSE file.
Copyright ©2019

