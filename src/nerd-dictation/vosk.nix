{
  lib,
  buildPythonPackage,
  fetchPypi,
  autoPatchelfHook,
  stdenv,
  cffi,
  requests,
  tqdm,
  srt,
  websockets,
}:
# nixpkgs doesn't package the vosk Python binding, so we install the upstream
# PyPI wheel directly. The wheel bundles a prebuilt `libvosk.so`, hence the
# autoPatchelfHook + libstdc++/libgomp (from cc.cc.lib) to fix its rpath.
#
# This is the linux x86_64 wheel only (the desktop host is x86_64). For another
# platform, swap `platform` for the matching wheel tag and update the hash.
buildPythonPackage rec {
  pname = "vosk";
  version = "0.3.45";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    abi = "none";
    platform = "manylinux_2_12_x86_64.manylinux2010_x86_64";
    hash = "sha256-JeAlCTxDmdcnj1Q1aO2MxUYKw6S/SMI2c6zh4l0mYZ8=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  propagatedBuildInputs = [
    cffi
    requests
    tqdm
    srt
    websockets
  ];

  pythonImportsCheck = [ "vosk" ];

  meta = with lib; {
    description = "Offline speech recognition Python API for Kaldi and Vosk";
    homepage = "https://github.com/alphacep/vosk-api";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
