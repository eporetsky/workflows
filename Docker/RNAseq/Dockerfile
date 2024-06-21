FROM ubuntu:24.04
LABEL maintainer="externelly"

RUN apt-get update -y && apt-get install -y wget curl git tar bzip2 unzip pigz axel build-essential && rm -rf /var/lib/apt/lists/*

RUN wget -P /tmp \
    "https://github.com/conda-forge/miniforge/releases/download/24.3.0-0/Miniforge3-Linux-x86_64.sh" \
    && bash /tmp/Miniforge3-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniforge3-Linux-x86_64.sh
ENV PATH /opt/conda/bin:$PATH

RUN conda install -y -c bioconda snakemake hisat2 fastp sambamba subread

RUN pip install pandas

WORKDIR /mount