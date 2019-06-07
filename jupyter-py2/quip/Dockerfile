FROM libatomsquip/minimal:latest
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

#################################################################################
## OS level deps
#################################################################################

USER root
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    # Useful tools
    curl \
    vim \
    emacs-nox \
    less \
    xterm \
    bsdmainutils \
    man-db \
    # AtomEye
    libxpm-dev \
    libgsl0-dev \
    # amber
    csh \
    flex \
    # gpaw
    libxc-dev \
	# using libzmq3-dev instead of libzmq3, this one works
    libzmq3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
USER $NB_USER

#################################################################################
## Python
#################################################################################

# Put any Python libraries here
RUN pip install --upgrade pip
RUN pip install --no-cache-dir jupyter numpy scipy matplotlib pyamg \
                               imolecule sphinx spglib nglview RISE pandas ase

# Slightly older, non dev version of GPAW
RUN cd /opt && wget https://files.pythonhosted.org/packages/source/g/gpaw/gpaw-1.4.0.tar.gz -O - | tar xz && \
    cd gpaw-1.4.0 && pip install --no-cache-dir .

# Keep the source for examples
RUN git clone --depth 1 https://github.com/libAtoms/matscipy.git /opt/matscipy \
 && cd /opt/matscipy \
 && pip install --no-cache-dir .
# && python setup.py install

RUN pip install --global-option=build_ext --global-option="-L/opt/OpenBLAS/lib" atomistica

# AmberTools (no Amber)
ENV AMBERHOME /opt/amber16
ENV PATH ${AMBERHOME}/bin:${PATH}

# Never write the tests to disk (1GB) and remove src (500MB) after compilation
RUN mkdir -p ${AMBERHOME} \
    && cd ${AMBERHOME} \
    && curl "http://ambermd.org/cgi-bin/AmberTools17-get.pl?Name=quipbot&Institution=NA&City=NA&State=NA&Country=NA&OS=linux-64" \
        | tar xj --exclude='*/test/*' --strip-components 1
RUN cd ${AMBERHOME} \
    && ./update_amber --show-applied-patches \
    && ./update_amber --update \
    && ./update_amber --show-applied-patches \
    && ./configure --with-python `which python` --python-install global -noX11 gnu
RUN cd ${AMBERHOME} \
    && make install \
RUN rm -rf ${AMBERHOME}/test ${AMBERHOME}/AmberTools
 #   && ./configure --with-python `which python` --python-install global -noX11 -mpi gnu \
 #  && make install \
#    && rm -rf ${AMBERHOME}/test ${AMBERHOME}/AmberTools


RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN jupyter nbextension enable --py --sys-prefix nglview
RUN jupyter-nbextension install rise --py --sys-prefix
RUN jupyter-nbextension enable rise --py --sys-prefix

#################################################################################
## DATA
#################################################################################


# Published GAPs
# Remote URLs do not get decompressed so pipe through tar

ENV POTENTIALS_DIR /opt/share/potentials

RUN wget -nv -O- "http://www.libatoms.org/pub/Home/TungstenGAP/GAP_6.tbz2" \
    | tar xj -P --transform "s,^,${POTENTIALS_DIR}/GAP/Tungsten/," \
 && wget -nv -O- "http://www.libatoms.org/pub/Home/IronGAP/gp33b.tar.gz" \
    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/Iron/," \
 && wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/gap_dft_corrections_water.tgz" \
    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/Water/," \
 && wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/gap_dft_corrections_ch4_h2o.tgz" \
    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/WaterCH4/," \
 && wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/gap_dft_1_2_body_LiH2O.tgz" \
    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/WaterLiH2O/," \
 && wget -nv -O- "http://www.libatoms.org/pub/Home/DataRepository/aC_GAP.tar.gz" \
    | tar xz -P --transform "s,^,${POTENTIALS_DIR}/GAP/Carbon/,"

#ADD Files/GAPPotentials.md ${POTENTIALS_DIR}/

# GPAW data
# Ensure we don't run interactively
ENV GPAW_SETUP_VERSION 0.9.20000
ENV GPAW_SETUP_PATH /opt/share/gpaw/gpaw-setups-${GPAW_SETUP_VERSION}

RUN mkdir -p /opt/share/gpaw \
 && wget https://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-0.9.20000.tar.gz -O - | tar -xz  -C /opt/share/gpaw/


