{ mkDerivation, base, bytestring, conduit, fetchgit, filepath
, haskell-indexer-backend-core, haskell-indexer-backend-ghc
, haskell-indexer-frontend-kythe, haskell-indexer-translate
, kythe-schema, mmorph, mtl, stdenv, text
}:
mkDerivation {
  pname = "haskell-indexer-pipeline-ghckythe";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = "sourceRoot+=/haskell-indexer-pipeline-ghckythe; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring conduit filepath haskell-indexer-backend-core
    haskell-indexer-backend-ghc haskell-indexer-frontend-kythe
    haskell-indexer-translate kythe-schema mmorph mtl text
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Gets GHC invocation arguments and streams Kythe entries";
  license = stdenv.lib.licenses.asl20;
}
