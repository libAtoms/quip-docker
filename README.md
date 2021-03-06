QUIP - QUantum mechanics and Interatomic Potentials
===================================================

Docker image for getting you up and running quickly with QUIP!

The QUIP package is a collection of software tools to carry out
molecular dynamics simulations. It implements a variety of
interatomic potentials and tight binding quantum mechanics, and
is also able to call external packages, and serve as plugins to
other software such as LAMMPS, CP2K and also the python framework
ASE. Various hybrid combinations are also supported in the style
of QM/MM, with a particular focus on materials systems such as
metals and semiconductors.

 - [Source for this image](https://github.com/libAtoms/QUIP/tree/public/docker)
 - [``QUIP`` and ``quippy`` documentation](http://libatoms.github.io/QUIP/)
 - [``QUIP`` source repository](https://github.com/libAtoms/QUIP)
 - https://www.libatoms.org
 - [``libAtoms/QUIP`` on Singularity](https://singularity-hub.org/collections/346/)

Docker
------

 The [libatomsquip/quip](https://hub.docker.com/r/libatomsquip/quip/) image
   ([alternative](https://store.docker.com/community/images/libatomsquip/quip))
   includes the base scientific stack and applications along with QUIP and
   quippy compiled with GAP support. Use of this image is restricted by a
   non-commercial licence agreement. The license terms are in the [GAP repo](https://github.com/libAtoms/GAP).
   
 

The default command runs a Jupyter notebook server that can be used from
your browser. The images should download automatically when you ``docker run``
but you will need to log in if you have access to the private image.
A typical launch command might look like:

```
docker run -it -p 8899:8899 -v ~/Work/DockerHome:/root/ libatomsquip/quip
```

 - ``docker run`` runs a docker container. These are often ephemeral so unless
   you will be making permanent changes to the OS you can add ``--rm`` to
   remove the container when it is finished.
 - ``-it`` makes sure that the running container is accessible from a terminal
   and can interact with it.
 - ``-p 8899:8899`` the Jupyter notebook is set to run on port 8899, this
   allows access to that port from outside the container. Access the notebook
   at http://localhost:8899/ in your browser. **Note:** by default this
   port will be exposed to all hosts, so if your machine in on a public IP
   address take care; you may wish to use e.g. ``-p 127.0.0.1:8899:8899``
   to restrict to local connections.
 - ``-v ~/Work/DockerHome:/root/`` makes the ``Work/DockerHome`` folder in
   your home directory become the ``$HOME`` directory of the docker user
   (root). This is the best way to make data available inside the container,
   and **any changes that you want to keep after the container stops must be
   made in a mounted volume!**

This command will start the jupyter notebook server. One useful workflow is to
stop this first container, and then restart it with ``docker container start IMAGE``, 
after which shells can be opened into it with ``docker exec -it IMAGE bash``.  

You can get a list of available containers and their labels (even stopped ones) 
by typing ``docker container ls -a``. The hexademical labels can be replaced 
with the friendly names provided by docker, or even renamed to your own, 
e.g. ``docker container rename IMAGE quip`` after which you can refer to 
the container by use the ``quip`` label. 

If you'd prefer to use a shell in the image right away, just add ``bash`` to the very end
of the first run command. 

Any any case, the first time you run a shell, you will be asked to agree to a license agreement 
(basically non-commercial use), by typing your email. 

Tips
----

 - All programs will be added to the ``PATH``, so commands like ``quip`` for
   QUIP and ``lmp_mpi`` for lammps work out-of the box.

 - Mount a volume as ``/root/`` and use it to store customisations like
   ``.bashrc`` and keep your frequently used scripts and compiled programs.
   (default user is ``root``, but this may change in future)

 - By mounting a volume as the home directory, you will only need to accept the
   GAP license the first time you create a container, not for every new one
   that starts.

Graphical Applications
----------------------

There is no native support for a GUI in Docker, however X11 applications can
be forwarded to the host machine with a few commandline options. Be aware that
this also exposes the host Xserver to the container which may be considered
a security risk.

```
docker run --rm -it -e DISPLAY -v $HOME/.Xauthority:/root/.Xauthority --net=host --ipc=host --pid=host -p 8899:8899 libatomsquip/quip bash 
```


Stack
-----

Images contain a full scientific stack that includes compilers, Python 3
and Julia [base image](https://github.com/libAtoms/docker-quip-base).
This image adds:

 - QUIP with OpenMP parallelisation
 - QUIP programs compiled with MPI support (e.g. ``quip_mpi``)
 - quippy - Python wrapper for QUIP (including AtomEye)
 - LAMMPS (MPI version) with QUIP integration and Python bindings


Python 2
--------

The docker has now switched over the version 3 of python as of August 2019, when
``quippy`` became fully Python 3 compatible. You can check out the last version
of the docker based on Python 2 by using the ``py2`` tag. That version is fixed 
and will not be updated. 

Building the image yourself
---------------------------

The ``Dockerfile`` file pulls in the QUIP source code from GitHub so it
is fine to build that in place ``docker build . -t your_tag_here``. Any
changes that you make to the QUIP code will not be included in the image.

To modify QUIP in your image, or build your own image that includes GAP,
copy ``Dockerfile.gap`` to the root directory of QUIP as ``Dockerfile``
and build from there. That build copies the contents of your own QUIP
directory. You can customise your build by editing the file 
``docker/arch/ALL_Makefile.linux_x86_64_gfortran.inc`` or adding your own
``Makefile.in`` into ``arch`` and changing the value of ``BUILD`` in the
Dockerfile so it will build using your own customisations.


Singularity
-----------

[Singularity](http://singularity.lbl.gov) is a container ecosystem targeting
scientific workflows on HPC. You can convert the QUIP Docker images to
Singularity (SingularityHub no longer kept updated).

