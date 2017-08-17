{ stdenv, haskellPackages }:

with { wrapper = haskellPackages.haskell-indexer-pipeline-ghckythe-wrapper; };

stdenv.mkDerivation {
  name = "haskell-indexer-wrapper-0.1";
  src = ./ghc_wrapper.sh;
  buildInputs = [ wrapper ]; # FIXME: should not be necessary
  unpackPhase = ''
    cp "$src" ./ghc-wrapper.sh
  '';
  patchPhase = ''
    sed -i "s|ghc_kythe_wrapper|${wrapper}/bin/ghc_kythe_wrapper|" ./ghc-wrapper.sh
  '';
  installPhase = ''
    mkdir -p "$out/bin"
    for binary in ${haskellPackages.ghc}/bin/*; do
        ln -sv "$binary" "$out/bin/$(basename "$binary")"
    done
    rm -v "$out/bin/ghc"
    rm -v "$out/bin/ghc-${haskellPackages.ghc.version}"
    install -m755 -D ./ghc-wrapper.sh "$out/bin/ghc-8.0.2"
    ln -sv "$out/bin/ghc-8.0.2" "$out/bin/ghc"
  '';
  inherit (haskellPackages.ghc) meta;
}
