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
sgdisk -n2:0:+4G -t2:8200 $DISK1 # set to a custom size of needed, swap
sgdisk -n3:0:0 -t3:8300 $DISK1 # root/rest

sgdisk -o $DISK2 # clear the second disk
```

3. check the partitions `fdisk -l`

3. create zfs pool

```bash
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=none \
    rpool \
    $DISK1-part3 $DISK2
```

5. create datasets and mount them

```bash
zfs create rpool/root
zfs create rpool/nix
zfs create rpool/var
zfs create rpool/home

mkdir -p /mnt
mount -t zfs rpool/root /mnt -o zfsutil
mkdir /mnt/nix /mnt/var /mnt/home

mount -t zfs rpool/nix /mnt/nix -o zfsutil
mount -t zfs rpool/var /mnt/var -o zfsutil
mount -t zfs rpool/home /mnt/home -o zfsutil
```

6. format boot

```bash
mkfs.fat -F 32 -n boot $DISK1-part1
```

7. format swap

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
1. update bootloader config and network host (get is using `head -c4 /dev/urandom | od -A none -t x4`) in `configuration.nix`

```nix
  boot = {
    # enable zfs support explicitly
    supportedFilesystems = [ "zfs" ];

    # enable systemd boot
    loader.systemd-boot.enable = true;
  };
  networking = {
    hostName = "beaststation-backup";
    hostId = "0fe3b192";
    firewall = {
      enable = true;

      allowedTCPPorts = [ 2222 ];
      allowedUDPPorts = [ 2222 ];
    };
  };
  users.users = {
    backup = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWkILtyyPWk4UYWJaZoI5UqGKo/qlaJG5h7zfS69+ie mail@dominik-schwaiger.ch"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxfAbBPBerC/yizdTU3aWII4fsDWEwZBHmxMAhgNn7X quio@dominik-kaltbrunn-pc"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINYO9+aRrPHh8WDkpcY0xSxJeFZg3nyjuhXkLOlBKIm"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/s6lYNuiiu10xgH91eUfyHMBumXa3wby0dP+PaVsaF root@beaststation"
      ];
      extraGroups = [ "wheel" ];
    };
  };
  services = {
    # This setups a SSH server.
    openssh = {
      enable = true;
      # use non-default 222 port for ssh
      ports = [ 2222 ];
    };
  };
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "de_CH-latin1";
  programs = {
    vim = {
      enable = true;
      defaultEditor = true;
    };

    git = {
      enable = true;
      config = {
        user = {
          email = "beaststation-backup@dominik-schwaiger.ch";
          name = "beaststation-backup";
        };

        save = {
          directory = [ "config" ];
        };
      };
    };
  };
```

3. update the hardware configuration `hardware-configuration.nix`

*(Now check the hardware-configuration.nix in /mnt/etc/nixos/hardware-configuration.nix and add whats missing e.g. options = [ "zfsutil" ] for all filesystems except boot and randomEncryption = true; for the swap partition. Also change the generated swap device to the partition we created e.g. /dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part2 in this case and /dev/disk/by-id/nvme-SKHynix_HFS512GDE9X081N_FNB6N634510106K5O-part1 for boot.)* - <https://wiki.nixos.org/wiki/ZFS>

```nix
{
  # ...

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/var" =
    { device = "rpool/var";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
      options = ["zfsutil"];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBdb4578c1-95c7dacd-part1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { 
         device = "/dev/disk/by-id/ata-VBOX_HARDDISK_VBdb4578c1-95c7dacd-part2"; 
         randomEncryption = true;
      }
    ];

  # ...
}
```

4. install nixos `nixos-install --root /mnt`

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
