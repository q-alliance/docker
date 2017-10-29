FROM ubuntu:16.04

MAINTAINER Tin Benjamin Matuka <tin@q-alliance.com>

# install deps
RUN apt-get clean && \
    apt-get -y update && \
    apt-get install -y locales curl sudo build-essential libssl-dev apt-transport-https && \
    locale-gen en_US.UTF-8

# install yarn without nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get -y update && \
    apt-get install -y --no-install-recommends yarn

# prepare www-data to be used as main user
RUN usermod -s /bin/bash -G staff www-data && \
    mkdir -p /var/www && \
    chown www-data. /var/www

# install nvm
RUN sudo -i -u www-data sh -c 'curl -sL -o- "https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh" | bash' && \
    sudo -u www-data mkdir /var/www/nvm-volume

# clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# set up sudo for www-data
COPY ./sudoers /etc/sudoers.d/www-data

# set up .profile for www-data
COPY ./nodejs-profile /var/www/.profile
RUN chown -R www-data. /var/www

WORKDIR /app/

USER www-data

ENTRYPOINT ["/bin/bash", "--login", "-i", "-c"]
