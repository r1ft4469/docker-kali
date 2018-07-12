# kali
A Docker image for various bits of Kali Linux

## Basic Usage
`docker run --rm -ti --net host pennoser/msf msf`

This will start `msfconsole` with a postgresql server, ready to rock. The
postgresql server has already been preloaded with the module cache, so lookups
should be fast.

## Advanced Usage

There's a number of other fun tools in here:

### zaproxy
`docker run --rm -it --net host -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix pennoser/msf zaproxy`

### armitage
`docker run --rm -it --net host -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix pennoser/msf armitage`

### good ol' bash
`docker run --rm -it --net host pennoser/msf`
