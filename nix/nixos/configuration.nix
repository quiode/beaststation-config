# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs
, lib
, config
, pkgs
, ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs
    (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name) != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;
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
    docker_pw.file = ../../secrets/docker_pw.age;
    telegram_watchtower_token.file = ../../secrets/telegram_watchtower_token.age;
    db_pw.file = ../../secrets/db_pw.age;
    nextcloud_admin_password.file = ../../secrets/nextcloud_admin_password.age;
    nextcloud_smtp_password.file = ../../secrets/nextcloud_smtp_password.age;
    jwt_secret.file = ../../secrets/jwt_secret.age;
    bw_installation_id.file = ../../secrets/bw_installation_id.age;
    bw_installation_key.file = ../../secrets/bw_installation_key.age;
    schwaiger_admin_password.file = ../../secrets/schwaiger_admin_password.age;
    gitlab_smtp_password.file = ../../secrets/gitlab_smtp_password.age;
    registry_http_secret.file = ../../secrets/registry_http_secret.age;
  };

  environment = {
    # packages
    systemPackages = with pkgs; [ inputs.agenix.packages."${system}".default fastfetch onefetch btop sanoid dua ];

    # custom /etc stuff
    etc = {
      aliases = {
        text = ''
          root: mail@dominik-schwaiger.ch
        '';
      };
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
        configurationLimit = 5;
        mirroredBoots = [
          {
            devices = [ "/dev/disk/by-id/nvme-CT500P3SSD8_24304A25BBDC-part1" ];
            path = "/boot-fallback";
          }
        ];
      };
    };

    zfs = {
      extraPools = [ "virt" ]; # TODO: update with correct pool
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

        # should be the same settings as the normal ssd configuration
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWkILtyyPWk4UYWJaZoI5UqGKo/qlaJG5h7zfS69+ie mail@dominik-schwaiger.ch" ];
          hostKeys = [ /etc/ssh/ssh_host_ed25519_key ]; # important: unquoted
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # enable docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Set hostname
  networking = {
    hostName = "beaststation";
    hostId = "d7f38611";

    # enable firewall
    firewall = {
      enable = true;

      allowedTCPPorts = [ 22 80 443 1194 2222 25565 ];
      allowedUDPPorts = [ 22 80 443 1194 2222 25565 ];
    };

    extraHosts = ''
      127.0.0.1 registry.dominik-schwaiger.ch
    '';

    # explicitly enable, needed for remote unlocking
    useDHCP = true;
  };

  # Configure system-wide user settings
  users.users = {
    domina = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWkILtyyPWk4UYWJaZoI5UqGKo/qlaJG5h7zfS69+ie mail@dominik-schwaiger.ch"
      ];
      extraGroups = [ "wheel" "docker" ];
      initialPassword = "1234";
    };
  };

  services = {
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
          recursive = "zfs";
          process_children_only = true;
        };

        "hdd/enc/non-critical" = {
          use_template = [ "non-critical" ];
          recursive = "zfs";
          process_children_only = true;
        };

        "rpool/ssd/critical" = {
          use_template = [ "critical" ];
          recursive = "zfs";
          process_children_only = true;
        };

        "rpool/ssd/non-critical" = {
          use_template = [ "non-critical" ];
          recursive = "zfs";
          process_children_only = true;
        };

        "rpool/home" = {
          use_template = [ "critical" ];
          recursive = "zfs";
        };
      };
    };

    # automatic backup of zfs snapshots
    syncoid = {
      enable = false;

      # use system host key
      sshKey = "/etc/ssh/ssh_host_ed25519_key";

      # do as root
      user = "root";
      group = "root";

      commonArgs = [ "--delete-target-snapshots" "--no-sync-snap" ];

      commands = {
        "hdd/enc/critical" = {
          source = "hdd/enc/critical";
          target = "hdd/backup/hdd/critical"; # TODO
          sendOptions = "w";
          recursive = true;
        };

        "rpool/ssd/critical" = {
          source = "rpool/ssd/critical";
          target = "hdd/backup/ssd/critical"; # TODO
          sendOptions = "w";
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
        git-auth = "eval \"\$(ssh-agent -s)\" && ssh-add /etc/ssh/ssh_host_ed25519_key";
        update = "sudo nix flake update --commit-lock-file --flake /config/nix";
        upgrade = "sudo nixos-rebuild switch --flake /config/nix#beaststation";
        new = "update && upgrade";
        unlock = "sudo zfs load-key -a ; sudo zfs load-key -a -L prompt && sudo zfs mount -a";
      };

      loginShellInit = ''
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
          host = "dominik-schwaiger.vsos.ethz.ch";
          from = "beaststation@dominik-schwaiger.ch";
          user = "beaststation@dominik-schwaiger.ch";
          passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.beaststation_mail_password.path}";
        };
      };
    };

    # enable ssh agent
    ssh.startAgent = true;
  };

  # optimize storage automatically
  nix.optimise.automatic = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
