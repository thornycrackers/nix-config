{ modulesPath, config, pkgs, ... }: {
  imports = [ "\${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.efi = true;
  networking.hostName = "aarch64";
  environment.systemPackages = with pkgs; [
    bash
    git
    gitAndTools.delta
    fzf
    vim
  ];
}

