# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
imports =
  [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
boot.initrd.kernelModules = [ ];
boot.kernelModules = [ ];
boot.extraModulePackages = [ ];

fileSystems."/" =
  {
    device = "rpool/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

fileSystems."/nix" =
  {
    device = "rpool/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

fileSystems."/var" =
  {
    device = "rpool/var";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

fileSystems."/home" =
  {
    device = "rpool/home";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

fileSystems."/boot" =
  {
    device = "/dev/disk/by-id//dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-part1";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

swapDevices = [{ device = "/dev/disk/by-id//dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-part2"; randomEncryption = true; }];

# Enables DHCP on each ethernet and wireless interface. In case of scripted networking
# (the default) this is the recommended approach. When using systemd-networkd it's
# still possible to use this option, but it's recommended to use it in conjunction
# with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
networking.useDHCP = lib.mkDefault true;
# networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;

nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
