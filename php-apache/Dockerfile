FROM ubuntu:18.04

MAINTAINER Tin Benjamin Matuka <tin@q-alliance.com>

# install deps
RUN apt-get clean && \
    apt-get -y update && \
    apt-get install -y locales curl software-properties-common git apt-transport-https sudo telnet dnsutils inetutils-ping && \
    locale-gen en_US.UTF-8
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && apt-get update

# install apache, php and php modules
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes \
    apache2 \
    nano \
    lynx \
    libapache2-mod-php7.1 \
    php7.1-bcmath \
    php7.1-bz2 \
    php7.1-cli \
    php7.1-common \
    php7.1-curl \
    php7.1-cgi \
    php7.1-dev \
    php7.1-gd \
    php7.1-gmp \
    php7.1-imap \
    php7.1-intl \
    php7.1-json \
    php7.1-ldap \
    php7.1-mbstring \
    php7.1-mcrypt \
    php7.1-mysql \
    php7.1-odbc \
    php7.1-opcache \
    php7.1-pgsql \
    php7.1-phpdbg \
    php7.1-pspell \
    php7.1-readline \
    php7.1-recode \
    php7.1-soap \
    php7.1-sqlite3 \
    php7.1-tidy \
    php7.1-xml \
    php7.1-xmlrpc \
    php7.1-xsl \
    php7.1-zip \
    php-tideways \
    php-mongodb \
    php-memcache \
    php-memcached \
    php-apcu \
    php-apcu-bc \
    php-mail \
    php-xdebug && \
    phpenmod apcu && \
    phpenmod apcu_bc && \
    a2enmod rewrite headers ssl

# add xdebug settings - don't enable the mod by default
COPY ./php-xdebug.ini /etc/php/7.1/mods-available/xdebug-settings.ini

# output apache logs to stdout
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# set up sendmail so that mail() works
RUN apt-get install -y --force-yes ssmtp && \
    echo 'FromLineOverride=YES' >> /etc/ssmtp/ssmtp.conf && \
    echo 'mailhub=mail:25' >> /etc/ssmtp/ssmtp.conf

# prepare www-data to be used as main user
RUN usermod -s /bin/bash -G staff www-data && \
    sudo -u www-data mkdir -p /var/www

COPY ./sudoers /etc/sudoers.d/www-data

# install composer
RUN curl https://getcomposer.org/installer > composer-setup.php && \
    php composer-setup.php && \
    mv composer.phar /usr/local/bin/composer && \
    rm composer-setup.php && \
    chown www-data:www-data /usr/local/bin/composer && \
    chown -R www-data. /var/www

# link php.ini
RUN mv /etc/php/7.1/apache2/php.ini /etc/php/7.1/apache2/php.ini.dist && \
    mv /etc/php/7.1/cli/php.ini /etc/php/7.1/cli/php.ini.dist && \
    ln -s /etc/php/7.1/php.ini /etc/php/7.1/apache2/php.ini && \
    ln -s /etc/php/7.1/php.ini /etc/php/7.1/cli/php.ini

# override default vhost
COPY ./vhost.conf /etc/apache2/sites-available/000-default.conf

# set up default command
COPY ./apache2-foreground.sh /usr/local/sbin/

# clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app/

USER www-data

CMD sudo /usr/local/sbin/apache2-foreground.sh
