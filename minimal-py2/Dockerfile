# Base Python image has most up to date Python parts
FROM libatomsquip/base-py2
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

# All the QUIPs go here; added to path in the end.
ENV QUIP_ROOT /opt/quip
ENV QUIP_INSTALLDIR=${QUIP_ROOT}/bin
ENV PATH ${QUIP_INSTALLDIR}:${PATH}

ENV QUIP_ARCH linux_x86_64_gfortran_openmp
ENV BUILD GAP

WORKDIR ${QUIP_ROOT}

# To build within the image without additonal libraries use
# the git+VANILLA version
RUN git clone --depth 1 https://github.com/libAtoms/QUIP.git ${QUIP_ROOT}

#ADD . ${QUIP_ROOT}
ADD arch/${BUILD}_Makefile.${QUIP_ARCH}.inc build/${QUIP_ARCH}/Makefile.inc

RUN make > /dev/null \
 && make install \
 && make install-quippy > /dev/null

# Launch in the home directory of the user
WORKDIR /root/
ADD files/demo.ipynb /root/

# Public GAP image requires license agreement
# Replace bash with a license check script
RUN mkdir -p /bin/real/ \
 && mv /bin/bash /bin/real/bash

ADD docker/files/fakebash /bin/bash

CMD bash -c exit && jupyter notebook --ip=$(hostname -i) --port=8899 --allow-root
EXPOSE 8899
