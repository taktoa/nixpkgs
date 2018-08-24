{ mkDerivation, base, Cabal, fetchgit, hpack, proto-lens-runtime
, proto-lens-setup, stdenv
}:
mkDerivation {
  pname = "proto-lens-tests-dep";
  version = "0.1.0.1";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-tests-dep; echo source root reset to $sourceRoot";
  setupHaskellDepends = [ base Cabal proto-lens-setup ];
  libraryHaskellDepends = [ base proto-lens-runtime ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Test package dependency";
  license = stdenv.lib.licenses.bsd3;
}