#################################################################################
#################################################################################
#################################################################################

# All the QUIPs go here; added to path in the end.
ENV QUIP_ROOT /opt/quip

# To build within the image without additonal libraries use
# the git+VANILLA version
# RUN git clone https://github.com/libAtoms/QUIP.git ${QUIP_ROOT}
# ENV BUILD NOGAP
# ENV BUILD GAP
ENV BUILD ALL
ADD . ${QUIP_ROOT}

# LAMMPS compilation

# lammps should be linked with SERIAL version of QUIP
# other configurations are untested and too complicated
# for a user (mixed paralleisms).
ENV QUIP_ARCH linux_x86_64_gfortran
ENV LAMMPS_PATH /opt/lammps

# Build only libquip for serial to keep a slim image.
# Makefile.inc is also required to compile lammps.
RUN cd ${QUIP_ROOT} \
    && mkdir -p build/${QUIP_ARCH} \
    && cp docker/arch/${BUILD}_Makefile.${QUIP_ARCH}.inc build/${QUIP_ARCH}/Makefile.inc \
    && make libquip > /dev/null \
    && find build/${QUIP_ARCH} -type f ! \( -name 'libquip.a' -o -name 'Makefile.inc' \) -delete

# Build LAMMPS from github - faster and more reliable than from the website
RUN mkdir -p ${LAMMPS_PATH} \
    && git clone --branch stable --depth 1 https://github.com/lammps/lammps.git ${LAMMPS_PATH}

# Build `shlib` objects first so they have `-fPIC` then symlink the directory
# so they can be reused to build the binaries halving the compilation time.
# Clean up Obj files immedaitely to keep image smaller.
RUN cd ${LAMMPS_PATH}/src \
    && make yes-all \
    && make no-lib \
    && make yes-user-quip yes-python no-user-intel \
    && make mpi mode=shlib \
    && make install-python \
    && ln -s Obj_shared_mpi Obj_mpi \
    && make mpi \
    && make clean-all

ENV PATH ${LAMMPS_PATH}/src/:${PATH}


# MPI QUIP for parallel within QUIP
# Installs with _mpi suffix, e.g. quip_mpi
ENV QUIP_ARCH linux_x86_64_gfortran_openmpi

RUN cd ${QUIP_ROOT} \
    && mkdir -p build/${QUIP_ARCH} \
    && cp docker/arch/${BUILD}_Makefile.${QUIP_ARCH}.inc build/${QUIP_ARCH}/Makefile.inc \
    && make > /dev/null \
    && QUIP_INSTALLDIR=${QUIP_ROOT}/bin make install \
    && find build/${QUIP_ARCH} -type f ! \( -name 'libquip.a' -o -name 'Makefile.inc' \) -delete


# QUIP for general use is the OpenMP version.
# Installs with no suffix, e.g. quip
# Also installs quippy
# Keep all libraries for AtomEye
ENV QUIP_ARCH linux_x86_64_gfortran_openmp

RUN cd ${QUIP_ROOT} \
    && mkdir -p build/${QUIP_ARCH} \
    && cp docker/arch/${BUILD}_Makefile.${QUIP_ARCH}.inc build/${QUIP_ARCH}/Makefile.inc \
    && make > /dev/null \
    && QUIP_INSTALLDIR=${QUIP_ROOT}/bin make install \
    && make install-quippy > /dev/null \
    && find build/${QUIP_ARCH} -type f ! \( -name '*.a' -o -name 'Makefile.inc' \) -delete

# AtomEye needs to link with QUIP for xyz read-write
RUN git clone --depth 1 https://github.com/jameskermode/AtomEye.git ${QUIP_ROOT}/src/AtomEye \
    && cd ${QUIP_ROOT}/src/AtomEye \
    && make \
    && cd ${QUIP_ROOT}/src/AtomEye/Python \
    && python setup.py install

ENV PATH ${QUIP_ROOT}/bin:${QUIP_ROOT}/src/AtomEye/bin:${PATH}

# ENTRYPOINT ["/bin/bash", "-c"]

# Launch in the home directory of the user
WORKDIR /root/
ADD docker/files/demo.ipynb /root/

#################################################################################
## Switch back to jovyan to avoid accidental container runs as root
#################################################################################

WORKDIR $HOME
USER $NB_UID
