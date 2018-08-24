{ mkDerivation, base, bytestring, Cabal, criterion, deepseq
, fetchgit, hpack, lens-family, lens-family-core
, optparse-applicative, proto-lens, proto-lens-runtime
, proto-lens-setup, stdenv, text
}:
mkDerivation {
  pname = "proto-lens-benchmarks";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-benchmarks; echo source root reset to $sourceRoot";
  setupHaskellDepends = [ base Cabal proto-lens-setup ];
  libraryHaskellDepends = [
    base bytestring criterion deepseq lens-family lens-family-core
    optparse-applicative proto-lens proto-lens-runtime text
  ];
  libraryToolDepends = [ hpack ];
  benchmarkHaskellDepends = [
    base criterion deepseq lens-family lens-family-core proto-lens
    proto-lens-runtime text
  ];
  preConfigure = "hpack";
  description = "Benchmarks for proto-lens";
  license = stdenv.lib.licenses.bsd3;
}
