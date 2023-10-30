# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  flakePkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "snow"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thorny = {
    home = "/home/thorny";
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "thorny";
    extraGroups = ["networkmanager" "jackaudio" "wheel" "docker"];
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
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; let
    basePackages = import ../../hosts/shared/packages-base.nix pkgs;
    parselyPackages = import ../../hosts/shared/packages-parsely.nix pkgs;
    localPackages = [flakePkgs.myneovim];
    # TODO: At some point these should be broken out like the above
    desktopPackages = [
      kitty
      # Desktop xfce things
      xfce.xfce4-panel
      xfce.xfce4-i3-workspaces-plugin
      xfce.xfce4-screensaver
      nitrogen
      # GUI Apps
      firefox-devedition-bin
      spotify
      slack
      # Sound
      qjackctl

      (pass.withExtensions (ext: with ext; [pass-otp]))
    ];
  in
    lib.mkMerge [basePackages parselyPackages localPackages desktopPackages];

  # Services
  services = {
    # Use i3 with xfce
    xserver = {
      enable = true;
      #autorun = true;
      displayManager = {defaultSession = "xfce+i3";};
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
    };
    openssh = {enable = true;};
    # Enable pipewire to take care of everything
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  # gtk2 is the most reliable out all the other flavors that I've tried so far
  # so I stick with it
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  # Enable docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}