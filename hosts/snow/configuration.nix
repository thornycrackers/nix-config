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

  # Define your hostname.
  networking.hostName = "snow";

  # Enable networking
  networking.networkmanager.enable = true;

  # Use nftables
  networking.nftables.enable = true;

  # Don't block DHCP requests to the Incus network and allow for Vagrant DHCP
  networking.firewall.trustedInterfaces = [
    "incusbr0"
    "virbr0"
    "virbr1"
    "virbr2"
  ];

  # Don't let NetworkManager manage libvirt bridges (prevents conflicts)
  networking.networkmanager.unmanaged = [
    "virbr0"
    "virbr1"
    "virbr2"
  ];

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Instal DejaVuSansMono nerd font
  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "DejaVuSansMono" ]; }) ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.thorny.gid = 1000;
  users.users.thorny = {
    home = "/home/thorny";
    isNormalUser = true;
    shell = pkgs.bash;
    description = "thorny";
    extraGroups = [
      "networkmanager"
      "jackaudio"
      "wheel"
      "docker"
      "libvirtd"
      "incus-admin"
      "openrazer"
    ];
    # Required for the docker rootless
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
    # Also required for the docker rootless
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    with pkgs;
    let
      basePackages = import ../../hosts/shared/packages-base.nix pkgs;
      parselyPackages = import ../../hosts/shared/packages-parsely.nix pkgs;
      desktopPackages = import ../../hosts/shared/packages-linux-desktop.nix pkgs;
      localPackages = [ flakePkgs.myneovim ];
    in
    lib.mkMerge [
      basePackages
      parselyPackages
      localPackages
      desktopPackages
    ];

  # Graphical settings. Use i3 to manage windows but xfce as a desktop manager.
  services = {
    displayManager = {
      defaultSession = "xfce+i3";
    };
    xserver = {
      enable = true;
      windowManager = {
        i3 = {
          enable = true;
          package = pkgs.i3-gaps;
        };
      };
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      videoDrivers = [ "nvidia" ];
    };
    openssh = {
      enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
    protonmail-bridge = {
      enable = true;
    };
    tailscale.enable = true;
    espanso.enable = true;
  };

  # gtk2 is the most reliable out all the other flavors that I've tried so far
  # so I stick with it
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSSHSupport = true;
  };

  # virtualisation stuff I want enabled
  virtualisation = {
    docker = {
      enable = true;
      # Be aware that if you try running namespaced docker with nomad, nomad can run into issues
      extraOptions = "--userns-remap=thorny:100";
    };
    # Enable virtd for virtualization
    libvirtd = {
      enable = true;
      # Auto-start networks
      onBoot = "start";
      onShutdown = "shutdown";
    };
    # Enable incus for easier
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

  # When I shutdown the computer, docker takes forever and the default is 90s.
  # I don't feel like waiting more than 10 seconds.
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  programs.steam = {
    enable = true;
    # Let pipewire handle the sound
    package = pkgs.steam.override { extraLibraries = pkgs: [ pkgs.pipewire ]; };
  };

  programs.noisetorch.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
