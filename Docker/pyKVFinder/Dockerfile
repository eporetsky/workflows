# Based on: https://github.com/maliksahil/docker-ubuntu-sahil
# docker build --rm -f Dockerfile -t ubuntu:pyKVFinder .
# docker run --name=pyKVFinder -v ${PWD}/pdbs:/pdbs --rm -it ubuntu:pyKVFinder

FROM ubuntu:22.04
LABEL maintainer="maintainer"

RUN apt-get update && \
    apt-get install -y python3-pip python3.8-dev python3-setuptools sudo curl git-core gnupg locales nodejs zsh wget nano nodejs npm fonts-powerline && \
    locale-gen en_US.UTF-8  && \
    adduser --quiet --disabled-password --shell /bin/zsh --home /home/devuser --gecos "User" devuser && \
    echo "devuser:password" | chpasswd &&  usermod -aG sudo devuser

# Install freesasa
RUN sudo apt-get install -y swig && \
    pip install pyKVFinder
    
ADD installthemes.sh /home/devuser/installthemes.sh
USER devuser
ENV TERM xterm
ENV ZSH_THEME agnoster
CMD ["zsh"]

# docker run --name=pockets -v ${PWD}/pdbs:/pdbs --rm -it ubuntu:pdb_feature