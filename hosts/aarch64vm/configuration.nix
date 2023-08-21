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

  # Enable flakes
  # Keep outputs and derivations for nix-direnv
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  services = { openssh = { enable = true; }; };

  virtualisation.docker.enable = true;
}
