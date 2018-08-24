{ mkDerivation, base, Cabal, data-default-class, fetchgit, hpack
, HUnit, lens-family, lens-family-core, proto-lens
, proto-lens-runtime, proto-lens-setup, stdenv, test-framework
, test-framework-hunit, transformers
}:
mkDerivation {
  pname = "proto-lens-combinators";
  version = "0.1.0.12";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-combinators; echo source root reset to $sourceRoot";
  setupHaskellDepends = [ base Cabal proto-lens-setup ];
  libraryHaskellDepends = [
    base data-default-class lens-family transformers
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base HUnit lens-family lens-family-core proto-lens
    proto-lens-runtime test-framework test-framework-hunit
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Utilities functions to proto-lens";
  license = stdenv.lib.licenses.bsd3;
}
