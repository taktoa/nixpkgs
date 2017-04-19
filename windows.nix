import ./. {
  crossSystem = {
    #config = "x86_64-w64-mingw32-gnu";
    #config = "x86_64-pc-mingw32-gnu";
    config = "x86_64-w64-mingw32";
    arch = "x86_64";
    libc = "msvcrt";
    # platform = (import ./lib/systems/platforms.nix).pc64;
    platform = {};
    openssl.system = "mingw64";
    withTLS = false;
    # useClangMinGW = true;
  };

  # config = {
  # };

  overlays = [
    (self: super: { stdenv = super.stdenv // { isWindows = true; }; })
    (import ./pkgs/os-specific/windows/overlay.nix)
  ];
}
