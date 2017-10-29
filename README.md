# Q Alliance development docker setup

## Add docker to your project
1. Copy everything from `dev/` to your project. Our setup comes with percona MySQL and mailcatcher, but you can remove or replace them in the docker-compose files.
1. Add `docker-compose.yml` and `.docker-data/` to your `.gitignore`
1. Symlink or copy the OS-specific docker-compose file to `docker-compose.yml`
1. **Linux only:** export your UID and GID by adding these lines to your `~/.bashrc`, `~/.bash_profile` or some other script that runs on shell startup:
    ```bash
    export DOCKER_UID=$(id -u)
    export DOCKER_GID=$(id -g)
    ```
1. Build/download the images with `docker-compose build`. If you're on Linux and need to use `sudo` to build the image, run `sudo -E docker-compose build` to pass your environment you set earlier.
1. Finally, start the containers with `docker-compose up`

## PHP and Apache
1. Install dependencies with composer while the containers are running: `docker-compose exec web composer install`
2. Adjust `php.ini` and `vhost.conf` in `.docker-config`

## Node.js
1. Create a file named `.nvmrc` containing the node version that you want (for example `v8.8.0`)
1. Install that version of node in docker: `docker-compose run --rm nodejs 'nvm install'`.
1. Run npm/yarn commands in docker like this: `docker-compose run --rm nodejs 'npm install'`

Consider creating an alias for the first part of the command to make your life easier.
