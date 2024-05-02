FROM ubuntu:24.04
LABEL maintainer="externelly"

RUN apt-get update -y && apt-get install -y wget curl git tar bzip2 unzip build-essential && rm -rf /var/lib/apt/lists/*

RUN wget -P /tmp \
    "https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Miniforge3-Linux-x86_64.sh" \
    && bash /tmp/Miniforge3-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniforge3-Linux-x86_64.sh
ENV PATH /opt/conda/bin:$PATH

RUN git clone https://github.com/JudeWells/chainsaw.git && \
    cd chainsaw && \
    mkdir results && \
    pip install -r requirements.txt && \
    cd stride && \
    tar -zxf stride.tgz && \
    make

WORKDIR /chainsaw

ENTRYPOINT ["python", "get_predictions.py"]