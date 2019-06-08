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
    # Useful tools
    curl \
    vim \
    emacs-nox \
    less \
    xterm \
    bsdmainutils \
    man-db \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
USER $NB_USER

#################################################################################
## Python 2.x environment
#################################################################################
# Misssing package: imolecule

RUN conda init

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
    pyamg \
    sphinx \
    spglib \
    RISE \
    pandas \
 && conda activate python2 \
 && conda remove --quiet --yes --force qt pyqt \
 && conda clean -tipsy \
 && fix-permissions $CONDA_DIR \
 && fix-permissions /home/$NB_USER

WORKDIR /otp/matscipy
COPY matscipy .

# Fixing permission
USER root
RUN chown -R $NB_USER:$NB_GID $PWD
USER $NB_USER

RUN . $CONDA_DIR/etc/profile.d/conda.sh \
 && conda activate python2 \
 && pip install --no-cache-dir .

WORKDIR $HOME

# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.
USER root
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install \
 && $CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json
USER $NB_USER

#################################################################################
## Julia 1.1.x environment
#################################################################################
# https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile

# install Julia packages in /opt/julia instead of $HOME
# PKG_DIR is now replaced with DEPOT_PATH
# PyCall: use Python 2.7 with Julia
ENV JULIA_PATH /opt/julia-1.1.0
ENV JULIA_DEPOT_PATH=/opt/julia
ENV PYTHON=${CONDA_DIR}/envs/python2/bin/python

USER root

RUN mkdir ${JULIA_PATH} \
 && cd ${JULIA_PATH} \
 && curl --location "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" | tar xz --strip-components 1 \
 && chown -R $NB_USER ${JULIA_PATH} \
 && ln -fs ${JULIA_PATH}/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
# Create JULIA_PKGDIR \
RUN mkdir /etc/julia \
 && echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/envs/python2/lib\")" >> /etc/julia/juliarc.jl \
 && mkdir $JULIA_DEPOT_PATH \
 && chown $NB_USER $JULIA_DEPOT_PATH \
 && fix-permissions $JULIA_DEPOT_PATH

USER $NB_UID

ADD --chown=1000 JuLibAtoms/*.toml ${JULIA_DEPOT_PATH}/environments/v1.1/
ADD --chown=1000 JuLibAtoms/*.toml ${JULIA_DEPOT_PATH}/environments/JuLibAtoms/

# Add Julia packages. This should download and build all packages.
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'using Pkg; Pkg.instantiate(); Pkg.API.precompile()' \
 && mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ \
 && chmod -R go+rx $CONDA_DIR/share/jupyter \
 && rm -rf $HOME/.local \
 && fix-permissions $JULIA_DEPOT_PATH $CONDA_DIR/share/jupyter

#################################################################################
## Switch back to jovyan to avoid accidental container runs as root
#################################################################################

WORKDIR $HOME
USER $NB_UID
