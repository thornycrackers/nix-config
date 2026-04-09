{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  pname = "obsidian-nvim";
  version = "2026-04-09";
  src = fetchFromGitHub {
    owner = "thornycrackers";
    repo = "obsidian.nvim";
    rev = "main";
    sha256 = "sha256-ZWbkqW+nGS6PY7ycaU5S/XK7XZJU6tgSetukxcRUA8M=";
  };
  nvimRequireCheck = "obsidian";
  meta.homepage = "https://github.com/thornycrackers/obsidian.nvim";
}
