{ haskell-indexer-src, mkDerivation, base, bytestring, containers, directory, filepath
, ghc, ghc-paths, hashable, haskell-indexer-backend-core
, haskell-indexer-translate, HUnit, mtl, reflection, semigroups
, stdenv, temporary, test-framework, test-framework-hunit, text
, text-offset, transformers, unix, unordered-containers
}:
mkDerivation rec {
  pname = "haskell-indexer-backend-ghc";
  version = "0.1.0.0";
  src = haskell-indexer-src + "/${pname}";
  # postUnpack = "sourceRoot+=/haskell-indexer-backend-ghc; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base containers directory filepath ghc ghc-paths hashable
    haskell-indexer-backend-core haskell-indexer-translate mtl
    reflection text transformers unix unordered-containers
  ];
  testHaskellDepends = [
    base bytestring filepath ghc haskell-indexer-backend-core
    haskell-indexer-translate HUnit semigroups temporary
    test-framework test-framework-hunit text text-offset transformers
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Indexing code using GHC API";
  license = stdenv.lib.licenses.asl20;
}
