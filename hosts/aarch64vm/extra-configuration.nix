{config, pkgs, ... }: {

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

  services = {
    openssh = {
      enable = true;
    };
  };
}
