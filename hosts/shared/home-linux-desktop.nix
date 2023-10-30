{
  pkgs,
  inputs,
  username,
  homedirectory,
  ...
}: {
  imports = [./home-base.nix];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${username}";
  home.homeDirectory = "${homedirectory}";

  # Wrapper packages via wrapper-manager
  # There's no hard or fast rules for when to use home manager vs wrapper manager.
  # I guess the best heuristic is how much I want to customize in the tool?
  home.packages = [
    (inputs.wrapper-manager.lib.build {
      inherit pkgs;
      modules = [../../src/bat ../../src/tmux];
    })
  ];

  # TODO: This is just "whatever" for now, clean it up later
  xdg.configFile."i3/config".source = ../../src/i3/config;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
