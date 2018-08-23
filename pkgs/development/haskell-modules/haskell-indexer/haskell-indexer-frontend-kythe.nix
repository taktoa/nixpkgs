{ haskell-indexer-src, mkDerivation, base, bytestring, conduit
, haskell-indexer-translate, kythe-schema, mmorph, mtl, stdenv
, text, text-offset, transformers
}:
mkDerivation rec {
  pname = "haskell-indexer-frontend-kythe";
  version = "0.1.0.0";
  src = haskell-indexer-src + "/${pname}";
  # postUnpack = "sourceRoot+=/haskell-indexer-frontend-kythe; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring conduit haskell-indexer-translate kythe-schema
    mmorph mtl text text-offset transformers
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Emits Kythe schema based on translation layer data";
  license = stdenv.lib.licenses.asl20;
}
