{ haskell-indexer-src, mkDerivation, base, fetchgit, filepath, stdenv, text }:
mkDerivation rec {
  pname = "haskell-indexer-pathutil";
  version = "0.1.0.0";
  src = haskell-indexer-src + "/${pname}";
  # postUnpack = "sourceRoot+=/haskell-indexer-pathutil; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [ base filepath text ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Utilities for dealing with filepaths";
  license = stdenv.lib.licenses.asl20;
}
