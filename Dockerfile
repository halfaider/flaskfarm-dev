# noble은 python이 3.12로 설치되고 3.12에서 libsc가 작동하지 않음
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
LABEL maintainer='halfaider'
ARG WORKSPACE="/projects"
ARG FF_ROOT="${WORKSPACE}/flaskfarm"
ARG FF_DATA="${FF_ROOT}/data"
ENV WORKSPACE="${WORKSPACE}"
ENV FF_ROOT="${FF_ROOT}"
ENV FF_DATA="${FF_DATA}"
ENV DEBIAN_FRONTEND="noninteractive"
ENV C_FORCE_ROOT=true
# noble부터는 전역 환경에서 pip install이 기본 차단됨
ENV PIP_BREAK_SYSTEM_PACKAGES=1
RUN sed -i '1i deb https://ftp.kaist.ac.kr/ubuntu-ports/ jammy main' /etc/apt/sources.list && \
    sed -i '2i deb-src https://ftp.kaist.ac.kr/ubuntu-ports/ jammy main' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
    python3.10 \
    python3-pip \
    redis-server \
    git \
    net-tools \
    unzip \
    openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install -U pip setuptools && \
    pip install -r /tmp/requirements.txt && \
    python3 -m pip cache purge

# SSH 디렉토리 생성 및 설정
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config


RUN mkdir -p /tmp/flaskfarm-dev
COPY docker/etc/ /etc
COPY docker/tmp/ /tmp
EXPOSE 22/tcp
EXPOSE 9999/tcp