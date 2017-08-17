{ mkDerivation, base, bytestring, fetchgit, HUnit, QuickCheck
, stdenv, test-framework, test-framework-hunit
, test-framework-quickcheck2, text, vector
}:
mkDerivation {
  pname = "text-offset";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = "sourceRoot+=/text-offset; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [ base text vector ];
  testHaskellDepends = [
    base bytestring HUnit QuickCheck test-framework
    test-framework-hunit test-framework-quickcheck2 text
  ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Library for converting between line/column and byte offset";
  license = stdenv.lib.licenses.asl20;
}
