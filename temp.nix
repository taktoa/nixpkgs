rec {
  pkgs = import ./default.nix {
    config = {};
    overlays = [];
  };

  indexed = hp: hp.override {
    overrides = self: super: {
      mkDerivation = args: super.mkDerivation (args // {
        doIndexer = true;
        doCheck = false;
        configureFlags = (args.configureFlags or []) ++ [
          "--disable-optimization"
        ];
      });
    };
  };

  indexedHP = indexed pkgs.haskellPackages;

  vectorIndex = indexedHP.vector;
  lensIndex = indexedHP.lens;
  reflectionIndex = indexedHP.reflection;

  haskell-indexer-wrapper = (
    import ./pkgs/development/haskell-modules/haskell-indexer-wrapper.nix {
      stdenv = pkgs.stdenv;
      # haskellPackages = pkgs.haskell.packages.ghc802;
      haskellPackages = pkgs.haskell.packages.ghc843;
    });

  # ghc802Fast = (pkgs.haskell.compiler.ghc802.overrideAttrs (old: {
  #   patches = (old.patches or []) ++ [
  #     ./pkgs/development/compilers/ghc/quick-build-flavour.patch
  #     ./temporary.patch
  #   ];
  #   configureFlags = (old.configureFlags or []) ++ [
  #     "--with-ghc=${haskell-indexer-wrapper}/bin/ghc-8.0.2"
  #   ];
  #   enableParallelBuilding = true;
  #   doCheck = false;
  #   NIX_HASKELL_PACKAGE_NAME    = "ghc";
  #   NIX_HASKELL_PACKAGE_VERSION = old.version;
  #   # buildPhase = ''
  #   #   make -C ghc 1
  #   # '';
  #   installPhase = ''
  #     mkdir -pv "$out"
  #     mkdir -pv "$doc"
  #     mkdir -pv "$man"
  #   '';
  # })).override { bootPkgs = pkgs.haskell.packages.ghc802; };
}
