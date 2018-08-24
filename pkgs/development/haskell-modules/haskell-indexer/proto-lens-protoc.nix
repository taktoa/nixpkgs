{ mkDerivation, base, bytestring, containers, data-default-class
, fetchgit, filepath, haskell-src-exts, hpack, lens-family, pretty
, proto-lens, stdenv, text
}:
mkDerivation {
  pname = "proto-lens-protoc";
  version = "0.4.0.0";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-protoc; echo source root reset to $sourceRoot";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base containers filepath haskell-src-exts lens-family pretty
    proto-lens text
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base bytestring containers data-default-class lens-family
    proto-lens text
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Protocol buffer compiler for the proto-lens library";
  license = stdenv.lib.licenses.bsd3;
}
