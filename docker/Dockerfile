FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
LABEL maintainer='halfaider'
ARG FF_ROOT="/flaskfarm-dev"
ARG FF_DATA="${FF_ROOT}/data"
ENV FF_DATA="${FF_DATA}"
ENV FF_ROOT="${FF_ROOT}"
ENV DEBIAN_FRONTEND="noninteractive"
ENV C_FORCE_ROOT=true
RUN sed -i '1i deb https://ftp.kaist.ac.kr/ubuntu-ports/ jammy main' /etc/apt/sources.list && \
    sed -i '2i deb-src https://ftp.kaist.ac.kr/ubuntu-ports/ jammy main' /etc/apt/sources.list
COPY root/ /
EXPOSE 9999/tcp