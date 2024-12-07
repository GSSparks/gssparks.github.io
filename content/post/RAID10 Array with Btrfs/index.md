---
title: "RAID10 Array with Btrfs"
date: 2024-12-07
description: "Minimizing Downtime and Enabling Incremental Upgrades by building a RAID10 Array with Btrfs."
image: "cover.png"
categories:
- Scripts
keywords:
- filesystem
- btrfs
- raid
- server administration
---

# Introduction

When designing a storage solution for reliability, redundancy, and performance, a RAID10 (Redundant Array of Independent Disks, level 10) configuration is one of the most effective strategies. Combining the speed of RAID0 (striping) with the redundancy of RAID1 (mirroring), RAID10 offers both high performance and fault tolerance, making it an ideal choice for critical applications and workloads.

Using Btrfs, a modern copy-on-write (COW) filesystem, further enhances RAID10 by providing powerful features such as data integrity checks, snapshots, and easy expansion. In this article, we will explore how to set up a RAID10 array with Btrfs, how to minimize downtime during failures, and how to take advantage of Btrfs’s flexibility for incremental upgrades.

# What is RAID10?

RAID10 is a hybrid configuration that combines the benefits of both RAID0 and RAID1:

RAID0 (Striping): Data is split across two or more drives for improved performance. The downside is that it lacks redundancy—if one drive fails, data is lost.
RAID1 (Mirroring): Data is duplicated on two or more drives, providing redundancy in case of a failure. However, it has lower performance than RAID0 due to the need for mirroring data.
RAID10 combines these two methods. It mirrors data across pairs of drives (RAID1) and then stripes the data across multiple mirrored sets (RAID0). This setup offers redundancy (so data is safe in case of a drive failure) while maintaining higher read and write speeds than RAID1 alone.

# Why Use Btrfs with RAID10?

Btrfs, a modern filesystem, introduces features that make RAID10 even more powerful and flexible:

- **Copy-on-write (COW):** Btrfs uses COW, meaning that when data is modified, the new data is written to a new location. This reduces the risk of corruption, as the previous data remains intact until the write is confirmed.
- **Snapshots:** Btrfs supports snapshots, allowing you to take read-only, point-in-time copies of your data. This is invaluable for backups and data recovery.
- **Incremental Upgrading:** Btrfs allows for the easy addition and removal of disks, making it simple to upgrade your RAID10 array incrementally.

# Steps to Build a RAID10 with Btrfs
## Step 1: Install Btrfs
Ensure that Btrfs is installed and available on your system. On most Linux distributions, Btrfs comes pre-installed. However, if you need to install it, you can do so via the package manager.

For Ubuntu/Debian-based systems:

```
sudo apt-get install btrfs-progs
```

For RedHat/CentOS/Fedora-based systems:
```
sudo dnf install btrfs-progs
```

For Arch Linux based systems:
```
sudo pacman -S btrfs-progs
```

## Step 2: Prepare the Drives
You need at least four drives to set up a RAID10 array, as RAID10 requires two mirrored pairs. Each drive should be empty, as Btrfs will format them during setup.

You can check the available drives on your system using the `lsblk` or `fdisk -l` command.

## Step 3: Create the Btrfs RAID10 Array
To create the RAID10 array, use the following Btrfs command:

```
sudo mkfs.btrfs -d raid10 -m raid10 /dev/sda /dev/sdb /dev/sdc /dev/sdd
``` 

Here:

- `-d raid10` specifies the data layout (RAID10).
- `-m raid10` specifies the metadata layout (RAID10).
- `/dev/sda`, `/dev/sdb`, `/dev/sdc`, and `/dev/sdd` are the devices you want to include in the RAID10 array.

## Step 4: Mount the Filesystem
Once the RAID10 array is created, you need to mount it to a directory for use. For example:

```
sudo mount /dev/sda /mnt/storage
```

Make sure to replace /mnt/storage with your desired mount point.

## Step 5: Monitor the RAID10 Array
You can verify the status of your RAID10 array using the btrfs filesystem show command:

```
sudo btrfs filesystem show /mnt/storage
```

This command will display information about the filesystem, including the number of devices and their status.

## Step 6: Adding Drives to Expand the RAID10 Array
One of the advantages of Btrfs is that you can add additional drives to the RAID10 array to expand storage without downtime. To add a drive, use the following command:

```
sudo btrfs device add /dev/sde /mnt/storage
```

Replace `/dev/sde` with the drive you want to add. After adding the drive, run a rebalance operation to integrate the new device into the array:

```
sudo btrfs balance start /mnt/storage
```

## Step 7: Replacing Failed Drives
If a drive fails, Btrfs allows you to replace it without significant downtime. First, identify the failed drive:

```
sudo btrfs device stats /mnt/storage
```

Next, replace the failed drive with a new one. For example, if `/dev/sdb` failed, replace it with a new drive (`/dev/sdf`):

```
sudo btrfs device replace /dev/sdb /dev/sdf /mnt/storage
```

Btrfs will automatically handle the rebuild process, ensuring that the array remains available during the replacement.

## Step 8: Incremental Upgrades and Rebalancing
As your storage needs grow, you can continue to add and remove drives to your RAID10 array incrementally. After each change (e.g., adding or removing a drive), you should run a rebalance operation:

```
sudo btrfs balance start /mnt/storage
```

This operation redistributes the data across the array and ensures that the filesystem is optimized for the new configuration.

# Minimizing Downtime
Btrfs’s built-in features help minimize downtime during drive failures and replacements:

- **Online Replacement:** Btrfs allows you to replace failed drives without taking the array offline, meaning applications and services can continue running while the rebuild process occurs in the background.
- **Rebalancing:** The rebalance process is non-disruptive, ensuring that the array remains available during expansion or when replacing drives.
- **Snapshots:** If you need to perform risky operations or major changes to your storage, you can take a snapshot of the array before making any modifications. If anything goes wrong, you can easily roll back to the snapshot.

# Conclusion

Using Btrfs for RAID10 provides both high performance and redundancy while offering flexibility for incremental upgrades. With Btrfs’s ability to easily add and replace drives, as well as its online balance and rebuild capabilities, you can minimize downtime and ensure that your system remains available even during hardware failures. Additionally, the copy-on-write nature of Btrfs, combined with its snapshot functionality, adds an extra layer of data protection, making it an ideal choice for mission-critical storage solutions.
