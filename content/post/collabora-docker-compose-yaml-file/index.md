---
title: "Collabora Docker Compose YAML File"
date: 2022-09-05
image: 'cover.png'
---
This my Docker Compose file for Collabora, which I use inside of my Nextcloud instance.

<!--more-->

```
version: '3'

services:
  collabora:
    image: collabora/code
    container_name: collabora
    restart: always
    ports:
      - 9980:9980
    environment:
      server_name: collabora.your-server.com
      aliasgroup1: https://nextcloud.your-server.com:443
      username: 'USERNAME'
      password: 'PASSWORD'
```
