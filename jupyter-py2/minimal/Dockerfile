FROM libatomsquip/base:latest
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

#################################################################################
##  QUIP + GAP + quippy
#################################################################################

# All the QUIPs go here; added to path in the end.
WORKDIR /opt/quip

# QUIP for general use is the OpenMP version.
ENV QUIP_ARCH linux_x86_64_gfortran_openmp

ENV QUIP_INSTALLDIR /opt/quip/bin
ENV PATH $QUIP_INSTALLDIR:$PATH

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
RUN make > /dev/null 2>&1 \
 && make install > /dev/null 2>&1

# Installs quippy using python2 environment
RUN . $CONDA_DIR/etc/profile.d/conda.sh \
 && conda activate python2 \
 && make quippy \
 && make install-quippy

#################################################################################
## Switch back to jovyan to avoid accidental container runs as root
#################################################################################

WORKDIR $HOME
USER $NB_UID
