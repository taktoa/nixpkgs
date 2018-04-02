{ mkDerivation, base, fetchgit, filepath, stdenv, text }:
mkDerivation {
  pname = "haskell-indexer-pathutil";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = "sourceRoot+=/haskell-indexer-pathutil; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [ base filepath text ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Utilities for dealing with filepaths";
  license = stdenv.lib.licenses.asl20;
}
