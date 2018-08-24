{ mkDerivation, base, contravariant, data-binary-ieee754
, discrimination, fetchgit, hpack, QuickCheck, stdenv
, test-framework, test-framework-quickcheck2
}:
mkDerivation {
  pname = "discrimination-ieee754";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/discrimination-ieee754; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base contravariant data-binary-ieee754 discrimination
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base contravariant data-binary-ieee754 discrimination QuickCheck
    test-framework test-framework-quickcheck2
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Discrimination of floating-point numbers via their IEEE754 representation";
  license = stdenv.lib.licenses.bsd3;
}
