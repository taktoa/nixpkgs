{ mkDerivation, base, Cabal, fetchgit, proto-lens-protoc, stdenv, kythe}:
mkDerivation {
  pname = "kythe-proto";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/mpickering/haskell-indexer";
    sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
    rev = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
  };
  postUnpack = ''sourceRoot+=/kythe-proto; echo source root reset to $sourceRoot
                rm -r $sourceRoot/third_party
                mkdir -pv $sourceRoot/third_party/kythe
                cp -r ${kythe} $sourceRoot/third_party/kythe/kythe
                chmod 755 -R $sourceRoot/third_party/kythe
                '';
  setupHaskellDepends = [ base Cabal proto-lens-protoc ];
  libraryHaskellDepends = [ base proto-lens-protoc ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Proto bindings for Kythe protobufs";
  license = stdenv.lib.licenses.asl20;
}
