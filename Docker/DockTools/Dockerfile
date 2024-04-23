FROM mambaorg/micromamba:jammy
LABEL maintainer="externelly"

ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN micromamba install -y conda-forge::prody conda-forge::openbabel && \
    pip install -U pandas numpy matplotlib seaborn biopython