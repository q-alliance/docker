FROM ubuntu:18.04

MAINTAINER Tin Benjamin Matuka <tin@q-alliance.com>

# install deps, apache, php and php modules all in one run and clean up afterwards to reduce the snapshot size
RUN apt-get clean && \
    apt-get -y update && \
    apt-get install -y --force-yes \
        locales \
        curl \
        software-properties-common \
        git \
        apt-transport-https \
        sudo \
        nvi \
        iproute2 \
        telnet \
        dnsutils \
        unzip \
        inetutils-ping && \
    locale-gen en_US.UTF-8 && \
    LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes \
        apache2 \
        nano \
        lynx \
        ssmtp \
        imagemagick \
        php5.6 php7.0 php7.1 php7.2 \
        libapache2-mod-php5.6 libapache2-mod-php7.0 libapache2-mod-php7.1 libapache2-mod-php7.1 libapache2-mod-php7.2 \
        php5.6-bcmath php7.0-bcmath php7.1-bcmath php7.2-bcmath \
        php5.6-bz2 php7.0-bz2 php7.1-bz2 php7.2-bz2 \
        php5.6-cli php7.0-cli php7.1-cli php7.2-cli \
        php5.6-common php7.0-common php7.1-common php7.2-common \
        php5.6-curl php7.0-curl php7.1-curl php7.2-curl \
        php5.6-cgi php7.0-cgi php7.1-cgi php7.2-cgi \
        php5.6-dev php7.0-dev php7.1-dev php7.2-dev \
        php5.6-gd php7.0-gd php7.1-gd php7.2-gd \
        php5.6-gmp php7.0-gmp php7.1-gmp php7.2-gmp \
        php5.6-imap php7.0-imap php7.1-imap php7.2-imap \
        php5.6-intl php7.0-intl php7.1-intl php7.2-intl \
        php5.6-json php7.0-json php7.1-json php7.2-json \
        php5.6-ldap php7.0-ldap php7.1-ldap php7.2-ldap \
        php5.6-mbstring php7.0-mbstring php7.1-mbstring php7.2-mbstring \
        php5.6-mcrypt php7.0-mcrypt php7.1-mcrypt \
        php5.6-mysql php7.0-mysql php7.1-mysql php7.2-mysql \
        php5.6-odbc php7.0-odbc php7.1-odbc php7.2-odbc \
        php5.6-opcache php7.0-opcache php7.1-opcache php7.2-opcache \
        php5.6-pgsql php7.0-pgsql php7.1-pgsql php7.2-pgsql \
        php5.6-pspell php7.0-pspell php7.1-pspell php7.2-pspell \
        php5.6-readline php7.0-readline php7.1-readline php7.2-readline \
        php5.6-recode php7.0-recode php7.1-recode php7.2-recode \
        php5.6-snmp php7.0-snmp php7.1-snmp php7.2-snmp \
        php5.6-soap php7.0-soap php7.1-soap php7.2-soap \
        php5.6-sqlite3 php7.0-sqlite3 php7.1-sqlite3 php7.2-sqlite3 \
        php5.6-tidy php7.0-tidy php7.1-tidy php7.2-tidy \
        php5.6-xml php7.0-xml php7.1-xml php7.2-xml \
        php5.6-xmlrpc php7.0-xmlrpc php7.1-xmlrpc php7.2-xmlrpc \
        php5.6-xsl php7.0-xsl php7.1-xsl php7.2-xsl \
        php5.6-zip php7.0-zip php7.1-zip php7.2-zip \
        php-sodium \
        php-tideways \
        php-mongodb \
        php-memcache \
        php-memcached \
        php-phalcon \
        php-redis \
        php-apcu \
        php-apcu-bc \
        php-mail \
        php-imagick \
        php-amqp \
        php-xdebug && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# enable missing modules
RUN phpenmod apcu && \
    phpenmod apcu_bc && \
    a2enmod rewrite headers ssl

# output apache logs to stdout
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# set up sendmail so that mail() works
RUN echo 'FromLineOverride=YES' >> /etc/ssmtp/ssmtp.conf && \
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
COPY ./php.ini /etc/php.ini
RUN for phpversion in 5.6 7.0 7.1 7.2; do \
        for phpenv in apache2 cli; do \
            mv "/etc/php/$phpversion/$phpenv/php.ini" "/etc/php/$phpversion/$phpenv/php.ini.dist" ; \
            ln -s /etc/php/php.ini "/etc/php/$phpversion/$phpenv/php.ini"; \
        done; \
    done

# add xdebug settings - don't enable the mod by default
COPY ./php-xdebug.ini /etc/php/xdebug-settings.ini
RUN for phpversion in 5.6 7.0 7.1 7.2; do \
        rm "/etc/php/$phpversion/mods-available/xdebug.ini"; \
        ln -s /etc/php/xdebug-settings.ini "/etc/php/$phpversion/mods-available/xdebug.ini"; \
    done

# override default vhost
COPY ./vhost.conf /etc/apache2/sites-available/000-default.conf

# prepare entrypoint and default command
COPY ./entrypoint.sh /usr/local/bin/
COPY ./apache2-foreground.sh /usr/local/sbin/

WORKDIR /app/

USER www-data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["sudo", "/usr/local/sbin/apache2-foreground.sh"]
