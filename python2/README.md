# quip-docker

Base on Python 2 image with root access.

## Docker Stack

- quip-base-py2: python:2 + linux packages + julia
- quip-gap-py2: QUIP + GAP
- quip-py2: potentials + AtomEye + lammps + ambertool 


## Building your own docker image
0. Cloning the repository:
   ```bash
   git clone --recursive https://github.com/fekad/project-water.git
   git submodule update --init --recursive
   ```
### Building base image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-base-py2:latest quip-base-py2
   ```

### Building minimal image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-minimal-py2:latest --build-arg GITHUB_TOKEN=... quip-minimal
   ```

### Building full image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-py2:latest quip-py2
   ```

## Using the docker image
1. Create a container:
   ```bash
   docker run \
   -p 8899:8899 \
   -v $PWD:/root \
   --name quip-py2 \
   libatomsquip/quip-py2:latest 
   ```




