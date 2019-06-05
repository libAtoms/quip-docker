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

## Custom compilation of OpenBLAS with OpenMP enabled
## (linear algebra is limited to single core in debs)
## NUM_THREADS must be set otherwise docker hub build
## non-parallel version.
#RUN git clone https://github.com/xianyi/OpenBLAS.git /tmp/OpenBLAS \
#    && cd /tmp/OpenBLAS/ \
#    && make NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 > /dev/null \
#    && make NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 install > /dev/null \
#    && rm -rf /tmp/OpenBLAS
#
## Make OpenBLAS the default
#RUN update-alternatives --install /usr/lib/libblas.so libblas.so /opt/OpenBLAS/lib/libopenblas.so 1000
#RUN update-alternatives --install /usr/lib/libblas.so.3 libblas.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000
#RUN update-alternatives --install /usr/lib/liblapack.so liblapack.so /opt/OpenBLAS/lib/libopenblas.so 1000
#RUN update-alternatives --install /usr/lib/liblapack.so.3 liblapack.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000
#RUN ldconfig



RUN conda init

#################################################################################
## Python 2.x environment
#################################################################################
# Misssing package: imolecule

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

USER root

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.1.0

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "80cfd013e526b5145ec3254920afd89bb459f1db7a2a3f21849125af20c05471 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    fix-permissions $JULIA_PKGDIR

USER $NB_UID

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'import Pkg; Pkg.update()' && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') && \
    julia -e "using Pkg; pkg\"add Gadfly RDatasets IJulia InstantiateFromURL\"; pkg\"precompile\"" && \
    # move kernelspec out of home \
    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local && \
    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter


####################
### Julia v1.1.x  ##
####################
#
## Use Python 2.7 with Julia
#ENV PYTHON /usr/local/bin/python
#
## specify paths for Julia 1.1
#ENV JULIA1_PATH /opt/julia/v1.1.0
## PKG_DIR is now replaced with DEPOT_PATH
#ENV JULIA_DEPOT_PATH /opt/julia/share/site
#
#RUN mkdir -p ${JULIA1_PATH} \
#    && cd ${JULIA1_PATH} \
#    && curl --location "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" | tar xz --strip-components 1
#
## clone the JuLipAtoms environment and copy it into v1.1 to make it the
## default environment loaded at startup
#RUN mkdir -p ${JULIA_DEPOT_PATH}/environments \
#    && cd ${JULIA_DEPOT_PATH}/environments \
#    && git clone https://github.com/libAtoms/JuLibAtoms.git \
#    && mkdir v1.1  \
#    && cp ./JuLibAtoms/*.toml ./v1.1
#
## this should download and build all packages
#RUN ${JULIA1_PATH}/bin/julia -e 'using Pkg; Pkg.instantiate()'
#
## Add to path as current version
#ENV PATH $JULIA1_PATH/bin:$PATH
#
## Relevant for Both Julia Environments:
## Add kernelspecs to global Jupyter
#RUN mv /root/.local/share/jupyter/kernels/julia* /usr/local/share/jupyter/kernels/

#################################################################################
## Switch back to jovyan to avoid accidental container runs as root
#################################################################################

WORKDIR $HOME
USER $NB_UID
