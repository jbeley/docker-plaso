FROM ubuntu:xenial
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
        apt-get -qq --allow-unauthenticated --no-install-recommends install \
            python-setuptools \
            curl \
            python-lzma \
            python3 \
            plaso \
            python-pip && \
            rm -rf /var/cache/apt/ /var/lib/apt/lists/

RUN curl -s -o /usr/bin/cdqr.py https://raw.githubusercontent.com/orlikoski/CDQR/master/src/cdqr.py
RUN chmod 755 /usr/bin/cdqr.py

RUN apt-get -qq -y clean && \
    apt-get remove -qq -y \
        apt-transport-https\
        curl\
        distro-info-data\
        gir1.2-glib-2.0\
        iso-codes\
        libcurl3-gnutls\
        libdbus-1-3\
        libdbus-glib-1-2\
        libgirepository-1.0-1\
        libglib2.0-0\
        lsb-release\
        makedev\
        python-apt-common\
        python-pip\
        python-pip-whl\
        python-setuptools\
        python3-apt\
        python3-dbus\
        python3-gi\
        python3-pycurl\
        python3-software-properties\
        software-properties-common && \
    apt-get -qq -y autoclean && \
    apt-get -qq -y autoremove

RUN useradd plaso

WORKDIR /home/plaso/
ENV HOME /home/plaso

VOLUME ["/data"]
USER plaso
