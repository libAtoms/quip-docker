# quip-docker

## Docker Stack

- base: jupyter/minimal + apt packages + python2 + julia
- minimal: QUIP + GAP
- all: potentials + lammps + ambertool + AtomEye 

## Building your own docker image
0. Cloning the repository:
   ```bash
   git clone --recursive https://github.com/libAtoms/quip-docker.git
   ```
   or
   ```bash
   git clone https://github.com/libAtoms/quip-docker.git
   git submodule update --init --recursive
   ```
   
### Building base image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-base-jpy2:latest jupyter-py2/quip-base
   ```

### Building minimal image
1. Determine the proper version of QUIP and GAP:
   ```bash
   ./jupyter-py2/quip-gap/QUIP/bin/gitversion > jupyter-py2/quip-gap/GIT_VERSION
   ./jupyter-py2/quip-gap/QUIP/bin/gapversion > jupyter-py2/quip-gap/GAP_VERSION
   ```
2. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-gap-jpy2:latest jupyter-py2/quip-gap
   ```

## Using the docker image
1. Create a container:
   ```bash
   docker run \
   -p 8888:8888 \
   -v $PWD:/home/jovyan/work \
   --name quip \
   libatomsquip/minimal:latest 
   ```

   More information about the command line options: 
   https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html

### For development:

- To have passwordless sudo access in the container use the following command:
    
   ```bash
   docker exec -it --user root quip start.sh
   ```





