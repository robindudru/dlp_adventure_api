FROM chialab/php:8.0-apache

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /home/app

#######################################
########## Configuration PHP ##########
#######################################

# extension php nécessaires
# intl      requis par Symfony
# apcu      opcache optimisation
# zip       requis par composer
# pdo_mysql 

# création du fichier de configuration php ini, exposant des variables d'environnement
# l'absence de timezone défini provoque une erreur
ENV PHP_DATE_TIMEZONE Europe/Paris
# memoire max allouée
ENV PHP_MEMORY_LIMIT 512M
# max upload file size
ENV PHP_UPLOAD_MAX_FILESIZE 6M
# Sécurisation des cookies si HTTPS
ENV PHP_COOKIE_SECURE 0
# optimisation du cache opcache
ENV PHP_OPCACHE_VALIDATE_TIMESTAMP 1
# optimisation pour windows
ENV PHP_REALPATH_CACHE_SIZE 4096K
RUN echo "date.timezone = ${PHP_DATE_TIMEZONE}"                              > /usr/local/etc/php/php.ini && \
    echo "short_open_tag = off"                                             >> /usr/local/etc/php/php.ini && \
    echo "expose_php = Off"                                                 >> /usr/local/etc/php/php.ini && \
    echo 'session.cookie_secure=${PHP_COOKIE_SECURE}'                       >> /usr/local/etc/php/php.ini && \
    echo 'memory_limit=${PHP_MEMORY_LIMIT}'                                 >> /usr/local/etc/php/php.ini && \
    echo 'upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE}'                   >> /usr/local/etc/php/php.ini && \
    echo 'opcache.validate_timestamps=${PHP_OPCACHE_VALIDATE_TIMESTAMP}'    >> /usr/local/etc/php/php.ini && \
    echo 'realpath_cache_size=${PHP_REALPATH_CACHE_SIZE}'                   >> /usr/local/etc/php/php.ini

##########################################
########## Configuration APACHE ##########
##########################################
RUN a2enmod headers proxy rewrite ssl proxy_wstunnel

ENV APACHE_DOCUMENT_ROOT /home/app/public
# configuration vhost apache, rediriger vers répertoire correspondant à la variable d'env APACHE_DOCUMENT_ROOT
# Sécurisation apache, ne pas exposer la version du server apache 
RUN sed -ri -e  's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g'     /etc/apache2/sites-available/*.conf && \
    sed -ri -e  's!/var/www/!${APACHE_DOCUMENT_ROOT}!g'         /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    sed -i -r   's/.*ServerTokens.*/ServerTokens Prod/'         /etc/apache2/conf-available/security.conf  && \
    sed -i -r   's/.*ServerSignature.*/ServerSignature Off/'    /etc/apache2/conf-available/security.conf

# on copie tout dans le container sauf les dossiers répertoriés dans .dockerignore
ADD ./ /home/app

# en sf 5 cette commande ne peut être lancé qu'en environnement de production
# ENV APP_ENV 1
# RUN composer install --no-dev --no-progress
RUN composer install --no-progress
