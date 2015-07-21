## Varnish Docker image

 - Centos 7
 - Varnish 4.x

### Supported tags and respective Dockerfile links

  - `:4`, `:latest` (default)
  - `:3`

### Base docker image

 - [hub.docker.com](https://registry.hub.docker.com/u/eeacms/varnish)


### Source code

  - [github.com](http://github.com/eea/eea.docker.varnish)


### Installation

1. Install [Docker](https://www.docker.com/).

## Usage


### Run with backends specified as environment variables

    $ docker run --env BACKENDS=74.125.140.103:80 eeacms/varnish:4

Setting the `BACKENDS` variable tells varnish to use the `-b` parameter and thus not use any `.vcl` files. To test this functionality you can run the commant above and navigate to `localhost:8080` inside your browser.

    $ docker run -p 8080:80 --env BACKENDS=87.54.7.167:80 eeacms/varnish:4

The command forwards the port 80 in the container to port 8080 on your machine, so you can view the results in your browser, and adds a backend with the IP 87.54.7.167 providing services on the port 80.

You can specify hosts by name, but they have to be included in `/etc/hosts` in the container. This could be done, for example, by extending the image and adding a custom /etc/hosts file inside the container, overwriting the default one.

### Mount a conf.d directory as a volume 

To use this container, you will need to provide your custom `.vcl` files. The `default.vcl` file is static and serves as base configuration that may not be changed once the container is running. The configuration files found in the `conf.d` directory are automatically included into the base `default.vcl` file in lexico-graphic order (keep in mind that in VCL the order files are included matters, so name your configuration files accordingly). The directory containing the configuration files must be mounted as a volume, located at `/etc/varnish/conf.d/` inside the container.

    $ docker run -d \
        -v /absolute/path/to/configuration/directory:/etc/varnish/conf.d \
        eeacms/varnish:4

### Extend the image with a custom default.vcl file

The `default.vcl` file provided with this image is bare and only contains the marker to specify the VCL version. If you want to use your own file, you can extend the image in a Dockerfile, like this:

    FROM eeacms/varnish:4
    COPY /absolute/path/to/my/default.vcl/file:/etc/varnish/default.vcl

and then run

    $ docker build -t your-image-name:your-image-tag /path/to/Dockerfile

As before, you are able to mount a `conf.d` directory in which to put your `.vcl` files, in order to have modular configuration.

### Change and reload configuration without restarting the container

Since the configuration directory is mounted as a volume, you can modify its content from outside the container. In order for the modifications to be loaded by the varnish daemon, you have to run the `reload` command, as following:

    $ docker exec <container-name-or-id> reload

The command will load the new configuration, compile it, and if compilation succeeds replace the old one with it. If compilation of the new configuration fails, the varnish daemon will continue to use the old configuration. Keep in mind that the only way to restore a previous configuration is to restore the configuration files and then reload them.

### Upgrade

    $ docker pull eeacms/varnish:4

## Supported environment variables ##


### varnish.env ###

  As varnish has close to no purpose by itself, this image should be used in combination with others with [Docker Compose](https://docs.docker.com/compose/). The varnish daemon can be configured by modifying the following env variables, either when running the container or in a `docker-compose.yml` file, using the `env_file` tag.

  * `PRIVILEDGED_USER` Priviledge separation user id
  * `CACHE_SIZE` Size of the cache storage
  * `ADDRESS_PORT` HTTP listen address and port
  * `PARAM_VALUE` A list of parameter-value pairs, each preceeded by the `-p` flag
  * `BACKENDS` A list of `host:port` pairs separated by space (e.g. `BACKENDS=127.0.0.1:80 74.125.140.103:80`) that will override the VCL configuration

### Docker Compose example
Here is a basic example of a `docker-compose.yml` file using the `eeacms/varnish` docker image:

    database:
      image: eeacms/postgres

    app:
      image: eeacms/plone-instance
      links:
       - database

    varnish:
      image: eeacms/varnish
      links:
       - app
      volumes:
       - /absolute/path/to/varnish/conf.d/directory/:/etc/varnish/conf.d/
      # env_file:
       # - /path/to/varnish.env

The application can be scaled to use more application instances, with `docker-compose scale`:

    $ docker-compose scale database=1 app=<number of instances> varnish=1

An example of such an application is [EEAGlossary](https://github.com/eea/eea.docker.glossary).

## Copyright and license

The Initial Owner of the Original Code is European Environment Agency (EEA).
All Rights Reserved.

The Original Code is free software;
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later
version.


## Funding

[European Environment Agency (EU)](http://eea.europa.eu)