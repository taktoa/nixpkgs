{ mkDerivation, base, bytestring, Cabal, containers, deepseq
, directory, fetchgit, filepath, hpack, process, proto-lens-protoc
, stdenv, temporary, text
}:
mkDerivation {
  pname = "proto-lens-setup";
  version = "0.4.0.0";
  src = fetchgit {
    url = "https://github.com/google/proto-lens.git";
    sha256 = "11kkc59ml1a4fkwwfccgfam98rj07q7x5q8ciali6hiav5xwch4n";
    rev = "591a8fafd2ee94e606d527dcb83392d811c24f8b";
  };
  postUnpack = "sourceRoot+=/proto-lens-setup; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    base bytestring Cabal containers deepseq directory filepath process
    proto-lens-protoc temporary text
  ];
  libraryToolDepends = [ hpack ];
  preConfigure = "hpack";
  homepage = "https://github.com/google/proto-lens#readme";
  description = "Cabal support for codegen with proto-lens";
  license = stdenv.lib.licenses.bsd3;
}
