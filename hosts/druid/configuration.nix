# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, flakePkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      trusted-users = root thorny
    '';
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "druid"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Use nftables
  networking.nftables.enable = true;

  # Don't block DHCP requests to the Incus network
  networking.firewall.trustedInterfaces = [
    "incusbr0"
    "docker0"
  ];

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thorny = {
    home = "/home/thorny";
    isNormalUser = true;
    shell = pkgs.bash;
    description = "thorny";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "incus-admin"
    ];
    # These entries are required for docker's --userns-remapping option to
    # create files on the host as the correct 'thorny' user
    subUidRanges = [
      {
        count = 1;
        startUid = 1000;
      }
      {
        count = 65534;
        startUid = 100001;
      }
    ];
    subGidRanges = [
      {
        count = 1;
        startGid = 1000;
      }
      {
        count = 65534;
        startGid = 100001;
      }
    ];
  };
  # Add subgid and subuid ranges for root so the incus daemon can remap files
  # back to "thorny"
  users.users.root.subUidRanges = [
    {
      startUid = 1000000;
      count = 1000000000;
    }
    {
      startUid = 1000;
      count = 1;
    }
  ];
  users.users.root.subGidRanges = [
    {
      startGid = 1000000;
      count = 1000000000;
    }
    {
      startGid = 1000;
      count = 1;
    }
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    let
      basePackages = import ../../hosts/shared/packages-base.nix pkgs;
      localPackages = [ flakePkgs.myneovim ];
    in
    lib.mkMerge [
      basePackages
      localPackages
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation = {
    docker = {
      enable = true;
      # Be aware that if you try running namespaced docker with nomad, nomad can run into issues
      extraOptions = "--userns-remap=thorny:100";
      package = pkgs.docker_29;
    };
    incus = {
      enable = true;
      # Incus preseed values. Copied from the wiki page https://wiki.nixos.org/wiki/Incus
      # They all seemed to match what I needed.
      preseed = {
        networks = [
          {
            config = {
              "ipv4.address" = "10.0.100.1/24";
              "ipv4.nat" = "true";
            };
            name = "incusbr0";
            type = "bridge";
          }
        ];
        profiles = [
          {
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                size = "35GiB";
                type = "disk";
              };
            };
            name = "default";
          }
          {
            name = "agent-sandbox";
            description = "Sandbox for Claude Code with nested Docker";
            config = {
              "security.nesting" = "true";
              "security.syscalls.intercept.mknod" = "true";
              "security.syscalls.intercept.setxattr" = "true";
              "linux.kernel_modules" = "tun";
              "raw.idmap" = ''
                uid 1000 1000
                gid 1000 1000
              '';
            };
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
        ];
        storage_pools = [
          {
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
            driver = "dir";
            name = "default";
          }
        ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
