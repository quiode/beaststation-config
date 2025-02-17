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
  age.secrets = { };

  environment = {
    # packages
    systemPackages = with pkgs; [ inputs.agenix.packages."${system}".default fastfetch onefetch btop sanoid dua htop speedtest-cli wget zfs-prune-snapshots ];

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

    # enable systemd boot
    loader.systemd-boot.enable = true;

    # use the latest ZFS-compatible Kernel
    # Note this might jump back and forth as kernels are added or removed.
    kernelPackages = latestKernelPackage;
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

  # Set hostname
  networking = {
    hostName = "beaststation-backup";
    hostId = "0fe3b192";

    # enable firewall
    firewall = {
      enable = true;

      allowedTCPPorts = [ 2222 ];
      allowedUDPPorts = [ 2222 ];
    };
  };

  # Configure system-wide user settings
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
          email = "beaststation-backup@dominik-schwaiger.ch";
          name = "beaststation-backup";
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
          from = "beaststation-backup@dominik-schwaiger.ch";
          user = "beaststation-backup@dominik-schwaiger.ch";
          passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.beaststation-backup_mail_password.path}";
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
