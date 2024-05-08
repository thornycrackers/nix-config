{ vimUtils
, fetchFromGitHub
,
}:
vimUtils.buildVimPlugin {
  pname = "vim-angry-reviewer";
  version = "2022-06-13";
  src = fetchFromGitHub {
    owner = "anufrievroman";
    repo = "vim-angry-reviewer";
    rev = "9bf1179";
    sha256 = "sha256-06V+aAnL2ER5yP26VQWVRP0yB4SpB28RX4K38bm52y4=";
  };
  meta.homepage = "https://github.com/anufrievroman/vim-angry-reviewer";
}
