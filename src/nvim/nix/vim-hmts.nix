{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin rec {
  pname = "hmts.nvim";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "calops";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-j/RFJgCbaH+V2K20RrQbsz0bzpN8Z6YAKzZMABYg/OU=";
  };
  meta.homepage = "https://github.com/calops/hmts.nvim";
}
