{ pkgs }: self: super:

with { inherit (pkgs.haskell.lib) addBuildTool doJailbreak dontCheck; };

with rec {
  haskell-indexer-src = pkgs.fetchgit {
    url    = "https://github.com/mpickering/haskell-indexer";
    rev    = "8238aeb84eae0908096d0b3a82dc5c4db0063a52";
    sha256 = "0l9825wxgxqsmj9m3vbk1mg352x8nc65hqllj1wxsv6c8mp2c4ps";
    # url    = "https://github.com/taktoa/haskell-indexer";
    # rev    = "5f246a9b537c70f3c088bd4628e0dcc27b314713";
    # sha256 = "1z8gy5f7vbkrd0qxy1wrxapbpc865rwj1yrzkmjfx0i0i3hqv5z1";
    # url    = "https://github.com/taktoa/haskell-indexer";
    # rev    = "2712e450769a300c5d9f31f0cec4008d2bed4a0c";
    # sha256 = "1flddc8d84kdx4wynpl131i1knb439jwrcx3dzdqqy5ymyw1lh57";
    # url    = "https://github.com/mpickering/haskell-indexer";
    # rev    = "1f9d412cfaa81563d959ad93d3fd2e6ba2b6beaa";
    # sha256 = "01drd8i0mhsw44nj977m2h2ww08i7sh23l3qig830s1sr2r57bzk";
  };
  # haskell-indexer-src = ../../../../../haskell-indexer;
  haskellIndexerCP = path: args: (
    self.callPackage path ({ inherit haskell-indexer-src; } // args));
  addProtobuf = pkg: addBuildTool pkg pkgs.protobuf3_1;
};

{
  discrimination-ieee754    = addProtobuf (self.callPackage ./discrimination-ieee754.nix    {});
  lens-labels               = addProtobuf (self.callPackage ./lens-labels.nix               {});
  proto-lens-arbitrary      = addProtobuf (self.callPackage ./proto-lens-arbitrary.nix      {});
  proto-lens-benchmarks     = addProtobuf (self.callPackage ./proto-lens-benchmarks.nix     {});
  proto-lens-combinators    = addProtobuf (self.callPackage ./proto-lens-combinators.nix    {});
  proto-lens-discrimination = addProtobuf (self.callPackage ./proto-lens-discrimination.nix {});
  proto-lens-optparse       = addProtobuf (self.callPackage ./proto-lens-optparse.nix       {});
  proto-lens-protobuf-types = addProtobuf (self.callPackage ./proto-lens-protobuf-types.nix {});
  proto-lens-protoc         = addProtobuf (self.callPackage ./proto-lens-protoc.nix         {});
  proto-lens-runtime        = addProtobuf (self.callPackage ./proto-lens-runtime.nix        {});
  proto-lens-setup          = addProtobuf (self.callPackage ./proto-lens-setup.nix          {});
  proto-lens-tests-dep      = addProtobuf (self.callPackage ./proto-lens-tests-dep.nix      {});
  proto-lens-tests          = addProtobuf (self.callPackage ./proto-lens-tests.nix          {});
  proto-lens                = addProtobuf (self.callPackage ./proto-lens.nix                {});

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
