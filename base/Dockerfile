FROM jupyter/minimal-notebook:latest
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

#################################################################################
## OS level deps
#################################################################################

USER root
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    gfortran \
    libblas-dev \
    liblapack-dev \
    openmpi-bin \
    libopenmpi-dev \
    netcdf-bin \
    libnetcdf-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
USER $NB_USER

RUN conda init

#################################################################################
## Python 2.x environment
#################################################################################

RUN . $CONDA_DIR/etc/profile.d/conda.sh \
 && conda  create --name python2  --quiet  --yes \
    python=2.7 \
    ipython \
    ipykernel \
    kernda \
    numpy \
    scipy \
    scikit-learn \
    matplotlib \
    ase \
    nglview \
 && conda activate python2 \
 && conda remove --quiet --yes --force qt pyqt \
 && conda clean -tipsy \
 && fix-permissions $CONDA_DIR \
 && fix-permissions /home/$NB_USER

# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.
USER root
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install \
 && $CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json
USER $NB_USER

#################################################################################
## Switch back to jovyan to avoid accidental container runs as root
#################################################################################

WORKDIR $HOME
USER $NB_UID
