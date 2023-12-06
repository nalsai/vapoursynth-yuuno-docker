# Vapoursynth-Yuuno Docker

An OCI container for running Vapoursynth with Yuuno (JupyterLab) based on Arch Linux.

docker-compose.yml example:

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
