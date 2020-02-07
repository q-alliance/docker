#!/bin/bash

# Set host for xdebug on linux
if [ -r /etc/docker_host ] && [ "$(cat /etc/docker_host)" == 'linux' ]
then
    gatewayIp="$(ip route | grep -E '^default' | grep -Eo '([0-9]{1,3}\.?){4}')"
    currentHostIp="$(cat /etc/hosts | grep -E 'host.docker.internal' | grep -Eo '([0-9]{1,3}\.?){4}')"

    if [ "$gatewayIp" != "$currentHostIp" ]
    then
        # delete line if it exists
        if [ -n "$(grep -Eo 'host\.docker\.internal' /etc/hosts)" ]
        then
            sudo ex -s -c "g/host\.docker\.internal/d | wq" /etc/hosts &>/dev/null
        fi

        # add line
        echo "${gatewayIp} host.docker.internal" | sudo tee --append /etc/hosts &>/dev/null
    fi
fi

# use default or specified PHP version
phpVersion="7.1"

if [ -n "${PHP_VERSION}" ] && [[ "${PHP_VERSION}" =~ ^5.6|7.[0-4]$ ]]
then
    phpVersion="${PHP_VERSION}"
fi

echo "Using PHP version ${phpVersion}"

sudo update-alternatives --set php "/usr/bin/php${phpVersion}" &>/dev/null
sudo a2dismod 'php*' &>/dev/null
sudo a2enmod "php${phpVersion}" &>/dev/null

set -e

args="$@"

if [[ "$-" =~ i ]]
then
    # interactive
    /bin/bash --login -i -c "${args}"
else
    # non-interactive
    /bin/bash --login -c "${args}"
fi
