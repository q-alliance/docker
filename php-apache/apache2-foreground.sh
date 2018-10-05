#!/usr/bin/env bash

# Set host for xdebug on linux
if [ -r /etc/docker_host ] && [ "$(cat /etc/docker_host)" == 'linux' ]
then
    gatewayIp="$(ip route | grep -E '^default' | grep -Eo '([0-9]{1,3}\.?){4}')"
    currentHostIp="$(cat /etc/hosts | grep -E 'host.docker.internal' | grep -Eo '([0-9]{1,3}\.?){4}')"

    if [ "$gatewayIp" != "$currentHostIp" ]
    then
        # delete line if it exists
        sudo sed -i '/host.docker.internal/d' /etc/hosts

        # add line
        sudo echo "${gatewayIp} host.docker.internal" >> /etc/hosts
    fi
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec /usr/sbin/apache2ctl -D FOREGROUND
