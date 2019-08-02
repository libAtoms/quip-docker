# quip-docker

Base on Python 3 image with root access.

## Docker Stack

- quip-base: python 3 + debian packages + julia
- quip-gap: QUIP + GAP
- quip: potentials + atomeye + lammps + ambertool 


## Building your own docker image
0. Cloning the repository:
   ```bash
   git clone https://github.com/libAtoms/quip-docker.git
   cd python3
   ```
### Building base image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-base-py3:latest quip-base
   ```

### Building minimal image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-gap-py3:latest --build-arg GITHUB_TOKEN=... quip-gap
   ```

### Building full image
1. Build the base image with the specific tags:
   ```bash
   docker build -t libatomsquip/quip-py3:latest quip
   ```

## Using the docker image
1. Create a container:
   ```bash
   docker run \
   -p 8899:8899 \
   -v $PWD:/root \
   --name quip-py3 \
   libatomsquip/quip-py3:latest 
   ```




