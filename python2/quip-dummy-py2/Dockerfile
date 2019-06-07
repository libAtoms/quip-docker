# Base Python (debian) image
FROM python:2
LABEL maintainer="Gabor Csanyi <gc121@cam.ac.uk>"

#################################################################################
## Root environment
#################################################################################

RUN cp /etc/skel/.bash* /etc/skel/.profile /root/ \
 && echo "PS1='docker:\W$ '" >> /root/.bashrc
