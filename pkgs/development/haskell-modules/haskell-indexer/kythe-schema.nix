{ haskell-indexer-src, mkDerivation, base, bytestring, data-default, fetchgit
, kythe-proto, lens-family, proto-lens, proto-lens-combinators
, stdenv, text
}:
mkDerivation rec {
  pname = "kythe-schema";
  version = "0.1.0.0";
  src = haskell-indexer-src + "/${pname}";
  # postUnpack = "sourceRoot+=/kythe-schema; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring data-default kythe-proto lens-family proto-lens
    proto-lens-combinators text
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Library for emitting Kythe schema entries";
  license = stdenv.lib.licenses.asl20;
}
