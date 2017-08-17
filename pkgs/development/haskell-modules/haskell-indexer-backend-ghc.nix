{ mkDerivation, base, bytestring, containers, fetchgit, filepath
, ghc, ghc-paths, hashable, haskell-indexer-backend-core
, haskell-indexer-translate, HUnit, mtl, reflection, semigroups
, stdenv, test-framework, test-framework-hunit, text, text-offset
, transformers, unix, unordered-containers
}:
mkDerivation {
  pname = "haskell-indexer-backend-ghc";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = "sourceRoot+=/haskell-indexer-backend-ghc; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base containers filepath ghc ghc-paths hashable
    haskell-indexer-backend-core haskell-indexer-translate mtl
    reflection text transformers unix unordered-containers
  ];
  testHaskellDepends = [
    base bytestring filepath ghc haskell-indexer-backend-core
    haskell-indexer-translate HUnit semigroups test-framework
    test-framework-hunit text text-offset transformers
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Indexing code using GHC API";
  license = stdenv.lib.licenses.asl20;
}
