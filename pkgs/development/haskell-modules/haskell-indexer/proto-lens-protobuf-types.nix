{ mkDerivation, base, Cabal, fetchgit, hpack, lens-labels
, proto-lens, proto-lens-runtime, proto-lens-setup, stdenv, text
}:
mkDerivation {
  pname = "proto-lens-protobuf-types";
  version = "0.3.0.3";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-protobuf-types; echo source root reset to $sourceRoot";
  setupHaskellDepends = [ base Cabal proto-lens-setup ];
  libraryHaskellDepends = [
    base lens-labels proto-lens proto-lens-runtime text
  ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Basic protocol buffer message types";
  license = stdenv.lib.licenses.bsd3;
}
