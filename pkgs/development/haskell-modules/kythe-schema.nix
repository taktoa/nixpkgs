{ mkDerivation, base, bytestring, data-default, fetchgit
, kythe-proto, lens-family, proto-lens, proto-lens-combinators
, stdenv, text
}:
mkDerivation {
  pname = "kythe-schema";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = "sourceRoot+=/kythe-schema; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring data-default kythe-proto lens-family proto-lens
    proto-lens-combinators text
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Library for emitting Kythe schema entries";
  license = stdenv.lib.licenses.asl20;
}
