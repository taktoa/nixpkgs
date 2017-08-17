{ lib, stdenv, hoogle, writeText, ghc
, packages, kythe
}:

let
  inherit (stdenv.lib) optional;
  wrapper = ./haskell-indexer-wrapper.sh;
  isGhcjs = ghc.isGhcjs or false;
  opts = lib.optionalString;
  haddockExe =
    if !isGhcjs
    then "haddock"
    else "haddock-ghcjs";
  ghcName =
    if !isGhcjs
    then "ghc"
    else "ghcjs";
  ghcDocLibDir =
    if !isGhcjs
    then ghc.doc + ''/share/doc/ghc*/html/libraries''
    else ghc     + ''/doc/lib'';
  # On GHCJS, use a stripped down version of GHC's prologue.txt
  prologue =
    if !isGhcjs
    then "${ghcDocLibDir}/prologue.txt"
    else writeText "ghcjs-prologue.txt" ''
      This index includes documentation for many Haskell modules.
    '';

  docPackages = lib.closePropagation packages;

in
stdenv.mkDerivation {
  name = "haskell-indexer-local-0.1";
  buildInputs = [ghc kythe];

  phases = [ "buildPhase" ];

  inherit docPackages;

  buildPhase = ''
    mkdir -p $out/share

    echo importing other packages
    for i in $docPackages; do
      if [[ ! $i == $out ]]; then
        for efile in $i/logs/*.entries; do
          echo $efile
          ${kythe}/tools/write_entries --graphstore "$out/share/gs" < "$efile"
        done
      fi
    done
    echo done

    ${kythe}/tools/write_tables --graphstore "$out/share/gs" \
                                --out "$out/share/tbl" \
                                --compress_shards


    echo finishing up
    mkdir -p $out/bin
    substitute ${wrapper} $out/bin/serve \
      --subst-var out --subst-var-by shell ${stdenv.shell} \
      --subst-var-by kythe ${kythe}
    chmod +x $out/bin/serve
  '';

  passthru = {
    isHaskellLibrary = false; # for the filter in ./with-packages-wrapper.nix
  };

  meta = {
    description = "A local haskell-indexer database";
    platforms = ghc.meta.platforms;
    hydraPlatforms = with stdenv.lib.platforms; none;
    maintainers = with stdenv.lib.maintainers; [ mpickering ];
  };
}
