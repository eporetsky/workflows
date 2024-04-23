# docker build --rm -f Dockerfile -t ubuntu:DynamicBind .
# docker run --shm-size 8G --gpus all -it -v ${PWD}:/workspace/DynamicBind/input ubuntu:DynamicBind /bin/bash

FROM pytorch/pytorch:1.12.0-cuda11.3-cudnn8-devel

RUN apt-get update && \
    apt-get install -y git-core

RUN conda update -n base conda && \
    conda install -n base conda-libmamba-solver && \
    conda config --set solver libmamba && \
    conda init bash

RUN git clone https://github.com/luwei0917/DynamicBind.git && \
    cd DynamicBind && \
    conda env create -f environment.yml

RUN . /root/.bashrc && \
    /opt/conda/bin/conda init bash && \
    conda create --name relax python=3.8  && \
    conda activate relax && \
    conda install -c conda-forge openmm pdbfixer libstdcxx-ng openmmforcefields openff-toolkit ambertools compilers biopython


