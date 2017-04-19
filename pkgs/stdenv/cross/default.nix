{ lib
, localSystem, crossSystem, config, overlays
}:

let
  bootStages = import ../. {
    inherit lib localSystem overlays;
    crossSystem = null;
    # Ignore custom stdenvs when cross compiling for compatability
    config = builtins.removeAttrs config [ "replaceStdenv" ];
  };

in bootStages ++ [

  # Build Packages
  (vanillaPackages: {
    buildPlatform = localSystem;
    hostPlatform = localSystem;
    targetPlatform = crossSystem;
    inherit config overlays;
    selfBuild = false;
    # It's OK to change the built-time dependencies
    allowCustomOverrides = true;
    stdenv = vanillaPackages.stdenv // {
      overrides = _: _: {};
    };
  })

  # Run Packages
  (buildPackages: {
    buildPlatform = localSystem;
    hostPlatform = crossSystem;
    targetPlatform = crossSystem;
    inherit config overlays;
    selfBuild = false;

    stdenv = (rec {
      bp = buildPackages;
      cs = crossSystem;

      makeStdenv = bp.makeStdenvCross bp.stdenv cs;

      iosStdenv = (
        let
          compiler = bp.darwin.ios-cross {
            prefix = cs.config;
            inherit (cs) arch;
            simulator = cs.isiPhoneSimulator or false;
          };
        in makeStdenv compiler.binutils compiler.cc
      );

      clangMinGWStdenv = (
        let
          compiler = bp.windows.clang-mingw-cross {
            prefix = cs.config;
            inherit (cs) arch;
          };
        in makeStdenv compiler.binutils compiler.cc
      );

      normalStdenv = (
        makeStdenv bp.binutilsCross bp.gccCrossStageFinal
      );

      stdenv = (
        if      cs.useiOSCross   or false then iosStdenv
        else if cs.useClangMinGW or false then clangMinGWStdenv
        else                                   normalStdenv
      );
    }).stdenv;
  })
]
