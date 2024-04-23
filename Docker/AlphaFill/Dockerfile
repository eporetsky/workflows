FROM ubuntu:24.04
LABEL maintainer="externelly"

RUN apt-get update && \
    apt-get install -y curl git-core zsh wget nano 
    
# Install freesasa
RUN apt-get install -y libzeep-dev libc++-dev libmcfp-dev cmake make g++ zlib1g-dev

RUN git clone https://github.com/PDB-REDO/alphafill  && \
    cd alphafill  && \
    cmake . -DCMAKE_BUILD_TYPE=Release  && \
    cmake --build .  && \
    ctest --test-dir .  && \
    cmake --install . && \
    sed -i -e 's/<NEEDS_TO_BE_CHANGED>/\/input/g' /usr/local/etc/alphafill.conf

