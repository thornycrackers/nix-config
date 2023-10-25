{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPluginFrom2Nix rec {
  pname = "hmts.nvim";
  version = "1.2.2";
  src = fetchFromGitHub {
    owner = "calops";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-jUuztOqNBltC3axa7s3CPJz9Cmukfwkf846+Z/gAxCU=";
  };
  meta.homepage = "https://github.com/calops/hmts.nvim";
}
