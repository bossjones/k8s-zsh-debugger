FROM index.docker.io/ubuntu:18.04

# ENV container docker
# ENV TERM xterm
# ENV DEBIAN_FRONTEND noninteractive

ENV NON_ROOT_USER=developer \
    container=docker \
    DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

ARG HOST_USER_ID=1000
ENV HOST_USER_ID ${HOST_USER_ID}
ARG HOST_GROUP_ID=1000
ENV HOST_GROUP_ID ${HOST_GROUP_ID}

# make apt use ipv4 instead of ipv6 ( faster resolution )
RUN sed -i "s@^#precedence ::ffff:0:0/96  100@precedence ::ffff:0:0/96  100@" /etc/gai.conf


# RUN sed -i "s,# deb-src http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) main restricted,deb-src http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) main restricted,g" /etc/apt/sources.list && \
#     sed -i "s,# deb-src http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc)-updates main restricted,deb-src http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc)-updates main restricted,g" /etc/apt/sources.list && \
#     DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
#     sudo \
#     bash-completion \
#     apt-file \
#     autoconf \
#     automake \
#     gettext \
#     build-essential \
#     ccache \
#     curl \
#     git \
#     lcov \
#     libbz2-dev \
#     libffi-dev \
#     libreadline-dev \
#     libsqlite3-dev \
#     libssl-dev \
#     python3-pip \
#     vim \
#     && \
#     \
#         apt-get upgrade -y && \
#         apt-get install -y \
#         git \
#         curl \
#         wget \
#         curl \
#         software-properties-common \
#         ca-certificates \
#         && \
#         locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && \
#         apt-get update && apt-get install -y --no-install-recommends \
#         tcl \
#         tk \
#         wget \
#         curl \
#         ca-certificates && \
#         apt-get update && apt-get install -y --no-install-recommends \
#         bzr \
#         git \
#         mercurial \
#         openssh-client \
#         subversion \
#         procps && \
#         apt-get update && apt-get install -y --no-install-recommends \
#         autoconf \
#         automake \
#         bzip2 \
#         file \
#         g++ \
#         gcc \
#         imagemagick \
#         libbz2-dev \
#         libc6-dev \
#         libcurl4-openssl-dev \
#         libdb-dev \
#         libevent-dev \
#         libffi-dev \
#         libgeoip-dev \
#         libglib2.0-dev \
#         libjpeg-dev \
#         libkrb5-dev \
#         liblzma-dev \
#         libmagickcore-dev \
#         libmagickwand-dev \
#         libmysqlclient-dev \
#         libncurses-dev \
#         libpng-dev \
#         libpq-dev \
#         libreadline-dev \
#         libsqlite3-dev \
#         libssl-dev \
#         libtool \
#         libwebp-dev \
#         libxml2-dev \
#         libxslt-dev \
#         libyaml-dev \
#         make \
#         patch \
#         xz-utils \
#         zlib1g-dev \
#         bash \
#         && apt-get autoclean -y && \
#         apt-get autoremove -y && \
#         rm -rf /var/lib/{cache,log}/ && \
#         rm -rf /var/lib/apt/lists/*.lz4


# add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe security" && \
# install locales package and set default locale to 'UTF-8' for the test execution environment
RUN \
    set -xe && apt-get update -y && \
    apt-get install -y \
    python sudo bash ca-certificates \
    locales \
    lsb-release \
    openssh-server \
    software-properties-common ansible && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8 && \
    mkdir -p /var/run/sshd && \
    apt-get -y install gdebi-core sshpass cron netcat net-tools iproute2 && \
    apt-get -y install \
    autoconf \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    fasd \
    fontconfig \
    gcc \
    git \
    iputils-ping \
    libevent-dev \
    libncurses-dev \
    locales \
    make \
    procps \
    python \
    python-dev \
    python-setuptools \
    ruby-full \
    sudo \
    tmux \
    vim \
    wget \
    python sudo bash ca-certificates \
    locales \
    lsb-release \
    openssh-server \
    software-properties-common ansible \
    git-core curl wget bash vim \
    sudo \
    && apt-get install language-pack-en-base procps file make patch autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev -y \
    && \
    apt-get install -y openssh-server \
    zsh && \
    sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG en_US.UTF-8


# SOURCE: https://github.com/rastasheep/ubuntu-sshd/blob/master/16.04/Dockerfile


# ansible-galaxy install viasite-ansible.zsh

# 1. small fix for SSH in ubuntu 13.10 (that's harmless everywhere else)
# 2. permit root logins and set simple password password and pubkey
# 3. change requiretty to !requiretty in /etc/sudoers
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -ri 's/requiretty/!requiretty/' /etc/sudoers && \
    echo 'root:password' | chpasswd

