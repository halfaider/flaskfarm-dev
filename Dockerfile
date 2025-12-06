FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
LABEL maintainer='halfaider'
ARG WORKSPACE="/projects"
ARG FF_DEV="/flaskfarm-dev"
ARG FF_ROOT="${WORKSPACE}/flaskfarm"
ARG FF_DATA="${FF_ROOT}/data"
ENV WORKSPACE="${WORKSPACE}"
ENV FF_DEV="${FF_DEV}"
ENV FF_ROOT="${FF_ROOT}"
ENV FF_DATA="${FF_DATA}"
ENV DEBIAN_FRONTEND="noninteractive"
ENV C_FORCE_ROOT=true
RUN sed -i '1i deb https://ftp.kaist.ac.kr/ubuntu-ports/ jammy main' /etc/apt/sources.list && \
    sed -i '2i deb-src https://ftp.kaist.ac.kr/ubuntu-ports/ jammy main' /etc/apt/sources.list
RUN mkdir -p /tmp/flaskfarm-dev
COPY docker/etc/ /etc
COPY docker/tmp/ /tmp
EXPOSE 9999/tcp