# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # specify agenix secrets. will be mounted at /run/agenix/secret
  age.secrets = {
    beaststation_mail_password.file = ../../secrets/beaststation_mail_password.age;
  };

  environment = {
    # packages
    systemPackages = with pkgs; [
      inputs.agenix.packages."${system}".default
      fastfetch
      onefetch
      btop
      sanoid
      dua
      gptfdisk
      htop
      pv
      zip
      unzip
      immich-cli
      speedtest-cli
      wget
      nvtopPackages.full
      zfs-prune-snapshots
      pciutils
      usbutils
    ];

    # custom /etc stuff
    etc = {
      aliases = {
        text = ''
          root: mail@dominik-schwaiger.ch
        '';
      };
    };
  };

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true; # needed for docker nvidia enable

    # install correct nvidia driver
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    # enable zfs support explicitly
    supportedFilesystems = [ "zfs" ];

    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        configurationLimit = 10;
        mirroredBoots = [
          {
            devices = [ "/dev/disk/by-id/nvme-CT500P3SSD8_24304A25BBDC-part1" ];
            path = "/boot-fallback";
          }
        ];
      };
    };

    zfs = {
      extraPools = [
        "virt"
        "hdd"
      ];
    };

    # use the latest ZFS-compatible Kernel
    # Note this might jump back and forth as kernels are added or removed.
    kernelPackages = latestKernelPackage;

    # enable remote unlocking by ssh, so that zfs datasets can be encrypted on boot
    kernelModules = [ "r8169" ];
    kernelParams = [ "ip=dhcp" ];

    initrd = {
      availableKernelModules = [ "r8169" ];
      network = {
        enable = true;
        postCommands = ''
          # Import all pools and Add the load-key command to the .profile
          echo "zpool import -a && zfs load-key -a && killall zfs" >> /root/.profile
        '';

        # should be the same settings as the normal ssh configuration
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt4xvNKr0MsKk7qY9RJux9KGfUk2lCsnAeUO4NtJP8n quio@gaming-pc"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpYUYVbj55SB3zK+W+oUq2AdO3sS27ZeTtGVYpdq3Dd quio@laptop"
          ];
          hostKeys = [
            /etc/secrets/initrd/ssh_host_rsa_key
            /etc/secrets/initrd/ssh_host_ed25519_key
          ]; # important: unquoted
        };
      };

      secrets."/config/secrets/passphrase.txt" = /config/secrets/passphrase.txt;
    };
  };

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # enable docker
  virtualisation.docker = {
    enable = true;
    enableNvidia = true; # TODO: deprecated, but replacement doesn't supply Nvidia runtime for docker and without that automatic restart doesn't work
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
    };
    daemon.settings = {
      "default-address-pools" = [
        {
          "base" = "172.29.0.0/16";
          "size" = 24;
        }
        {
          "base" = "172.30.0.0/16";
          "size" = 24;
        }
        {
          "base" = "172.31.0.0/16";
          "size" = 24;
        }
      ];
    };
  };

  # Set hostname
  networking = {
    hostName = "beaststation";
    hostId = "d7f38611";

    # enable firewall
    firewall = {
      enable = true;

      allowedTCPPorts = [
        22
        80
        443
        1194
        2222
        25565
        25
        143
        389
        465
        587
        636
        993
      ];
      allowedUDPPorts = [
        22
        80
        443
        1194
        2222
        25565
        25
        143
        389
        465
        587
        636
        993
        34197
      ];
    };

    # explicitly enable, needed for remote unlocking
    useDHCP = true;
  };

  # Configure system-wide user settings
  users = {
    groups = {
      virt = { };
      domina = { };
      vali = { };
    };

    users = {
      domina = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt4xvNKr0MsKk7qY9RJux9KGfUk2lCsnAeUO4NtJP8n quio@gaming-pc"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpYUYVbj55SB3zK+W+oUq2AdO3sS27ZeTtGVYpdq3Dd quio@laptop"
        ];
        extraGroups = [
          "wheel"
          "docker"
          "video"
        ];
        group = "domina";
      };

      virt = {
        isNormalUser = true;
        extraGroups = [ ];
        group = "virt";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvENmoNJtelL9NIB+c/KSanF5kajF+/SuS1FuA3n5a7l/XFEw0YHw8vRZqjsJYHHjCyKba0BZ0kVu96JtiLEcR6SE7rpESuJ8hVL0JS8sVCjp+jjpmMM60aOx7vXPqR6BiOnCK74EpucEXrotUl0KYD0TEwE9O1ArML9Pxz2VFQ/mFjmmGmOg46B3N302T6t4Ng+YzavUW9E5S1Lw5hxQPR2G4ujLSFeIwchTTqG7SpJfzmczJ8XPQ6SJ2fNTkXfTNBOBOe5d8g1XNrZz55njV9IWIIpnOPDpKfPYCuubiFgkQv89n7fpS/lLr1sNyYnGVowjamOI6GKzWmG+hqkpnLz0sx5clurr6nMYb6MlmFsBi9saBoWyVLAQOhrat882Sk3dd5NebEA5A53ctk4oVd92Wda6PYvaVsC5KC+fqztE1+Zvi8jJR21l3Yh/GmlRBplKp/WlUJ+MF9MD+/mOaU9Ca8EmibitIjEkv1/GnQHR2KsHaFBooF7pfBQh3mxhfE1RF6a1Y2zzSO5GDzdQlDCQmjvB8KT0vEScna5dhw9ys+sS8Q5pqtpouObUUL4DRFr27GUpzrdKNtrJ4bonWFhPeurQBsXEvpMT/Xl4rH0+2WNeiSmTv2+U8U1y7Ld+tQa296EfgZ+62CMQLV7JRuJYoPpkc6nNtCJ8FIJPrPw== joshua@board"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIffUHUiY5LIzpG5EfwT6mbulPlwejd7rSztrJmMohP1 backup@pool"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9S1UMVtJr2CHLg2XuSMyl8m2F/ezKULST7kM7saY2r backup@home"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6sBthWuPYqE+Bds9QKfg9ka0L6CAXsf0NrEEIvbq6lJdUt34tp/IjPtJe0g0cydgXpdLk/hsOM1tn0h/hCXBy2YjUab/aJbRZPf+qXD9ZLg4o1w/nPc4a64BsLwYAdtiS9osq15zUpzibYRLaaKhLlF7v4LY0tiwU7hUO8kQs/jxDBDfvx4xTexCWHoWcBtX9xdQQSXqX3JKhVjQxMfsYxw1TJZ6LZduAIxo8kKKJ+WXl8JpORu+c98OQ++ed1UMIxaAeviOJ34+0EK/wDtakzqLUGXL7h5OZ07p7jBCiLo4WYhAMIwSS20tWP2J3aS02v0Xd+BAdsPW1iKIVlJGBK8XWDIlYn9+otJ+TR3DK9ROGFBKJlBCs7n7NBFchE/2NmI0O0DASm/jn6tjFumk7aOKvycCu102zTnxzpuO+1NlV/xmZS+DnQb/mQxZy+1CAKMmxBGoY+BiPHFpbpD7O59AY5fuOm2G/5J32CzKPXTuLdgjttzsPi/QkS7FFwh8= joshua@pad"
        ];
      };

      vali = {
        isNormalUser = true;
        extraGroups = [ ];
        group = "vali";
        openssh.authorizedKeys.keys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAWEDj/Yib6Mqs016jx7rtecWpytwfVl28eoHtPYCM9TVLq81VIHJSN37lbkc/JjiXCdIJy2Ta3A3CVV5k3Z37NbgAu23oKA2OcHQNaRTLtqWlcBf9fk9suOkP1A3NzAqzivFpBnZm3ytaXwU8LBJqxOtNqZcFVruO6fZxJtg2uE34mAw=="
        ];
      };
    };
  };

  services = {
    xserver = {
      enable = false;
      videoDrivers = [ "nvidia" ];
    };

    # This setups a SSH server.
    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };

      # use non-default 222 port for ssh
      ports = [ 2222 ];
    };

    zfs = {
      # zfs auto scrub
      autoScrub.enable = true;

      # enable zed -> email notifications for zfs
      zed = {
        settings = {
          ZED_DEBUG_LOG = "/tmp/zed.debug.log";
          ZED_EMAIL_ADDR = [ "root" ];
          ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
          ZED_EMAIL_OPTS = "@ADDRESS@";

          ZED_NOTIFY_INTERVAL_SECS = 3600;
          ZED_NOTIFY_VERBOSE = true;

          ZED_USE_ENCLOSURE_LEDS = true;
          ZED_SCRUB_AFTER_RESILVER = true;
        };

        # this option does not work; will return error
        enableMail = false;
      };
    };

    # automatic snapshots of zfs datasets
    sanoid = {
      enable = true;

      templates = {
        critical = {
          # frequency
          hourly = 36;
          daily = 30;
          monthly = 6;
          yearly = 0;

          # additional settings
          autoprune = true;
          autosnap = true;
        };

        non-critical = {
          # frequency
          hourly = 10;
          daily = 7;
          monthly = 1;
          yearly = 0;

          # additional settings
          autoprune = true;
          autosnap = true;
        };
      };

      datasets = {
        "hdd/enc/critical" = {
          use_template = [ "critical" ];
          recursive = true;
        };

        "hdd/enc/non-critical" = {
          use_template = [ "non-critical" ];
          recursive = true;
        };

        "rpool/ssd/critical" = {
          use_template = [ "critical" ];
          recursive = true;
        };

        "rpool/ssd/non-critical" = {
          use_template = [ "non-critical" ];
          recursive = true;
        };

        "rpool/home" = {
          use_template = [ "critical" ];
          recursive = true;
        };

        "rpool/nix" = {
          use_template = [ "non-critical" ];
          recursive = true;
        };

        "rpool/root" = {
          use_template = [ "non-critical" ];
          recursive = true;
        };

        "rpool/var" = {
          use_template = [ "non-critical" ];
          recursive = true;
        };
      };
    };

    # automatic backup of zfs snapshots
    syncoid = {
      enable = true;

      user = "syncoid";
      group = "syncoid";

      # use custom ssh key
      sshKey = /etc/secrets/syncoid/id_ed25519;

      commonArgs = [
        "--delete-target-snapshots"
        "--no-sync-snap"
      ];

      commands = {
        "hdd/enc/critical" = {
          source = "hdd/enc/critical";
          target = "domina@yniederer.ch:backup/hdd";
          sendOptions = "w";
          extraArgs = [
            "--sshport"
            "2222"
          ];
          recursive = true;
        };

        "rpool/ssd/critical" = {
          source = "rpool/ssd/critical";
          target = "domina@yniederer.ch:backup/ssd";
          sendOptions = "w";
          extraArgs = [
            "--sshport"
            "2222"
          ];
          recursive = true;
        };
      };
    };
  };

  # set locale, time, etc.
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "de_CH-latin1";

  # programs
  programs = {
    vim = {
      enable = true;
      defaultEditor = true;
    };

    git = {
      enable = true;
      config = {
        user = {
          email = "beaststation@dominik-schwaiger.ch";
          name = "beaststation";
        };

        save = {
          directory = [ "config" ];
        };
      };
    };

    bash = {
      # set alias for simple update
      shellAliases = {
        update = "nix flake update --commit-lock-file --flake /config/nix";
        upgrade = "nh os switch /config/nix";
        unlock = "sudo zfs load-key -a ; sudo zfs load-key -a -L prompt && sudo zfs mount -a";
        occ = "sudo docker exec --user www-data nextcloud php occ";
      };

      loginShellInit = ''
        # If not running interactively, don't do anything and return early
        [[ $- == *i* ]] || return  
        fastfetch
      '';
    };

    # enable mail sending through mail server
    msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = 465;
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
        tls = "on";
        auth = "login";
        tls_starttls = "off";
      };
      accounts = {
        default = {
          host = "mail.dominik-schwaiger.ch";
          from = "beaststation@dominik-schwaiger.ch";
          user = "beaststation@dominik-schwaiger.ch";
          passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.beaststation_mail_password.path}";
        };
      };
    };

    # enable ssh agent
    ssh = {
      startAgent = true;
      knownHosts = {
        "[yniederer.ch]:2222".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxx2JxRobdvqPUIDgl0xFHoF0UVjNGNGmQzqg0xr210";
      };
    };

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 5";
      flake = "/config/nix";
    };
  };

  # optimize storage automatically
  nix.optimise.automatic = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
