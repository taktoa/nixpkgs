{ mkDerivation, base, fetchgit, hpack, optparse-applicative
, proto-lens, stdenv, text
}:
mkDerivation {
  pname = "proto-lens-optparse";
  version = "0.1.1.2";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-optparse; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base optparse-applicative proto-lens text
  ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Adapting proto-lens to optparse-applicative ReadMs";
  license = stdenv.lib.licenses.bsd3;
}
