# Base Python (debian) image
FROM python
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

# simple utilities
RUN apt-get -y update \
 && apt-get upgrade -y \
 && apt-get install -y \
#        python-rdkit \
        # Useful tools
        pandoc \
        curl \
        vim \
        emacs-nox \
        less \
        bsdmainutils \
        man-db \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# Put any Python libraries here
RUN pip install --upgrade pip \
 && pip install --no-cache-dir \
        jupyter \
        numpy \
        scipy \
        scikit-learn\
#        scikit-build\
        matplotlib \
        pyamg \
        imolecule \
#        sphinx \
#        sphinx-rtd-theme \
        nbsphinx \
        numpydoc \
        spglib \
        nglview \
        RISE \
        pandas \
        phonopy \
#        torch\
#        torchani\
        click \
        # quippy & gap_fit from PyPI
        quippy-ase \
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
## Entrypoint
#################################################################################

WORKDIR /root/

# Set bash instead of sh as defualt terminal in Jupyter
ENV SHELL /bin/bash

CMD bash -c exit && jupyter notebook --ip=$(hostname -i) --port=8899 --allow-root
EXPOSE 8899
