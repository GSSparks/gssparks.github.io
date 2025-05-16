---
title: "Protecting Linux from SYN Floods with sysctl"
date: 2025-04-04
description: "Protecting my server at the kernel level!"
image: "cover.jpg"
categories:
- Server Solutions
- Security
keywords:
- hacking
- linux
- SYN Floods
- SYN-RECIEVE
---

To harden your Linux server against SYN flood attacks—a common type of denial-of-service attack—you can configure TCP stack behavior using `sysctl`. Here's a sample config from `/etc/sysctl.d/99-synflood.conf`:
```
# Enable SYN cookies
net.ipv4.tcp_syncookies = 1
```
Defends against SYN floods by enabling SYN cookies. This lets the kernel respond to TCP SYN requests without allocating memory until the connection is fully established.

```
# Drop TCP connections after too many retransmissions
net.ipv4.tcp_synack_retries = 2
```
Limits retries for unacknowledged SYN+ACK packets. Fewer retries means the server won't wait long on suspicious clients.

```
# Limit the backlog queue to avoid memory exhaustion
net.ipv4.tcp_max_syn_backlog = 2048
net.core.somaxconn = 1024
```
Controls connection queues:

- `tcp_max_syn_backlog`: Max half-open (SYN-RECV) connections waiting for completion.

- `somaxconn`: Max length of the full connection queue.

Together, they limit how many pending connections are allowed, reducing memory exhaustion risks.

```
# Reduce time waiting for ACK
net.ipv4.tcp_abort_on_overflow = 1
```
Kills connections quickly if the accept queue is full, rather than waiting. This helps prevent queue overflow from being exploited.

To apply these changes immediately, run:

```
sudo sysctl --system
```
These settings are lightweight, kernel-level defenses that help keep your server responsive under load without requiring external tools like firewalls or proxies.
