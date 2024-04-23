# docker build --rm -f Dockerfile -t externelly/diffdock:latest .

FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04
LABEL maintainer="externelly"

RUN apt-get update -y && apt-get install -y wget libxml2 cuda-minimal-build-11-3 libcusparse-dev-11-3 libcublas-dev-11-3 libcusolver-dev-11-3 git

RUN wget -P /tmp \
    "https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Miniforge3-Linux-x86_64.sh" \
    && bash /tmp/Miniforge3-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniforge3-Linux-x86_64.sh
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update -y && apt-get install -y wget curl git tar bzip2 unzip && rm -rf /var/lib/apt/lists/*

RUN pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu117 && \
    git clone https://github.com/gcorso/DiffDock.git && \
    cd DiffDock/  && \
    sed -i -e 's/\[esmfold\]//g' requirements.txt && \
    pip install -r requirements.txt && \
    pip install pyyaml==6.0.1

# Download pre-trained DiffDock and ESM models. Ignore python script error. 
# https://stackoverflow.com/questions/30716937/dockerfile-build-possible-to-ignore-error
RUN cd /DiffDock && \
    python -m inference ; exit 0

WORKDIR /DiffDock