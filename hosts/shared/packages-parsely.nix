pkgs:
with pkgs; let
  # Define a custom terraform so I can control the specific version
  terraform-mine = pkgs.mkTerraform {
    version = "1.4.5";
    hash = "sha256-mnJ9d3UHAZxmz0i7PH0JF5gA3m3nJxM2NyAn0J0L6u8=";
    vendorHash = "sha256-3ZQcWatJlQ6NVoPL/7cKQO6+YCSM3Ld77iLEQK3jBDE=";
  };
in [
  awscli2
  jdk8_headless
  leiningen
  unstable.nomad
  openvpn
  terraform-mine
  wander
]
