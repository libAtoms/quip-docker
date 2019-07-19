# Base Python (debian) image
FROM python:2
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

#################################################################################
## Root environment
#################################################################################

RUN cp /etc/skel/.bash* /etc/skel/.profile /root/ \
 && echo "PS1='docker:\W$ '" >> /root/.bashrc

#################################################################################
## OS level deps
#################################################################################

# Build tools and deps for QUIP. Followed by some useful utilities
RUN apt-get -y update \
 && apt-get upgrade -y \
 && apt-get install -y \
        gfortran \
        openmpi-bin \
        libopenmpi-dev \
        liblapack-dev \
        libblas-dev \
        libnetcdf-dev \
        netcdf-bin \
        # using libzmq3-dev instead of libzmq3, this one works
        libzmq3-dev \
        # Useful tools
        pandoc \
        curl \
        vim \
        emacs-nox \
        less \
        bsdmainutils \
        man-db \
        # AtomEye
        libxpm-dev \
        libgsl0-dev \
        xterm \
        # amber
        csh \
        flex \
        # gpaw
        libxc-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Custom compilation of OpenBLAS with OpenMP enabled (linear algebra is limited to single core in debs)
# NUM_THREADS must be set otherwise docker build non-parallel version.
RUN git clone --depth 1 https://github.com/xianyi/OpenBLAS.git /tmp/OpenBLAS \
 && cd /tmp/OpenBLAS/ \
 && make NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 > /dev/null \
 && make NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 install > /dev/null \
 && rm -rf /tmp/OpenBLAS

# Make OpenBLAS the default
RUN update-alternatives --install /usr/lib/libblas.so libblas.so /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && update-alternatives --install /usr/lib/libblas.so.3 libblas.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && update-alternatives --install /usr/lib/liblapack.so liblapack.so /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && update-alternatives --install /usr/lib/liblapack.so.3 liblapack.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && ldconfig

#################################################################################
## Python environment
#################################################################################

# Put any Python libraries here
RUN pip install --upgrade pip \
 && pip install --no-cache-dir \
        jupyter \
        numpy \
        scipy \
        matplotlib \
        pyamg \
        imolecule \
        sphinx \
        sphinx-rtd-theme \
        nbsphinx \
        numpydoc \
        spglib \
        nglview \
        RISE \
        pandas \
        ase==3.17.0 \
 && pip install --no-cache-dir 'nbconvert[execute]' 'ipython<6' \       
 && jupyter nbextension enable --py --sys-prefix widgetsnbextension \
 && jupyter nbextension enable --py --sys-prefix nglview \
 && jupyter-nbextension install rise --py --sys-prefix \
 && jupyter-nbextension enable rise --py --sys-prefix

# Keep the source for examples
RUN git clone https://github.com/libAtoms/matscipy.git /opt/matscipy \
 && cd /opt/matscipy \
 && pip install --no-cache-dir .

#################################################################################
## Julia v1.1.x
#################################################################################

# specify paths for Julia 1.1
ENV JULIA_PATH /opt/julia/v1.1.0
# PKG_DIR is now replaced with DEPOT_PATH 
ENV JULIA_DEPOT_PATH /opt/julia/share/site
# Add to path as current version
ENV PATH ${JULIA_PATH}/bin:$PATH
# Use Python 2.7 with Julia
ENV PYTHON /usr/local/bin/python

RUN mkdir -p ${JULIA_PATH} \
 && cd ${JULIA_PATH} \
 && curl --location "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" | tar xz --strip-components 1

# clone the JuLipAtoms environment and copy it into v1.1 to make it the 
# default environment loaded at startup
RUN mkdir -p ${JULIA_DEPOT_PATH}/environments \
 && cd ${JULIA_DEPOT_PATH}/environments \
 && git clone --depth 1 https://github.com/libAtoms/JuLibAtoms.git \
 && mkdir v1.1  \
 && cp ./JuLibAtoms/*.toml ./v1.1 \
 # this should download and build all packages
 && ${JULIA_PATH}/bin/julia -e 'using Pkg; Pkg.instantiate(); Pkg.API.precompile()'

# Relevant for Both Julia Environments:
# Add kernelspecs to global Jupyter
RUN mv /root/.local/share/jupyter/kernels/julia* /usr/local/share/jupyter/kernels/

