# Base Python (debian) image
FROM python:3.7
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
ENV DEBIAN_FRONTEND noninteractive 
RUN dpkg-reconfigure dash

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
RUN git clone -b 'v0.3.9' --single-branch --depth 1 https://github.com/xianyi/OpenBLAS.git /tmp/OpenBLAS \
 && cd /tmp/OpenBLAS/ \
 && make NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 > /dev/null \
 && make NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 install > /dev/null \
 && rm -rf /tmp/OpenBLAS

# Make OpenBLAS the default
#RUN update-alternatives --install /usr/lib/libblas.so libblas.so /opt/OpenBLAS/lib/libopenblas.so 1000 \
# && update-alternatives --install /usr/lib/libblas.so.3 libblas.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000 \
# && update-alternatives --install /usr/lib/liblapack.so liblapack.so /opt/OpenBLAS/lib/libopenblas.so 1000 \
# && update-alternatives --install /usr/lib/liblapack.so.3 liblapack.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000 \
# && ldconfig




#################################################################################
## Python 3 environment
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
 && jupyter nbextension enable --py --sys-prefix widgetsnbextension \
 && jupyter nbextension enable --py --sys-prefix nglview \
 && jupyter-nbextension install rise --py --sys-prefix \
 && jupyter-nbextension enable rise --py --sys-prefix

# get latest version of ASE
RUN pip install git+https://gitlab.com/ase/ase


# Keep the source for examples
RUN git clone https://github.com/libAtoms/matscipy.git /opt/matscipy \
 && cd /opt/matscipy \
 && pip install --no-cache-dir .


#################################################################################
## Julia v1.4.x
#################################################################################

# specify paths for Julia 1.4
ENV JULIA_PATH /opt/julia/v1.4.1
# PKG_DIR is now replaced with DEPOT_PATH 
ENV JULIA_DEPOT_PATH /opt/julia/share/site
# Add to path as current version
ENV PATH ${JULIA_PATH}/bin:$PATH

RUN mkdir -p ${JULIA_PATH} \
 && cd ${JULIA_PATH} \
 && curl --location "https://julialang-s3.julialang.org/bin/linux/x64/1.4/julia-1.4.1-linux-x86_64.tar.gz" | tar xz --strip-components 1

###########################################################################################
# OpenBLAS for Julia, so that we get around the 'illegal instruction' bug in openBLAS 0.3.5
RUN mkdir /tmp/blas && \
    curl -L -o /tmp/blas/blas.tar.gz "https://github.com/JuliaBinaryWrappers/OpenBLAS_jll.jl/releases/download/OpenBLAS-v0.3.9+2/OpenBLAS.v0.3.9.x86_64-linux-gnu-libgfortran4.tar.gz" && \
    tar -C /tmp/blas -xzf /tmp/blas/blas.tar.gz && \
    cp /tmp/blas/lib/libopenblas* ${JULIA_PATH}/lib/julia/ && \
    rm -r /tmp/blas

# clone the JuLipAtoms environment and copy it into v1.4 to make it the 
# default environment loaded at startup
RUN mkdir -p ${JULIA_DEPOT_PATH}/environments \
 && cd ${JULIA_DEPOT_PATH}/environments \
 && git clone --depth 1 https://github.com/libAtoms/JuLibAtoms.git \
 && mkdir v1.4  \
 && cp ./JuLibAtoms/*.toml ./v1.4 \
 # this should download and build all packages
 && ${JULIA_PATH}/bin/julia -e 'using Pkg; Pkg.instantiate(); Pkg.API.precompile()'

# Relevant for Both Julia Environments:
# Add kernelspecs to global Jupyter
RUN mv /root/.local/share/jupyter/kernels/julia* /usr/local/share/jupyter/kernels/

CMD bash
