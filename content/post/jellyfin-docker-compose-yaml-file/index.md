---
title: "Jellyfin Docker Compose YAML File"
date: 2022-09-05
image: "cover.png"
categories:
- Docker Compose
keywords:
- jellyfin
- docker-compose
- configuration
---
This is my docker compose YAML file for my Jellyfin Instance.

<!---more--->

```
version: "3"
services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    restart: "unless-stopped"
    network_mode: "host"
    volumes:
      - /mnt/storage/jellyfin/config:/config
      - /mnt/storage/jellyfin/cache:/cache
      - /mnt/storage/Videos:/media
      - /mnt/storage/Music:/music
    environment:
      - JELLYFIN_PublishedServerUrl=https://jellyfin.your-server.com
    devices:
    # VAAPI Devices
    - /dev/dri/renderD128:/dev/dri/renderD128
    - /dev/dri/card0:/dev/dri/card0
```
