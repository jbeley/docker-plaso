FROM ubuntu:bionic
MAINTAINER @accenturecifr

ENV version 1.1.0
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq -y update && \
        apt-get -qq -y --no-install-recommends install \
            software-properties-common \
            apt-transport-https \
            apt-utils \
            software-properties-common && \
        add-apt-repository -u -y ppa:gift/stable
RUN     apt-get -qq -y update && \
        apt-get -y --no-install-recommends install \
            python-setuptools \
            curl \
            python-lzma \
            python3-plaso \
            plaso-tools \
            python-pip && \
            rm -rf /var/cache/apt/ /var/lib/apt/lists/

RUN curl -s -o /usr/bin/cdqr.py https://raw.githubusercontent.com/orlikoski/CDQR/master/src/cdqr.py
RUN chmod 755 /usr/bin/cdqr.py

RUN apt-get -qq -y clean && \
    apt-get remove -qq -y \
            apt-transport-https \
            curl \
            distro-info-data \
            gir1.2-glib-2.0 \
            gpg \
            gpgconf \
            iso-codes \
            libasn1-8-heimdal \
            libassuan0 \
            libcurl4 \
            libdbus-1-3 \
            libgirepository-1.0-1 \
            libglib2.0-0 \
            libgssapi-krb5-2 \
            libgssapi3-heimdal \
            libhcrypto4-heimdal \
            libheimbase1-heimdal \
            libheimntlm0-heimdal \
            libhx509-5-heimdal \
            libk5crypto3 \
            libkeyutils1 \
            libkrb5-26-heimdal \
            libkrb5-3 \
            libkrb5support0 \
            libldap-2.4-2 \
            libldap-common \
            libnghttp2-14 \
            libpsl5 \
            libroken18-heimdal \
            librtmp1 \
            libsasl2-2 \
            libsasl2-modules-db \
            libwind0-heimdal \
            lsb-release \
            python-apt-common \
            python3-apt \
            python3-dbus \
            python3-gi \
            python3-software-properties \
            software-properties-common  && \
    apt-get -qq -y autoclean && \
    apt-get -qq -y autoremove

RUN useradd plaso

WORKDIR /home/plaso/
ENV HOME /home/plaso

VOLUME ["/data"]
USER plaso