# # install core software for packaging and ssh communication
# RUN echo -e "#!/bin/sh\nexit 101\n" > /usr/sbin/policy-rc.d && \
#     set -xe && apt-get update -y && \
#     apt-get -y install gdebi-core sshpass cron netcat net-tools iproute2 && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Install dependencies
# # `universe` is needed for ruby
# # `security` is needed for fontconfig and fc-cache
# RUN \
#     set -xe && add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe security" && \
#     add-apt-repository ppa:aacebedo/fasd && \
#     apt-get update && \
#     apt-get -y install \
#     autoconf \
#     bash-completion \
#     build-essential \
#     ca-certificates \
#     curl \
#     fasd \
#     fontconfig \
#     gcc \
#     git \
#     iputils-ping \
#     libevent-dev \
#     libncurses-dev \
#     locales \
#     make \
#     procps \
#     python \
#     python-dev \
#     python-setuptools \
#     ruby-full \
#     sudo \
#     tmux \
#     vim \
#     wget \
#     zsh && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# ################################################################################################################

# # SOURCE: https://github.com/rastasheep/ubuntu-sshd/blob/master/16.04/Dockerfile
# RUN set -xe && apt-get update \
#     && apt-get install -y \
#     git-core curl wget bash vim \
#     sudo \
#     && apt-get install language-pack-en-base procps file make patch autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev -y \
#     && \
#     apt-get install -y openssh-server && \
#     mkdir /var/run/sshd && \
#     sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#     sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN set -xe \
#     && useradd -U -d /home/test -m -r -G adm,sudo,dip,plugdev,tty,audio test \
#     && usermod -a -G test -s /bin/bash -u 1000 test \
#     && groupmod -g 1000 test \
#     && ( mkdir /home/test/.ssh \
#     && chmod og-rwx /home/test/.ssh \
#     && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/test/.ssh/authorized_keys \
#     ) \
#     && echo 'test     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
#     && echo '%test     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
#     && cat /etc/sudoers \
#     && echo 'test:test' | chpasswd

RUN set -xe \
    && useradd -U -d /home/${NON_ROOT_USER} -m -r -G adm,tty,audio ${NON_ROOT_USER} \
    && usermod -a -G ${NON_ROOT_USER} -s /bin/bash -u ${HOST_USER_ID} ${NON_ROOT_USER} \
    && groupmod -g ${HOST_GROUP_ID} ${NON_ROOT_USER} \
    && ( mkdir /home/${NON_ROOT_USER}/.ssh \
    && chmod og-rwx /home/${NON_ROOT_USER}/.ssh \
    && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/${NON_ROOT_USER}/.ssh/authorized_keys \
    ) \
    && echo "${NON_ROOT_USER}     ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && echo "%${NON_ROOT_USER}     ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && cat /etc/sudoers \
    && echo "${NON_ROOT_USER}:${NON_ROOT_USER}" | chpasswd && \
    mkdir /var/run/dbus && \
    mkdir -p /home/${NON_ROOT_USER}/.local/bin && \
    chown ${NON_ROOT_USER}:${NON_ROOT_USER} -Rv /home/${NON_ROOT_USER}

EXPOSE 22

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# tmux stuff

RUN mkdir -p $HOME/.fonts $HOME/.config/fontconfig/conf.d \
    && wget -P $HOME/.fonts https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf \
    && wget -P $HOME/.config/fontconfig/conf.d/ https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf \
    && fc-cache -vf $HOME/.fonts/

WORKDIR /root

RUN git clone https://github.com/samoshkin/tmux-config \
    && ./tmux-config/install.sh \
    && rm -rf ./tmux-config

ENV TERM=xterm-256color

COPY playbook.yml /playbook.yml
COPY inventory.ini /inventory.ini

RUN ansible-playbook -i /inventory.ini -c local /playbook.yml

########################################

# INSTALL NVM
# # nvm environment variables
# ENV NVM_DIR /usr/local/nvm
# ENV NODE_VERSION 8.5.0

# # install nvm
# # SOURCE: https://gist.github.com/remarkablemark/aacf14c29b3f01d6900d13137b21db3a
# # https://github.com/creationix/nvm#install-script
# RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

# # install node and npm
# RUN source $NVM_DIR/nvm.sh \
#     && nvm install $NODE_VERSION \
#     && nvm alias default $NODE_VERSION \
#     && nvm use default

# # add node and npm to path so the commands are available
# ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
# ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# # confirm installation
# RUN node -v
# RUN npm -v

# RUN chown ${NON_ROOT_USER}:${NON_ROOT_USER} -R /usr/local/nvm

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/k8s-zsh-debugger"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"
MAINTAINER TonyDark Jarvis <jarvis@theblacktonystark.com>
