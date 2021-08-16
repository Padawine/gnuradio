#!/bin/bash
xhost +
docker run -it --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --privileged --device=/dev/snd:/dev/snd -e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
 -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native --group-add $(getent group audio | cut -d: -f3) -v ~/.config/pulse/cookie:/root/.config/pulse/cookie   -v /data:/data -v /dev:/dev john4gun/gnuradio
