{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  pname = "obsidian-nvim";
  version = "2026-04-09";
  src = fetchFromGitHub {
    owner = "thornycrackers";
    repo = "obsidian.nvim";
    rev = "main";
    sha256 = "";
  };
  meta.homepage = "https://github.com/thornycrackers/obsidian.nvim";
}
