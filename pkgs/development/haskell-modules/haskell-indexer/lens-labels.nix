{ mkDerivation, base, fetchgit, ghc-prim, hpack, profunctors
, stdenv, tagged
}:
mkDerivation {
  pname = "lens-labels";
  version = "0.2.0.2";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/lens-labels; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [ base ghc-prim profunctors tagged ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Integration of lenses with OverloadedLabels";
  license = stdenv.lib.licenses.bsd3;
}
