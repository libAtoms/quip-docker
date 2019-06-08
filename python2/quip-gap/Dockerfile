FROM libatomsquip/quip-base-py2
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

# All the QUIPs go here; added to path in the end.
ENV QUIP_ROOT /opt/quip
ENV QUIP_INSTALLDIR ${QUIP_ROOT}/bin
ENV PATH ${QUIP_INSTALLDIR}:${PATH}

WORKDIR /opt/quip

RUN git clone --depth 1 --recursive https://github.com/libAtoms/QUIP.git .
ADD GAP src/GAP

#################################################################################
# Quip library for LAMMPS
#################################################################################

# lammps should be linked with SERIAL version of QUIP other configurations are
# untested and too complicated for a user (mixed paralleisms).
ENV QUIP_ARCH linux_x86_64_gfortran
ADD Makefile.inc build/${QUIP_ARCH}/Makefile.inc

# Build only libquip for serial to keep a slim image.
# Makefile.inc is also required to compile lammps.
RUN make libquip > /dev/null \
 && find build/${QUIP_ARCH} -type f ! \( -name 'libquip.a' -o -name 'Makefile.inc' \) -delete

#################################################################################
# Quip with OpenMP
#################################################################################

ENV QUIP_ARCH linux_x86_64_gfortran_openmp
ADD Makefile.inc build/${QUIP_ARCH}/Makefile.inc

RUN make > /dev/null \
 && make install \
 && make install-quippy > /dev/null


#################################################################################
## Entrypoint
#################################################################################

WORKDIR /root/

CMD bash -c exit && jupyter notebook --ip=$(hostname -i) --port=8899 --allow-root
EXPOSE 8899
