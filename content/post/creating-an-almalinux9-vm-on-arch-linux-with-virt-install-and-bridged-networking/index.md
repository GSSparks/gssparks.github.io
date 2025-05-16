---
title: "Creating an AlmaLinux 9 VM on Arch Linux with virt-install and Bridged Networking"
date: 2025-04-02
description: "Set up a powerful AlmaLinux 9 virtual machine on your Arch Linux host using virt-install and bridged networking for full LAN access—perfect for testing, development, or server workloads."
image: "cover.jpg"
categories:
- Server Solutions
keywords:
- linux
- al9
- vm
- bridged networking
---
I set up an AlmaLinux 9 VM on my Arch Linux server using libvirt and virt-install. My requirements:

- VM gets its own IP from my router (bridged to LAN)

- VM autostarts with the host

- Installation is headless

- I’m not using NetworkManager—I use `systemd-networkd`

## Step 1: Install Required Packages
```
sudo pacman -S libvirt qemu virt-manager dnsmasq bridge-utils edk2-ovmf
```
Enable and start libvirt:
```
sudo systemctl enable --now libvirtd
```
## Step 2: Create a Bridge with systemd-networkd

Create the following files:

`/etc/systemd/network/br0.netdev`
```
[NetDev]
Name=br0
Kind=bridge
```
`/etc/systemd/network/br0.network`
```
[Match]
Name=br0

[Network]
DHCP=yes
```
`/etc/systemd/network/ethernet.network`
```
[Match]
Name=enp3s0  # Replace with your actual interface

[Network]
Bridge=br0
```
Enable and restart systemd-networkd:
```
sudo systemctl enable --now systemd-networkd
```
You should now see `br0` come up with an IP address from your LAN's DHCP server.

## Step 3: Create a Libvirt Network for the Bridge

Save this as `lanbridge.xml`:
```
<network>
  <name>lanbridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
```
Apply it:
```
sudo virsh net-define lanbridge.xml
sudo virsh net-autostart lanbridge
sudo virsh net-start lanbridge
```
## Step 4: Mount the AlmaLinux ISO
```
sudo mount -o loop AlmaLinux-9.5-x86_64-dvd.iso /mnt
```
## Step 5: Install the VM (Text-Only, Headless)
```
virt-install \
  --connect qemu:///system \
  --name wazuh-server \
  --ram 4096 \
  --vcpus 4 \
  --os-variant almalinux9 \
  --location /mnt \
  --disk path=/var/lib/libvirt/images/almalinux9.qcow2,size=20 \
  --network network=lanbridge \
  --graphics none \
  --console pty,target_type=serial \
  --extra-args='console=ttyS0,115200 inst.text' \
  --autostart
```
## Notes

Exit console: `Ctrl+]`

Reconnect to VM:
```
sudo virsh --connect qemu:///system console wazuh-server
```
VM autostarts with the host and gets a DHCP lease like a normal device.
