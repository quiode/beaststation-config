# NixOS Backup Configuration

This folder contains the nixos configuration for the backup server.

## Installation

This is a step-by-step guide to install nixos. The assumption is that the server is installed on **two separate disks joined together** (so not mirrored as in the server config).

### Guide

Use the minimal edition of the nixos installer. This is tested for nixos version 24.11.

#### Host Setup

1. Become root: `sudo su`
1. Enable german keys: `loadkeys de`
1. Set password: `passwd`
1. Enable ssh: `systemctl restart sshd`
1. Get the ip of the server: `ip address`

Now connect with the system using the host ssh: `ssh root@ip`.

#### Partitioning

1. Save the disks `DISK1=/dev/disk/by-id/...`, `DISK2=/dev/disk/by-id/...`
1. create the partitions:

```bash
sgdisk -o $DISK1 # clear the disk
sgdisk -n1:1M:+1G -t1:EF00 $DISK1 # efi/boot
sgdisk -n2:0:+8G -t2:8200 $DISK1 # set to a custom size of needed, swap
sgdisk -n3:0:+50G -t3:8300 $DISK1 # root
sgdisk -n4:0:0 -t4:8300 $DISK1 # zfs

sgdisk -o $DISK2 # clear the second disk
```

3. check the partitions `fdisk -l`

3. create zfs pool

```bash
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O compression=zstd-6 \
    backup \
    $DISK1-part4 $DISK2
```

5. format boot

```bash
mkfs.fat -F 32 -n boot $DISK1-part1
```

6. format swap

```bash
mkswap -L swap $DISK1-part2
swapon $DISK1-part2
```

#### Install NixOS

1. mount boot

```bash
mkdir -p /mnt/boot
mount $DISK1-part1 /mnt/boot

# Generate the nixos config
nixos-generate-config --root /mnt
```

#### Configure NixOs

1. go into the nixos directory: `cd /mnt/etc/nixos`
1. clone the repo (<https://github.com/quiode/beaststation-config.git>) and replace the files
1. update the hardware configuration `hardware-configuration.nix`

*(Now check the hardware-configuration.nix in /mnt/etc/nixos/hardware-configuration.nix and add whats missing e.g. options = [ "zfsutil" ] for all filesystems except boot and randomEncryption = true; for the swap partition. Also change the generated swap device to the partition we created e.g. /dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part2 in this case and /dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part1 for boot.)* - <https://wiki.nixos.org/wiki/ZFS>

4. install nixos `nixos-install --flake .#beaststation-backup --root /mnt --impure`

## Setup after installation

1. set passwort for root and users using `passwd`
1. create datasets, import/create additional pools and add them to the `configuration.nix` for automatic import
1. enable git in `configuration.nix`: `programs.git.enable = true;`
1. Clone the Repository: `git clone https://github.com/quiode/beaststation-docker-compose.git /config` to a sutable location `/config`
1. remove the existing nixos config and sync it to the git repository: `rm -rf /etc/nixos` and then `ln -s /config/nix-backup /etc/nixos`
1. use the config: `nixos-rebuild switch`

## Passwords

Passwords and other secrets are all being handled using [agenix](https://github.com/ryantm/agenix). They are stored encrypted under `../secrets` and are decrypted (using the ssh key of the host system) and mounted under `/run/agenix`.

For more information read the readme in the secrets folder.

## Encryption

The real data is encrypted. So the dataset containing the backup datasets is being sent encrypted and can't be decrypted on the server.
