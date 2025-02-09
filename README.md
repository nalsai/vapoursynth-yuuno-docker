# VapourSynth-Yuuno Docker

An OCI container for running VapourSynth with Yuuno (Jupyter integration) based on Arch Linux.

You can run it as a server and access Yuuno (JupyterLab) via the web. Make sure to not expose the port directly to the internet, as it has no authentication. In the example below, I use Traefik with traefik-forward-auth to add authentication to the container.

See [yuuno.encode.moe](https://yuuno.encode.moe/) for more information about Yuuno.

Alternatively, you can also use it to filter videos directly with VapourSynth from the container. This can be helpful to run VapourSynth anywhere without having to painfully install and setup your plugin environment.

You can set the environment variable `$STARTUP_SCRIPT` to the path of a script, then it will get executed on startup. This can be used to install additional packages (you can install from the AUR with paru) or setup your environment. By default it is set to `/yuuno/startup.sh`.

## Included VapourSynth plugins

- vapoursynth
- 


## Usage of Yuuno

docker-compose.yml:

```yml
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
    cpu_shares: 512  # lower cpu priority (default shares: 1024)
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

## Usage of VapourSynth for scripting

If you want to make a script to (batch) filter and encode videos with VapourSynth, you can use this example:

encode.sh:

```bash
#!/bin/bash

if [ -f /run/.containerenv ]; then
    echo "Step 2: Filtering and Encoding"
    mkdir -p out
    for f in *.mkv; do
      vspipe filter.vpy - -c y4m --arg clip=$f | ffmpeg -i - -i "$f" \
          -hide_banner \
          -map 0 -map 1:a \
          -pix_fmt yuv420p -c:v libx264 -crf 16 -preset slow \
          -c:a aac -b:a 192k \
          "out/${f%.*}.mkv" -n
    done
else
    echo "Step 1: Entering container"
    podman run --rm -it --cpu-quota=70000 -v "$(pwd)":/yuuno:Z --userns=keep-id --security-opt label=disable --entrypoint=./encode.sh ghcr.io/nalsai/vapoursynth-yuuno:sha-ecb25f9 
fi
```

Podman may need `--user 0`, as it gets mapped to the host user and other users can't create files in the mounted volume.
If you use docker, you can just replace `podman` with `docker`.

Copy your filter script to `filter.vpy` with the variable `clip` as the source and your videos to the same folder as the script.
Don't forget to `import vapoursynth as vs` in the first line of your `filter.vpy` script.
Then run `./encode.sh` - it will start the container and encode all mkv files in the current folder.
