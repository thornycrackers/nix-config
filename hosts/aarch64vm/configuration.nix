{ modulesPath, config, pkgs, ... }: {
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

