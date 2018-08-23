{ pkgs }: self: super:

with { inherit (pkgs.haskell.lib) addBuildTool doJailbreak dontCheck; };

with rec {
  haskell-indexer-src = pkgs.fetchgit {
    url    = "https://github.com/taktoa/haskell-indexer";
    rev    = "5f246a9b537c70f3c088bd4628e0dcc27b314713";
    sha256 = "1z8gy5f7vbkrd0qxy1wrxapbpc865rwj1yrzkmjfx0i0i3hqv5z1";
    # url    = "https://github.com/taktoa/haskell-indexer";
    # rev    = "2712e450769a300c5d9f31f0cec4008d2bed4a0c";
    # sha256 = "1flddc8d84kdx4wynpl131i1knb439jwrcx3dzdqqy5ymyw1lh57";
    # url    = "https://github.com/mpickering/haskell-indexer";
    # rev    = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
    # sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
  };
  # haskell-indexer-src = ../../../../../haskell-indexer;
  haskellIndexerCP = path: args: (
    super.callPackage path ({ inherit haskell-indexer-src; } // args));
  addProtobuf = pkg: addBuildTool pkg pkgs.protobuf3_1;
};

{
  proto-lens             = addProtobuf super.proto-lens;
  proto-lens-descriptors = addProtobuf super.proto-lens-descriptors;
  proto-lens-protoc      = addProtobuf super.proto-lens-protoc;
  proto-lens-combinators = addProtobuf super.proto-lens-combinators;

  haskell-indexer-backend-core              = doJailbreak (haskellIndexerCP ./haskell-indexer-backend-core.nix {});
  haskell-indexer-backend-ghc               = doJailbreak (haskellIndexerCP ./haskell-indexer-backend-ghc.nix {});
  haskell-indexer-frontend-kythe            = doJailbreak (haskellIndexerCP ./haskell-indexer-frontend-kythe.nix {});
  haskell-indexer-pathutil                  = doJailbreak (haskellIndexerCP ./haskell-indexer-pathutil.nix {});
  haskell-indexer-pipeline-ghckythe-wrapper = haskellIndexerCP ./haskell-indexer-pipeline-ghckythe-wrapper.nix {};
  haskell-indexer-pipeline-ghckythe         = doJailbreak (haskellIndexerCP ./haskell-indexer-pipeline-ghckythe.nix {});
  haskell-indexer-translate                 = doJailbreak (haskellIndexerCP ./haskell-indexer-translate.nix {});
  kythe-proto                               = addProtobuf (doJailbreak (haskellIndexerCP ./kythe-proto.nix { kythe = pkgs.kythe; }));
  kythe-schema                              = doJailbreak (haskellIndexerCP ./kythe-schema.nix {});
  text-offset                               = doJailbreak (haskellIndexerCP ./text-offset.nix {});

  hspec-core = dontCheck super.hspec-core;
  temporary  = dontCheck super.temporary;
}
