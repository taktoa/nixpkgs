{ haskell-indexer-src, mkDerivation, base, bytestring, fetchgit, filepath, stdenv, text
}:
mkDerivation rec {
  pname = "haskell-indexer-translate";
  version = "0.1.0.0";
  src = haskell-indexer-src + "/${pname}";
  # postUnpack = "sourceRoot+=/haskell-indexer-translate; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [ base bytestring filepath text ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Translation layer isolating compiler backends from frontends";
  license = stdenv.lib.licenses.asl20;
}
