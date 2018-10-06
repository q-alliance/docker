# Q Alliance development docker setup

## Add docker to your project
1. Copy everything from `dev/` to your project, including the "hidden" directory `.docker-config/`. Our setup comes with a mix of containers that fit our development needs, but you can remove or replace them in the docker-compose-* files.
1. Add `docker-compose.yml`, `.docker-config/php-xdebug.ini` and `.docker-data/` to your project's `.gitignore`
1. Symlink or copy the OS-specific docker-compose file to `docker-compose.yml`. For example, if you're running Linux, you copy or symlink the `docker-compose-linux.yml` file to `docker-compose.yml`.
1. __Linux only:__ export your UID and GID by adding these lines to your `~/.bashrc`, `~/.bash_profile` or some other script that runs on shell startup:
    ```bash
    export DOCKER_UID=$(id -u)
    export DOCKER_GID=$(id -g)
    ```
1. Build/download the images with `docker-compose build`. If you're on Linux and need to use `sudo` to build the image, run `sudo -E docker-compose build` to pass the environment variables you set earlier.
1. Finally, start the containers with `docker-compose up`

## Common issues

### Error starting userland proxy: listen tcp 0.0.0.0:*: bind: address already in use
Your host already has an application running on the specified port. Most likely, you have web/MySQL/Browsersync running outside of docker and using the same port. You have a couple of options:
1. Turn off the service that's running outside of docker, or change its port.
1. Change the port mapping in your docker-compose.yml. When you have a combination of ports like '3306:3306', the first port is the port on your host and the second one is the port in the container. If you change that to '3307:3306', you will be able to access the database from the host on port 3307, but your application running in docker will still connect to port 3306.
1. Remove the port mapping in your docker-compose.yml. If you don't need this service mapped (for exampleif you are running Browsersync outside of docker), you can simply remove the mapping.

### web_1 | httpd (pid *) already running
This issue has been fixed. If you run into it, update the image by running: `docker pull qalliance/php-apache`

### npm or yarn watchers slow or maxing out CPU on OSX
Mac OS has pretty slow file sharing with Docker and in most cases we suggest installing nvm and yarn on the host and running the watcher on the host.

If you are determined to run the watcher inside Docker, you can try using Docker CE Edge and setting up caching for the /app volume.

### `file not found` or `cannot start service` on OSX
If your project is outside of /Users, you will need to add it to the shared directories in Docker settings.

## Common usage

### PHP and Apache
  * Install dependencies with composer while the containers are running: `docker-compose exec web composer install`
  * Adjust `php.ini` and `vhost.conf` files in `.docker-config/`

### Node.js
  * Create a file named `.nvmrc` containing the node version that you want (for example `v8.8.0`)
  * Install that version of node in docker: `docker-compose run --rm nodejs nvm install`.
  * Run npm/yarn commands in docker like this: `docker-compose run --rm nodejs npm install`

Consider creating an alias for the first part of the command to make your life easier.

## Containers and services
Our setup has all the basic services we need for a PHP based web project.

### web - Apache and PHP
Apache is set up to run on standard ports: `80` for http and `443` for https. A valid (not self-signed) __SSL__ certificate is included in our setup. It covers the wildcard __*.q-devs.com__ domain, which is also pointed to 127.0.0.1 on our DNS. This allows you to easily use a different subdomain for each of your projects and prevents a lot of browser caching issues.

Default PHP version in the container is __7.1__ with pretty much all common modules installed and enabled. You can change the PHP version through the environment variable in your `docker-compose.yml` file and it will get switched on your next `docker-compose up`. You can also modify the `php.ini` file for your project in `.docker-config/php.ini`.

__Xdebug__ is also set up, but it is turned __off by default__ (for performance reasons). The default idekey is `PHPSTORM`, but you can change that and any other xdebug options by creating a `.docker-config/php-xdebug.ini` file and pointing the volume to it in your `docker-compose.yml`. Map your project root to `/app` in PhpStorm for mapping to work correctly.

PHP __composer__ is also globally installed in the container so that you can easily manage your dependencies from within the container.

Default connection info for your application:
Hostname: `web`
Port: `80` for http or `443` for https (the certificate won't match the hostname)

Default connection info from the host:
Hostname: `localhost`, `127.0.0.1` or any subdomain of `q-devs.com`

### db - Percona* MySQL server
Percona MySQL is Percona's drop-in replacement for MySQL with a lot of great features and performance improvements that make it more practical in production environments. There are issues with the official image on Windows, so we use the Oracle MySQL on Windows only.

Default connection info for your applications:
  * Hostname: `db` - communication between containers is done by using container names as domain names
  * Port: `3306`
  * Database name: `db`
  * User name: `user`
  * Password: `passw0rd!`
  * Root password is set to `d0ck3r!`, in case your application has to have root level access to MySQL.

Default connection info from the host:
  * Hostname: `localhost` or `127.0.0.1`
  * Port: `3306`

### nodejs - nvm and yarn
nvm (Node Version Manager) is used to install whichever Node.js version you need for the specific project. Once you choose your Node.js version for a project, we suggest that you write it in `.nvmrc`, so that all other developers can use that exact same version.

Yarn is installed globally in the container and set up to use the same Node.js you are using through nvm.

By default, the port `3000` is passed to the host, since it's the default port for Browsersync.

### mail - Mailcatcher
Mailcatcher is a mail (SMTP) server that doesn't pass any mail to the specified addresses, but catches them and displays them for testing and debugging in its web interface that is passed to port `1080` by default.

If you want to be able to send mail to Mailcatcher from your host, you can pass through port `25` in you `docker-compose.yml` files.

Default connection info for your applications:
  * Mail server: `mail`
  * Port: `25` for SMTP

Default connection info from the host:
  * Hostname: `localhost` or `127.0.0.1`
  * Port: `1080` for web interface
