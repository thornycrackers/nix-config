{ modulesPath, config, pkgs, ... }: {
  # NOTE: Initial configuration when loading up a nixos blank nixos aarch64 vm.
  # I'm sure there is a better way to do this, but haven't figured it out yet.
  # When I first boot up the aarch64 machine, I copy this file to
  # /etc/nixos/configuration.nix and install these base packages. This give me
  # everything I need to get ready for a flakes install. After this I will
  # symlink all the flakes stuff and bootstrap based on the hostname.
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.efi = true;
  networking.hostName = "aarch64vm";
  environment.systemPackages = with pkgs; [
    bash
    git
    gitAndTools.delta
    fzf
    vim
  ];
  users.users.root = {
    shell = pkgs.zsh;
    home = "/root";
  };
  programs.zsh.enable = true;
}

