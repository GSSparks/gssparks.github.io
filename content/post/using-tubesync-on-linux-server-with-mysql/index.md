---
title: "Using Tubesync on Linux Server with MySQL"
date: 2022-09-05
image: "cover.png"
---
I recently installed Tubesync on my Arch Linux server to download commonly watched YouTube channels directly to my media server. Right off I noticed that if the system tried to perform a large task like indexing large channels it would timeout and return a code 500. Tubesync with it's built in SQLite database just wasn't able to keep up with larger channels. Luckily there's a [work around](https://github.com/meeb/tubesync/blob/main/docs/other-database-backends.md) by using MySQL server for the database. With this setup, I never get a code 500.

<!---more--->

Here's the Docker Compose YAML file:

```
version: '3'

services:
  tubesync:
    image: ghcr.io/meeb/tubesync:latest
    container_name: tubesync
    restart: unless-stopped
    ports:
      - 4848:4848
    depends_on:
      - tubesyncdb
    volumes:
      - /mnt/storage/videos/youtube/tubesync-config:/config
      - /mnt/storage/videos/youtube/tubesync-downloads:/downloads
    environment:
      - TZ=YOUR_TIMEZONE
      - PUID=1000
      - PGID=1000
      - DATABASE_CONNECTION=mysql://tubesync:PASSWORD@172.19.0.2:3306/tubesync
    networks:
      tubesync-net:
        ipv4_address: 172.19.0.3

  tubesyncdb:
    image: mysql
    container_name: tubesync-db
    restart: unless-stopped
    volumes:
      - /mnt/storage/videos/youtube/tubesync-db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=PASSWORD
      - MYSQL_USER=tubesync
      - MYSQL_PASSWORD=PASSWORD
      - MYSQL_DATABASE=tubesync
    networks:
      tubesync-net:
        ipv4_address: 172.19.0.2

networks:
  tubesync-net:
```
