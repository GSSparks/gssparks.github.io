---
title: "Static IP Address on an Arch Linux Headless Server"
date: 2022-09-05
image: cover.png
---
On my local Pi-Hole server I wanted to set a static IP address as opposed to dynamic. And although there are a few different ways to do this using netctl or systemd-network, I decided to use dhcpd. On this box I have a few docker containers running that make use of dhcp so it seems easiest to just use this to set the static IP address.
First I needed to find the name of the network interface. Typing the following command will give me the name of my device.
```
ip link show

enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
        mode DEFAULT group default qlen 1000
        link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
```
Now that I have the device name, I need to add it to the dhcpcd.conf file. I use nano to add the settings to the end of the config file.
```
sudo nano /etc/dhcpcd.conf

interface enp4s0
static ip_address=10.10.10.2/24
static routers=10.10.10.1
static domain_name_server=127.0.0.1
```
After saving the file, I then restarted the dhcp server.
```
sudo systemctl restart dhcpd.service
```
Now checking the server with ifconfig I can see that the network device is now using IP address 10.10.10.2.
```
ifconfig enp4s0

enp4s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.10.10.2  netmask 255.255.255.0  broadcast 10.10.10.255
```
