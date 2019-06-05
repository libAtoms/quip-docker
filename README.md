# quip-docker

## Docker Stack

- base: jupyter/minimal + apt packages + python2 + julia
- minimal: QUIP + GAP
- all: potentials + lammps + ambertool + AtomEye 


## Building your own docker image
0. Cloning the repository:
   ```bash
   git clone --recursive https://github.com/fekad/project-water.git
   git submodule update --init --recursive
   ```
### Building base image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/base:latest base
   ```

### Building minimal image
1. Determine the proper version of QUIP and GAP:
    ```bash
    ./minimal/QUIP/bin/gitversion > minimal/GIT_VERSION
    ./minimal/QUIP/bin/gapversion.sh > minimal/GAP_VERSION
    ```
2. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/minimal:latest minimal
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





