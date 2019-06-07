FROM libatomsquip/quip-gap-py2
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

#################################################################################
## Additional python packages
#################################################################################

# Slightly older, non dev version of GPAW

RUN cd /opt \
 && wget https://files.pythonhosted.org/packages/source/g/gpaw/gpaw-1.4.0.tar.gz -O - | tar xz \
 && cd gpaw-1.4.0 \
 && pip install --no-cache-dir .

RUN pip install --global-option=build_ext --global-option="-L/opt/OpenBLAS/lib" atomistica

# AtomEye needs to link with QUIP for xyz read-write

WORKDIR ${QUIP_ROOT}/src/AtomEye

ENV PATH ${QUIP_ROOT}/src/AtomEye/bin:${PATH}

RUN git clone --depth 1 https://github.com/jameskermode/AtomEye.git . \
 && make > /dev/null \
 && cd Python \
 && python setup.py install

#################################################################################
## Softwares
#################################################################################

# LAMMPS compilation

WORKDIR /opt/lammps

ENV LAMMPS_PATH /opt/lammps
ENV PATH ${LAMMPS_PATH}/src/:${PATH}

# Build LAMMPS from github - faster and more reliable than from the website
RUN git clone --branch stable --depth 1 https://github.com/lammps/lammps.git .

# Build `shlib` objects first so they have `-fPIC` then symlink the directory
# so they can be reused to build the binaries halving the compilation time.
# Clean up Obj files immedaitely to keep image smaller.
RUN cd src \
 && make yes-all \
 && make no-lib \
 && QUIP_ARCH=linux_x86_64_gfortran; make yes-user-quip \
 && make no-user-intel \
 && make yes-python \
 && make -j4 mpi mode=shlib \
 && make install-python \
 && ln -s Obj_shared_mpi Obj_mpi \
 && make -j4 mpi \
 && make clean-all


# AmberTools (no Amber)

WORKDIR /opt/amber16/

ENV AMBERHOME /opt/amber16/
ENV PATH ${AMBERHOME}/bin:${PATH}

# Never write the tests to disk (1GB) and remove src (500MB) after compilation
RUN curl "http://ambermd.org/cgi-bin/AmberTools17-get.pl?Name=quipbot&Institution=NA&City=NA&State=NA&Country=NA&OS=linux-64" \
    | tar xj --exclude='*/test/*' --strip-components 1 \
 && ./update_amber --show-applied-patches \
 && ./update_amber --update \
 && ./update_amber --show-applied-patches \
 && ./configure --with-python `which python` --python-install global -noX11 gnu \
 && make install > /dev/null \
 && ./configure --with-python `which python` --python-install global -noX11 -mpi gnu \
 && make install > /dev/null \
 && rm -rf ${AMBERHOME}/test ${AMBERHOME}/AmberTools


#################################################################################
## Data
#################################################################################

# Published GAPs

WORKDIR /opt/share/potentials

# Remote URLs do not get decompressed so pipe through tar
ENV POTENTIALS_DIR /opt/share/potentials

ADD files/GAPPotentials.md .

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


# GPAW data

WORKDIR /opt/share/gpaw

# Ensure we don't run interactively
ENV GPAW_SETUP_VERSION 0.9.20000
ENV GPAW_SETUP_PATH /opt/share/gpaw/gpaw-setups-${GPAW_SETUP_VERSION}

RUN wget https://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-0.9.20000.tar.gz -O - | tar -xz  -C .


#################################################################################
## Entrypoint
#################################################################################

WORKDIR /root/

# Public GAP image requires license agreement
# Replace bash with a license check script
RUN mkdir -p /bin/real/ \
 && mv /bin/bash /bin/real/bash

ADD files/fakebash /bin/bash

# Launch in the home directory of the user
ADD files/demo.ipynb .
