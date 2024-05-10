{
  buildPythonPackage,
  fetchPypi,
  python3Packages,
}:
buildPythonPackage rec {
  pname = "flake8-isort";
  version = "6.0.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-U39FOmYNfpA/YC7Po2E2sUDeJ531jQLrG2oMhOg8Uow=";
  };
  propagatedBuildInputs = with python3Packages; [ setuptools ];
  checkInputs = with python3Packages; [
    flake8
    isort
    pytest
  ];
}
