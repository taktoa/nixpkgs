{ pkgs, haskellLib }:

with haskellLib;

self: super: {

  # Suitable LLVM version.
  llvmPackages = pkgs.llvmPackages_35;

  # Disable GHC 8.0.x core libraries.
  array = null;
  base = null;
  binary = null;
  bytestring = null;
  Cabal = null;
  containers = null;
  deepseq = null;
  directory = null;
  filepath = null;
  ghc-boot = null;
  ghc-boot-th = null;
  ghc-prim = null;
  ghci = null;
  haskeline = null;
  hoopl = null;
  hpc = null;
  integer-gmp = null;
  pretty = null;
  process = null;
  rts = null;
  template-haskell = null;
  terminfo = null;
  time = null;
  transformers = null;
  unix = null;
  xhtml = null;

  # jailbreak-cabal can use the native Cabal library.
  jailbreak-cabal = super.jailbreak-cabal.override { Cabal = null; };

  # https://github.com/bmillwood/applicative-quoters/issues/6
  applicative-quoters = appendPatch super.applicative-quoters (pkgs.fetchpatch {
    url = "https://patch-diff.githubusercontent.com/raw/bmillwood/applicative-quoters/pull/7.patch";
    sha256 = "026vv2k3ks73jngwifszv8l59clg88pcdr4mz0wr0gamivkfa1zy";
  });

  # Requires ghc 8.2
  ghc-proofs = dontDistribute super.ghc-proofs;

  # http://hub.darcs.net/dolio/vector-algorithms/issue/9#comment-20170112T145715
  vector-algorithms = dontCheck super.vector-algorithms;

  # https://github.com/thoughtbot/yesod-auth-oauth2/pull/77
  yesod-auth-oauth2 = doJailbreak super.yesod-auth-oauth2;

  # https://github.com/nominolo/ghc-syb/issues/20
  ghc-syb-utils = dontCheck super.ghc-syb-utils;

  # Newer versions require ghc>=8.2
  apply-refact = super.apply-refact_0_3_0_1;

  # This builds needs the latest Cabal version.
  cabal2nix = super.cabal2nix.overrideScope (self: super: { Cabal = self.Cabal_2_0_0_2; });

  proto-lens             = pkgs.haskell.lib.addBuildTool super.proto-lens             pkgs.protobuf3_1;
  proto-lens-descriptors = pkgs.haskell.lib.addBuildTool super.proto-lens-descriptors pkgs.protobuf3_1;
  proto-lens-protoc      = pkgs.haskell.lib.addBuildTool super.proto-lens-protoc      pkgs.protobuf3_1;
  proto-lens-combinators = pkgs.haskell.lib.addBuildTool super.proto-lens-combinators pkgs.protobuf3_1;

  haskell-indexer-backend-core              = pkgs.haskell.lib.doJailbreak (super.callPackage ./haskell-indexer-backend-core.nix {});
  haskell-indexer-backend-ghc               = pkgs.haskell.lib.doJailbreak (super.callPackage ./haskell-indexer-backend-ghc.nix {});
  haskell-indexer-frontend-kythe            = pkgs.haskell.lib.doJailbreak (super.callPackage ./haskell-indexer-frontend-kythe.nix {});
  haskell-indexer-pathutil                  = pkgs.haskell.lib.doJailbreak (super.callPackage ./haskell-indexer-pathutil.nix {});
  haskell-indexer-pipeline-ghckythe-wrapper = super.callPackage ./haskell-indexer-pipeline-ghckythe-wrapper.nix {};
  haskell-indexer-pipeline-ghckythe         = pkgs.haskell.lib.doJailbreak (super.callPackage ./haskell-indexer-pipeline-ghckythe.nix {});
  haskell-indexer-translate                 = pkgs.haskell.lib.doJailbreak (super.callPackage ./haskell-indexer-translate.nix {});
  kythe-proto                               = pkgs.haskell.lib.addBuildTool (pkgs.haskell.lib.doJailbreak (super.callPackage ./kythe-proto.nix { kythe = pkgs.kythe; })) pkgs.protobuf3_1;
  kythe-schema                              = pkgs.haskell.lib.doJailbreak (super.callPackage ./kythe-schema.nix {});
  text-offset                               = pkgs.haskell.lib.doJailbreak (super.callPackage ./text-offset.nix {});

  hspec-core = pkgs.haskell.lib.dontCheck super.hspec-core;

  temporary = pkgs.haskell.lib.dontCheck super.temporary;

}
