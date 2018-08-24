{ mkDerivation, base, bytestring, containers, fetchgit, hpack
, lens-family, proto-lens, QuickCheck, stdenv, text
}:
mkDerivation {
  pname = "proto-lens-arbitrary";
  version = "0.1.2.2";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-arbitrary; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring containers lens-family proto-lens QuickCheck text
  ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Arbitrary instances for proto-lens";
  license = stdenv.lib.licenses.bsd3;
}
