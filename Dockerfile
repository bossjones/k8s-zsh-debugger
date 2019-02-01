FROM index.docker.io/ubuntu:18.04

ENV container docker
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get update -y && \
    apt-get install -yqq \
    python sudo bash ca-certificates \
    locales \
    lsb-release \
    openssh-server \
    software-properties-common ansible && \
    ansible-galaxy install viasite-ansible.zsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir /var/run/sshd

# install locales package and set default locale to 'UTF-8' for the test execution environment
RUN apt-get -y install locales && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV LANG en_US.UTF-8

# 1. small fix for SSH in ubuntu 13.10 (that's harmless everywhere else)
# 2. permit root logins and set simple password password and pubkey
# 3. change requiretty to !requiretty in /etc/sudoers
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^#?PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -ri 's/requiretty/!requiretty/' /etc/sudoers && \
    echo 'root:password' | chpasswd

# install core software for packaging and ssh communication
RUN echo -e "#!/bin/sh\nexit 101\n" > /usr/sbin/policy-rc.d && \
    apt-get -y install gdebi-core sshpass cron netcat net-tools iproute2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install dependencies
# `universe` is needed for ruby
# `security` is needed for fontconfig and fc-cache
RUN \
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe security" && \
    add-apt-repository ppa:aacebedo/fasd && \
    apt-get update && \
    apt-get -yqq install \
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
    zsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
################################################################################################################

# SOURCE: https://github.com/rastasheep/ubuntu-sshd/blob/master/16.04/Dockerfile
RUN apt-get update \
    && apt-get install -y \
    git-core curl wget bash vim \
    sudo \
    && apt-get install language-pack-en-base procps file make patch autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev -y \
    && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/

RUN set -xe \
    && useradd -U -d /home/test -m -r -G adm,sudo,dip,plugdev,tty,audio test \
    && usermod -a -G test -s /bin/bash -u 1000 test \
    && groupmod -g 1000 test \
    && ( mkdir /home/test/.ssh \
    && chmod og-rwx /home/test/.ssh \
    && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/test/.ssh/authorized_keys \
    ) \
    && echo 'test     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && echo '%test     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && cat /etc/sudoers \
    && echo 'test:test' | chpasswd

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
