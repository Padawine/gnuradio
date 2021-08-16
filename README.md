# gnuradio 3.8.2.0

### Howto use

build.sh - build docker image:
```text
docker build -t john4gun/gnuradio .
```

run.sh - Run docker image with UI and audio support:
```shell
#!/bin/bash
xhost +
docker run -it --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --privileged --device=/dev/snd:/dev/snd -e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
 -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native --group-add $(getent group audio | cut -d: -f3) -v ~/.config/pulse/cookie:/root/.config/pulse/cookie   -v /data:/data -v /dev:/dev john4gun/gnuradio
```
