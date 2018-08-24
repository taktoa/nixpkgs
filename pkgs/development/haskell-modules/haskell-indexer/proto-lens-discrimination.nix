{ mkDerivation, base, bytestring, Cabal, containers, contravariant
, data-default, discrimination, discrimination-ieee754, fetchgit
, hpack, HUnit, lens-family, proto-lens, proto-lens-arbitrary
, proto-lens-runtime, proto-lens-setup, stdenv, test-framework
, test-framework-hunit, test-framework-quickcheck2, text
}:
mkDerivation {
  pname = "proto-lens-discrimination";
  version = "0.1.1.0";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-discrimination; echo source root reset to $sourceRoot";
  setupHaskellDepends = [ base Cabal proto-lens-setup ];
  libraryHaskellDepends = [
    base bytestring containers contravariant data-default
    discrimination discrimination-ieee754 lens-family proto-lens
    proto-lens-runtime text
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base bytestring containers contravariant data-default
    discrimination discrimination-ieee754 HUnit lens-family proto-lens
    proto-lens-arbitrary proto-lens-runtime test-framework
    test-framework-hunit test-framework-quickcheck2 text
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Support for using proto-lens types with http://hackage.haskell.org/package/discrimination.";
  license = stdenv.lib.licenses.bsd3;
}
