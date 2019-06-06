# Base Python image has most up to date Python parts
# Debian derived
FROM python:2
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

######################
## Root environment ##
######################

RUN cp /etc/skel/.bash* /etc/skel/.profile /root/ \
 && echo "PS1='docker:\W$ '" >> /root/.bashrc

###################
## OS level deps ##
###################

# Build tools and deps for QUIP
# Followed by some useful utilities
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
        curl \
        # using libzmq3-dev instead of libzmq3, this one works
        libzmq3-dev \
        # Useful tools
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
        # target for the future
        python3 \
        python3-dev \
        python3-setuptools\
        python3-numpy\
        python3-scipy\
        python3-matplotlib

# Custom compilation of OpenBLAS with OpenMP enabled
# (linear algebra is limited to single core in debs)
# NUM_THREADS must be set otherwise docker hub build
# non-parallel version.
RUN git clone https://github.com/xianyi/OpenBLAS.git /tmp/OpenBLAS \
 && cd /tmp/OpenBLAS/ \
 && make DYNAMIC_ARCH=1 NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 \
 && make DYNAMIC_ARCH=1 NO_AFFINITY=1 USE_OPENMP=1 NUM_THREADS=32 install \
 && rm -rf /tmp/OpenBLAS

# Make OpenBLAS the default
RUN update-alternatives --install /usr/lib/libblas.so libblas.so /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && update-alternatives --install /usr/lib/libblas.so.3 libblas.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && update-alternatives --install /usr/lib/liblapack.so liblapack.so /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && update-alternatives --install /usr/lib/liblapack.so.3 liblapack.so.3 /opt/OpenBLAS/lib/libopenblas.so 1000 \
 && ldconfig

############
## Python ##
############

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
        spglib \
        nglview \
        RISE \
        pandas \
        ase

# Slightly older, non dev version of GPAW
RUN cd /opt \
 && wget https://files.pythonhosted.org/packages/source/g/gpaw/gpaw-1.4.0.tar.gz -O - | tar xz \
 && cd gpaw-1.4.0 \
 && pip install --no-cache-dir .

# Keep the source for examples
RUN git clone https://github.com/libAtoms/matscipy.git /opt/matscipy \
 && cd /opt/matscipy \
 && pip install --no-cache-dir .

RUN pip install --global-option=build_ext --global-option="-L/opt/OpenBLAS/lib" atomistica

RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension \
 && jupyter nbextension enable --py --sys-prefix nglview \
 && jupyter-nbextension install rise --py --sys-prefix \
 && jupyter-nbextension enable rise --py --sys-prefix

##############
## Python 3 ##
##############

# Put Python 3 packages in a virtualenv
# include `py3` command as a quick alias
# to activate
ENV PY3_PATH /opt/python3/
ENV PIP3 ${PY3_PATH}/bin/pip
ENV PYTHON3 ${PY3_PATH}/bin/python

RUN virtualenv -p python3 ${PY3_PATH} \
 && echo "alias py3='source ${PY3_PATH}/bin/activate'" >> /etc/bash.bashrc

RUN ${PIP3} install --upgrade pip \
 && ${PIP3} install --no-cache-dir \
        jupyter \
        numpy \
        scipy \
        matplotlib \
        ase \
        pyamg \
        imolecule \
        sphinx \
        spglib \
        nglview \
 && ${PIP3} install --no-cache-dir gpaw \
 && ${PIP3} install git+https://github.com/libAtoms/matscipy.git \
 && ${PIP3} install --global-option=build_ext --global-option="-L/opt/OpenBLAS/lib" atomistica \
 && ${PY3_PATH}/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension \
 && ${PY3_PATH}/bin/jupyter nbextension enable --py --sys-prefix nglview

# Add kernel to main Jupyter
# POSIX echo does not take -e already works with newlines
RUN ln -s ${PY3_PATH}/share/jupyter/kernels/python3 /usr/local/share/jupyter/kernels/ \
 && echo '{\n "argv": [\n  "'${PYTHON3}'",\n  "-m",\n  "ipykernel_launcher",\n  "-f",\n  "{connection_file}"\n ],\n "display_name": "Python 3",\n "language": "python"\n}' > /usr/local/share/jupyter/kernels/python3/kernel.json

