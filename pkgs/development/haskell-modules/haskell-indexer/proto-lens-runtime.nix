{ mkDerivation, base, bytestring, containers, data-default-class
, fetchgit, filepath, hpack, lens-family, lens-labels, proto-lens
, stdenv, text
}:
mkDerivation {
  pname = "proto-lens-runtime";
  version = "0.4.0.0";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-runtime; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring containers data-default-class filepath lens-family
    lens-labels proto-lens text
  ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  license = stdenv.lib.licenses.bsd3;
}
