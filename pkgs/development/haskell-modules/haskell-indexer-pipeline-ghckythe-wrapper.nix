{ mkDerivation, base, bytestring, fetchgit
, haskell-indexer-backend-core, haskell-indexer-backend-ghc
, haskell-indexer-pathutil, haskell-indexer-pipeline-ghckythe
, kythe-schema, optparse-applicative, proto-lens, stdenv, text
}:
mkDerivation {
  pname = "haskell-indexer-pipeline-ghckythe-wrapper";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = "sourceRoot+=/haskell-indexer-pipeline-ghckythe-wrapper; echo source root reset to $sourceRoot";
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base bytestring haskell-indexer-backend-core
    haskell-indexer-backend-ghc haskell-indexer-pathutil
    haskell-indexer-pipeline-ghckythe kythe-schema optparse-applicative
    proto-lens text
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Executable able to take GHC arguments and emitting Kythe entries";
  license = stdenv.lib.licenses.asl20;
}
