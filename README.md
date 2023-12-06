# VapourSynth-Yuuno Docker

An OCI container for running VapourSynth with Yuuno (Jupyter integration) based on Arch Linux.

You can run it as a server and access Yuuno (JupyterLab) via the web. Make sure to not expose the port directly to the internet, as it has no authentication. In the example below, I use Traefik with traefik-forward-auth to add authentication to the container.

See [yuuno.encode.moe](https://yuuno.encode.moe/) for more information about Yuuno.

Alternatively, you can also use it to filter videos directly with VapourSynth from the container. This can be helpful to run VapourSynth anywhere without having to painfully install and setup your plugin environment.

You can set the environment variable `$STARTUP_SCRIPT` to the path of a script that will be executed on startup. This can be used to install additional packages (you can install from the AUR with paru) or setup your environment. If the additional packages you need are generally useful for filtering/encoding, consider creating an issue or a pull request to add them to the container.

---

docker-compose.yml:

```yml
version: "3.9"

services:
  vapoursynth-yuuno:
    image: ghcr.io/nalsai/vapoursynth-yuuno
    container_name: vapoursynth-yuuno
    restart: unless-stopped
    volumes:
      - ./yuuno:/yuuno
      - /mnt/data/media:/media
    ports:
      - 8888:8888
    tty: true
    ulimits:         # without ulimits fakeroot takes forever on my fedora docker host
      nproc: 65535
      nofile:
        soft: 26677
        hard: 46677
    #cpus: 1.8       # limit max cpu usage
    cpu_shares: 256  # lower cpu priority (default shares: 1024)
    devices:
      - /dev/kfd:/dev/kfd
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.yuuno.rule=Host(`vs.example.com`)"
      - "traefik.http.routers.yuuno.entrypoints=websecure"
      - "traefik.http.routers.yuuno.tls.certresolver=letsencrypt"
      - "traefik.http.routers.yuuno.middlewares=traefik-forward-auth"

networks:
  traefik:
    external: true
```

---

If you want to make a script to (batch) filter and encode videos with VapourSynth, you can use this example:

encode.sh:

```bash
#!/bin/bash

if ps -eZ | grep container_t; then
    echo "I'm inside the matrix!";
    echo "Time to filter and encode"
    mkdir -p out
    for f in *.mp4; do
      vspipe filter.vpy - -c y4m --arg clip=$f | ffmpeg -i - -pix_fmt yuv420p10le -c:v libx265 -crf 20 -preset slow "out/${f%.*}.mkv"
      #vspipe filter.vpy - -c y4m --arg clip=$f | ffmpeg -i - -i $f -map 0 -map 1:a -pix_fmt yuv420p10le -c:v libx265Z -crf 20 -preset slow -c:a libopus -b:a 128k "out/${f%.*}.mkv"  # add audio from the original file
    done
else
    echo "I'm living in real world!";
    echo "Time to enter the matrix"
    podman run --user 0 --rm -it -v "$(pwd)":/yuuno:z --entrypoint=./encode.sh ghcr.io/nalsai/vapoursynth-yuuno:sha-ecb25f9
fi
```

Podman needs user 0, as it gets mapped to the host user and other users can't create files in the mounted volume. If you use docker, you can just replace `podman` with `docker` and remove the `--user 0` part.

Copy your filter script to `filter.vpy` with the variable `clip` as the source (don't forget to `import vapoursynth as vs` in the first line) and your videos to the same folder as the script. Then run `./encode.sh` and it will start podman and then start encoding all videos in the folder.
