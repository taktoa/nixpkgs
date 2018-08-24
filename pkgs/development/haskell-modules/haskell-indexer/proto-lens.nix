{ mkDerivation, attoparsec, base, bytestring, containers
, data-default-class, deepseq, fetchgit, hpack, lens-family
, lens-labels, parsec, pretty, stdenv, text, transformers, void
}:
mkDerivation {
  pname = "proto-lens";
  version = "0.3.1.1";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens; echo source root reset to $sourceRoot";
  enableSeparateDataOutput = true;
  libraryHaskellDepends = [
    attoparsec base bytestring containers data-default-class deepseq
    lens-family lens-labels parsec pretty text transformers void
  ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "A lens-based implementation of protocol buffers in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
