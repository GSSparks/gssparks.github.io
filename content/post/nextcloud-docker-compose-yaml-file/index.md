---
title: "Nextcloud Docker Compose YAML File"
date: 2022-09-05
image: "cover.jpg"
categories:
- Docker Compose
keywords:
- nextcloud
- docker-compose
- configuration
---
This is my current Docker Compose YAML file for my Nextcloud instance.

<!--more-->

```
version: '3'

services:
  nextcloud-db:
    image: mariadb
    container_name: nextcloud-db
    restart: always
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW --innodb-read-only-compressed=OFF
    volumes:
      - /mnt/nextcloud/db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=PASSWORD
      - MYSQL_PASSWORD=PASSWORD
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
    networks:
      nextcloud-net:
        ipv4_address: 172.20.0.2

  nextcloud-app:
    image: nextcloud
    container_name: nextcloud-app
    restart: always
    ports:
      - 8888:80
    links:
      - nextcloud-db
    volumes:
      - /mnt/nextcloud/data:/var/www/html
    environment:
      - MYSQL_PASSWORD=PASSWORD
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=database
    networks:
      nextcloud-net:
        ipv4_address: 172.20.0.3

networks:
  nextcloud-net:
```
