{ haskell-indexer-src, mkDerivation, base, Cabal, fetchgit, proto-lens-runtime, proto-lens-setup, stdenv, kythe }:
mkDerivation rec {
  pname = "kythe-proto";
  version = "0.1.0.0";
  src = haskell-indexer-src + "/${pname}";
  postUnpack = ''
    rm -r $sourceRoot/third_party
    mkdir -pv $sourceRoot/third_party/kythe
    cp -r ${kythe} $sourceRoot/third_party/kythe/kythe
    chmod 755 -R $sourceRoot/third_party/kythe
  '';
  setupHaskellDepends = [ base Cabal proto-lens-setup ];
  libraryHaskellDepends = [ base proto-lens-runtime ];
  homepage = "https://github.com/google/haskell-indexer";
  description = "Proto bindings for Kythe protobufs";
  license = stdenv.lib.licenses.asl20;
}
