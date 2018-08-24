{ mkDerivation, base, bytestring, Cabal, data-default-class
, fetchgit, hpack, HUnit, lens-family, lens-family-core
, lens-labels, pretty, proto-lens, proto-lens-arbitrary
, proto-lens-protobuf-types, proto-lens-runtime, proto-lens-setup
, proto-lens-tests-dep, QuickCheck, stdenv, test-framework
, test-framework-hunit, test-framework-quickcheck2, text
}:
mkDerivation {
  pname = "proto-lens-tests";
  version = "0.1.0.1";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-tests; echo source root reset to $sourceRoot";
  setupHaskellDepends = [ base Cabal proto-lens-setup ];
  libraryHaskellDepends = [
    base bytestring data-default-class HUnit lens-family pretty
    proto-lens proto-lens-arbitrary proto-lens-runtime QuickCheck
    test-framework test-framework-hunit test-framework-quickcheck2 text
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base bytestring data-default-class HUnit lens-family
    lens-family-core lens-labels pretty proto-lens proto-lens-arbitrary
    proto-lens-protobuf-types proto-lens-runtime proto-lens-tests-dep
    QuickCheck test-framework test-framework-hunit
    test-framework-quickcheck2 text
  ];
  preConfigure = "hpack";
  description = "Unit tests for proto-lens";
  license = stdenv.lib.licenses.bsd3;
}
