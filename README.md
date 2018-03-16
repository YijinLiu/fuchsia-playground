# Have fun with Google Fuchsia OS
===============================

## Build the docker image
<pre>
$ cd build
$ make
</pre>

## Run the docker container
<pre>
$ docker run -it --user=${USER} --workdir=/home/${USER} --name fuchsia-${USER} ${USER}/fuchsia:`date '+%Y-%m-%d'`
</pre>

## Run Fuchsia in QEMU
Inside docker container:
<pre>
$ cd build/fuchsia
$ .jiri_root/bin/fx run
</pre>
