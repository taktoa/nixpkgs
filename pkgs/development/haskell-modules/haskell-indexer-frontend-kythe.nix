{ mkDerivation, base, bytestring, conduit, fetchgit
, haskell-indexer-translate, kythe-schema, mmorph, mtl, stdenv
, text, text-offset, transformers
}:
mkDerivation {
  pname = "haskell-indexer-frontend-kythe";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = "sourceRoot+=/haskell-indexer-frontend-kythe; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring conduit haskell-indexer-translate kythe-schema
    mmorph mtl text text-offset transformers
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Emits Kythe schema based on translation layer data";
  license = stdenv.lib.licenses.asl20;
}