###################
### Julia v0.6.4 ##
###################
#
## Use Python 2.7 with Julia
#ENV PYTHON /usr/local/bin/python
#
## List of Julia packages to install
#ARG JULIA_PACKAGES="PyCall IJulia PyPlot ODE Plots Interact JuLIP ASE"
#
## Set JULIA_PKGDIR to install packages globally
#ENV JULIA_PKGDIR /opt/julia/share/site
#ENV JULIA_PATH /opt/julia/v0.6
#ENV JULIA_VERSION 0.6.4
#
## Don't store the intermediate file, pipe into tar
#RUN mkdir -p $JULIA_PATH \
#    && cd $JULIA_PATH \
#    && curl --location "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%[.-]*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" > tmp.tgz \
# && file tmp.tgz \
# && ls -l tmp.tgz \
# && tar xzf tmp.tgz --strip-components 1
#
## umask ensures directories are writeable for non-root user
#RUN umask 0000 \
#    && ${JULIA_PATH}/bin/julia -e 'Pkg.init()' \
#    && echo "${JULIA_PACKAGES}" | sed 's/\s\+/\n/g' > $JULIA_PKGDIR/v${JULIA_VERSION%[.-]*}/REQUIRE \
#    && ${JULIA_PATH}/bin/julia -e 'Pkg.resolve()' \
#    # pre-compilation of installed packages
#    && ${JULIA_PATH}/bin/julia -e 'for pkg in keys(Pkg.installed()); try pkgsym = Symbol(pkg); eval(:(using $pkgsym)); catch; end; end' \
#    && chmod -R a+rw ${JULIA_PKGDIR}/lib
#
## Use Python 2.7 with Julia
#ENV PYTHON /usr/local/bin/python
#RUN ${JULIA_PATH}/bin/julia -e 'Pkg.build("PyCall")'
#
## create a symlink to be able to call Julia v0.6.4
#RUN ln -s /opt/julia/v0.6/bin/julia /usr/local/bin/julia6
#
## # Add to path as current version
## ENV PATH $JULIA_PATH/bin:$PATH

###################
## Julia v1.1.x  ##
###################

# specify paths for Julia 1.1
ENV JULIA1_PATH /opt/julia/v1.1.0
# PKG_DIR is now replaced with DEPOT_PATH 
ENV JULIA_DEPOT_PATH /opt/julia/share/site

RUN mkdir -p ${JULIA1_PATH} \
 && cd ${JULIA1_PATH} \
 && curl --location "https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz" | tar xz --strip-components 1

# clone the JuLipAtoms environment and copy it into v1.1 to make it the 
# default environment loaded at startup
RUN mkdir -p ${JULIA_DEPOT_PATH}/environments \
 && cd ${JULIA_DEPOT_PATH}/environments \
 && git clone https://github.com/libAtoms/JuLibAtoms.git \
 && mkdir v1.1  \
 && cp ./JuLibAtoms/*.toml ./v1.1 \
 # this should download and build all packages
 && ${JULIA1_PATH}/bin/julia -e 'using Pkg; Pkg.instantiate()'

# Add to path as current version
ENV PATH $JULIA1_PATH/bin:$PATH

# Relevant for Both Julia Environments:
# Add kernelspecs to global Jupyter
RUN mv /root/.local/share/jupyter/kernels/julia* /usr/local/share/jupyter/kernels/


###########
### DATA ##
###########
#
## Published GAPs
## Remote URLs do not get decompressed so pipe through tar
#
#ENV POTENTIALS_DIR /opt/share/potentials
#
#RUN wget -nv -O- "http://www.libatoms.org/pub/Home/TungstenGAP/GAP_6.tbz2" \
#    | tar xj -P --transform "s,^,${POTENTIALS_DIR}/GAP/Tungsten/,"
#RUN wget -nv -O- "http://www.libatoms.org/pub/Home/IronGAP/gp33b.tar.gz" \
#    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/Iron/,"
#RUN wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/gap_dft_corrections_water.tgz" \
#    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/Water/,"
#RUN wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/gap_dft_corrections_ch4_h2o.tgz" \
#    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/WaterCH4/,"
#RUN wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/gap_dft_1_2_body_LiH2O.tgz" \
#    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/WaterLiH2O/,"
#RUN wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/aC_GAP.tar.gz" \
#    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/Carbon/,"
#
##ADD Files/GAPPotentials.md ${POTENTIALS_DIR}/
#
## GPAW data
## Ensure we don't run interactively
#ENV GPAW_SETUP_VERSION 0.9.20000
#RUN mkdir -p /opt/share/gpaw
#RUN wget https://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-0.9.20000.tar.gz -O - | tar -xz  -C /opt/share/gpaw/
#ENV GPAW_SETUP_PATH /opt/share/gpaw/gpaw-setups-${GPAW_SETUP_VERSION}
#
###############
### Software ##
###############
#
## Add big software packages into the Software subdirectory
#
#
## Use these to run jupyter from this base notebook for testing
## CMD jupyter notebook --ip=$(hostname -i) --port=8899 --allow-root
## EXPOSE 8899

## AmberTools (no Amber)
#
#ENV AMBERHOME /opt/amber16/
#
## Never write the tests to disk (1GB) and remove src (500MB) after compilation
#
#RUN mkdir -p ${AMBERHOME} \
#    && cd ${AMBERHOME} \
#    && curl "http://ambermd.org/cgi-bin/AmberTools17-get.pl?Name=quipbot&Institution=NA&City=NA&State=NA&Country=NA&OS=linux-64" \
#        | tar xj --exclude='*/test/*' --strip-components 1 \
#    && ./update_amber --show-applied-patches \
#    && ./update_amber --update \
#    && ./update_amber --show-applied-patches \
#    && ./configure --with-python `which python` --python-install global -noX11 gnu \
#    && make install \
#    && ./configure --with-python `which python` --python-install global -noX11 -mpi gnu \
#    && make install \
#    && rm -rf ${AMBERHOME}/test ${AMBERHOME}/AmberTools
#
#ENV PATH ${AMBERHOME}/bin:${PATH}

