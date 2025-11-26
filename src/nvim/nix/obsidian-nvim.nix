{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  pname = "obsidian-nvim";
  version = "2024-01-01";
  src = fetchFromGitHub {
    owner = "Thornycrackers-Forks";
    repo = "obsidian.nvim";
    rev = "main";
    sha256 = "sha256-9f7YoKtXr6SBJCTCTQvY6Pl14P/v0hC9JaKvcjr6FLQ=";
  };
  meta.homepage = "https://github.com/Thornycrackers-Forks/obsidian.nvim";
}
