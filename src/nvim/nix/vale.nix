{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "vale";
  version = "2.17.0";
  subPackages = [ "cmd/vale" ];
  outputs = [
    "out"
    "data"
  ];
  src = fetchFromGitHub {
    owner = "errata-ai";
    repo = "vale";
    rev = "v${version}";
    sha256 = "sha256-PUaIx6rEaLz0HUxkglsVHw0Kx/ovI2f4Yhknuysr5Gs=";
  };
  vendorHash = "sha256-zdgLWEArmtHTDM844LoSJwKp0UGoAR8bHnFOSlrrjdg=";
  postInstall = ''
    mkdir -p $data/share/vale
    cp -r styles $data/share/vale
  '';
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];
}
