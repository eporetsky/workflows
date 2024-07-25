FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y git-core

RUN apt-get install -y build-essential make parallel

RUN git clone https://github.com/GodzikLab/FATCAT-dist.git && \
    cd FATCAT-dist && \
    ./Install

WORKDIR /FATCAT-dist