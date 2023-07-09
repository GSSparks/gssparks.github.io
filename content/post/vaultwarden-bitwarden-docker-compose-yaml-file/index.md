---
title: "Vaultwarden/Bitwarden Docker Compose YAML File"
date: 2022-09-05
image: 'cover.jpg'
categories:
- Docker Compose
keywords:
- vaultwarden
- bitwarden
- docker-compose
- configuration
---
This is my current Vaultwarden Docker Compose yaml file.

<!--more-->

```
version: '3'

services:
  bitwarden:
    image: vaultwarden/server:latest
    container_name: bitwarden
    restart: always
    ports:
      - 8282:80
    volumes:
      - /mnt/storage/bw-data:/data
    environment:
      WEBSOCKET_ENABLED: 'true' # Required to use websockets
      SIGNUPS_ALLOWED: 'false'   # set to false to disable signups
```
