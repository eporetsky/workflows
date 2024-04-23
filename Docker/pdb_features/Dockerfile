# Based on: https://github.com/maliksahil/docker-ubuntu-sahil
# docker build --rm -f Dockerfile -t ubuntu:pdb_feat .
# docker run --name=pdb_feat -v ${PWD}/pdbs:/pdbs --rm -it ubuntu:pdb_feature

FROM ubuntu:22.04
LABEL maintainer="maintainer"

RUN apt-get update && \
    apt-get install -y python3-pip python3.8-dev python3-setuptools sudo curl git-core gnupg locales nodejs zsh wget nano nodejs npm fonts-powerline && \
    locale-gen en_US.UTF-8  && \
    adduser --quiet --disabled-password --shell /bin/zsh --home /home/devuser --gecos "User" devuser && \
    echo "devuser:password" | chpasswd &&  usermod -aG sudo devuser

# Install freesasa
RUN sudo wget https://freesasa.github.io/freesasa-2.1.2.zip && \
    sudo apt-get install -y unzip libc++-15-dev libc++abi-15-dev && \
    sudo unzip freesasa-2.1.2.zip && \
    cd freesasa-2.1.2 && \
    sudo ./configure --disable-xml --disable-json && \
    sudo make && \
    sudo make install

ADD installthemes.sh /home/devuser/installthemes.sh
USER devuser
ENV TERM xterm
ENV ZSH_THEME agnoster
CMD ["zsh"]

# docker run --name=pockets -v ${PWD}/pdbs:/pdbs --rm -it ubuntu:pdb_feature