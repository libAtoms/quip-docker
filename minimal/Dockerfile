FROM libatomsquip/base:latest
LABEL maintainer="Tamas K. Stenczel <tks32@cam.ac.uk>"

#################################################################################
##  Python 3 dependencies 
#################################################################################
# this might be better off in the base Dokcerfile

RUN  ${CONDA_DIR}/bin/conda install numpy matplotlib ase

#################################################################################
##  QUIP + GAP + quippy
#################################################################################

# All the QUIPs go here; added to path in the end.
WORKDIR /opt/quip

# QUIP for general use is the OpenMP version.
ENV QUIP_ARCH linux_x86_64_gfortran
#ENV QUIP_ARCH linux_x86_64_gfortran_openmp

#ENV QUIP_INSTALLDIR /opt/quip/bin
#ENV PATH $QUIP_INSTALLDIR:$PATH

# Install f90wrap -- from the submodule to get the exact version
RUN git clone https://github.com/jameskermode/f90wrap.git /opt/f90wrap --branch=py3 --depth=1 \
    && cd /opt/f90wrap \
    && python setup.py install

# copy the files and folders needed 
COPY QUIP .
COPY GAP src/GAP
COPY Makefile.inc build/$QUIP_ARCH/
COPY GIT_VERSION .
COPY GAP_VERSION src/GAP/

# Fixing permission
USER root
RUN chown -R $NB_USER:$NB_GID $PWD
USER $NB_USER

# Installs with no suffix, e.g. quip
RUN make quippy 

## Installs quippy using python2 environment
#RUN . $CONDA_DIR/etc/profile.d/conda.sh \
# && conda activate python2 \
# && make quippy > /dev/null 2>&1 \
# && make install-quippy > /dev/null 2>&1

#################################################################################
## Switch back to jovyan to avoid accidental container runs as root
#################################################################################

WORKDIR $HOME
USER $NB_UID
