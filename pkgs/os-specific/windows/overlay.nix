self: super:

with rec {
  inherit (super) lib buildEnv;
  nullAllInSet    = lib.attrsets.mapAttrs (k: v: null);
  makeDummy       = name: buildEnv { name = "${name}-dummy"; paths = []; };
  compose         = lib.foldl' (f: g: x: (f (g x))) (x: x);
  apply           = str: fs: ((compose (lib.reverseList fs)) (lib.getAttr str super));
  override        = args:   drv: drv.override args;
  overrideAttrs   = cb:     drv: drv.overrideAttrs cb;

  appendOld = attr: old: add: (
    let x = old.${attr} or [];
    in (if isNull x then add else (x ++ add)));

  addBuildInputs = inputs: overrideAttrs (old: {
    buildInputs = appendOld "buildInputs" old inputs;
  });

  addNativeInputs = inputs: overrideAttrs (old: {
    nativeBuildInputs = appendOld "nativeBuildInputs" old inputs;
  });

  addPatch = patch: overrideAttrs (old: {
    patches = appendOld "patches" old [patch];
  });

  confFlags = flags: overrideAttrs (old: {
    configureFlags = appendOld "configureFlags" old flags;
  });

  confFlag        = str:    confFlags [str];
  confDisable     = str:    confFlag "--disable-${str}";
  confEnable      = str:    confFlag "--enable-${str}";

  # For debugging purposes
  # MINGW-packages = name: (
  #   let base = ../../../../MINGW-packages;
  #   in builtins.toPath "${base}/mingw-w64-${name}/"
  # );
};

{
  # ----------------------------------------------------------------------------
  # -- Package options ---------------------------------------------------------
  # ----------------------------------------------------------------------------

  mesaSupported = false;
  x11Support    = false;
  cupsSupport   = false;
  xcbSupport    = false;
  glSupport     = false;
  pythonSupport = false; # for libxslt

  # ----------------------------------------------------------------------------
  # -- Disabled packages -------------------------------------------------------
  # ----------------------------------------------------------------------------

  ### Currently broken packages

  # General broken libraries

  libedit           = null;
  libgnome_keyring  = null;
  libgnome_keyring3 = null;
  gnutls            = null;
  libsoup           = null;

  # Media-related broken libraries

  a52dec         = null;
  aalib          = null;
  libdv          = null;
  libmpeg2       = null;
  libpulseaudio  = null;
  librsvg        = null;
  libshout       = null;
  mjpegtools     = null;
  mjpegtoolsFull = null;
  openjpeg       = null;
  speex          = null;
  taglib         = null;
  fluidsynth     = null;
  wildmidi       = null;
  imlib2         = null;

  # Font/rendering-related broken libraries

  cairo        = null;
  pango        = null;
  fontconfig   = null;
  ghostscript  = null;
  harfbuzz     = null;
  harfbuzz-icu = null;
  icu          = null;

  # Broken executables
  mariadb    = null;
  postgresql = null;

  ### Tools not useful for cross-builds
  rtags                = null;
  include-what-you-use = null;

  ### Unix-specific hardware interface libraries

  alsaLib     = null;
  libcdio     = null;
  libdvdread  = null;
  libusb1     = null;
  libavc1394  = null;
  libiec61883 = null;
  libvdpau    = null;
  wayland     = null;
  libv4l      = null;
  v4l_utils   = null;
  mesa        = null;

  ### Other Unix-specific packages

  cups              = null;
  systemd           = null;
  linuxHeadersCross = null;

  # ----------------------------------------------------------------------------
  # -- Packages that should be native ------------------------------------------
  # ----------------------------------------------------------------------------

  ### Build tools

  # cmake        = null;
  # cmakeCurses  = null;
  # cmake_2_8    = null;
  # cmakeWithGui = null;
  # autogen      = null;
  # pkgconfig    = null;
  # m4           = null;
  # help2man     = null;
  # intltool     = null;
  # texinfo      = null;
  # groff        = null;

  ### Languages and compilers

  # perl        = null;
  # ruby        = null;
  # python      = null;
  # vala        = null;
  # guile       = null;
  # yasm        = null;
  # bison       = null;
  # bison2      = null;
  # bison3      = null;
  # flex        = null;
  # flex_2_5_35 = null;
  # flex_2_6_1  = null;
  # yacc        = null;

  ### Miscellaneous packages

  # ncurses              = super.buildPackages.ncurses;
  # coreutils            = super.buildPackages.coreutils;
  # utillinuxMinimal     = super.buildPackages.utillinuxMinimal;
  # gobjectIntrospection = super.buildPackages.gobjectIntrospection;

  # ----------------------------------------------------------------------------
  # -- Fixes related to X11 ----------------------------------------------------
  # ----------------------------------------------------------------------------

  xorg  = nullAllInSet super.xorg // {
    # libXcursor = makeDummy "libXcursor";
    # libX11 = makeDummy "libX11";
    # inherit (super.xorg) lndir;
  };

  xlibs = nullAllInSet super.xlibs // {
    # inherit (super.xlibs) libXcursor libX11;
  };

  libXext      = null;
  libxcb       = null;
  libxkbcommon = null;

  # ----------------------------------------------------------------------------
  # -- Packages fixes ----------------------------------------------------------
  # ----------------------------------------------------------------------------

  libxml2Python = super.libxml2;

  # gettext = apply "gettext" [
  #   (addBuildInputs [super.libiconv])];

  x264 = apply "x264" [
    (confFlag "--cross-prefix=x86_64-w64-mingw32-")];

  faad2 = apply "faad2" [
    (addPatch ./fixes/faad2-frontend-off_t.patch)];

  lame = apply "lame" [
    (addPatch ./fixes/lame-dbl-epsilon.patch)];

  giflib = apply "giflib" [
    (override { xmlto = null; })];

  libtheora = apply "libtheora" [
    (confDisable "examples")
    (confDisable "shared")
    (confEnable  "static")];

  nettle = apply "nettle" [
    (confEnable  "shared")
    (confEnable  "public-key")
    (addNativeInputs [super.buildPackages.m4])];

  unbound = apply "unbound" [
    (confEnable  "shared")
    (confDisable "static")
    (confDisable "rpath")
    (confFlag    "--with-libevent=no")
    (confFlag    "--without-pyunbound")
    (confFlag    "--without-pythonmodule")
    (confFlag    "--without-pthreads")
    (confFlag    "--with-libunbound-only")
  ];

  libgsf = apply "libgsf" [
    (addPatch ./fixes/libgsf-dllmain.patch)
    (confDisable "introspection")
    (confDisable "shared")
    (confEnable  "static")];

  libmsgpack = apply "libmsgpack" []; # FIXME

  nlohmann_json = apply "nlohmann_json" []; # FIXME

  protobuf3_0 = apply "protobuf3_0" []; # FIXME

  zeromq4 = apply "zeromq4" [
    (override { libuuid = null; })];

  dbus = apply "dbus" [
    (confDisable "systemd")
    (confDisable "shared")
    (confEnable  "static")];

  dbus_libs = self.dbus;
  dbus_tools = self.dbus;

  gdk_pixbuf = apply "gdk_pixbuf" []; # FIXME

  glib = apply "glib" []; # FIXME

  glibmm = apply "glibmm" [
    (confDisable "documentation")
    (confDisable "shared")
    (confEnable  "static")
    (addNativeInputs [self.glib.dev])];

  ncurses = apply "ncurses" [
    (addPatch ./fixes/ncurses-libsystre.patch)
    (confFlag    "--without-ada")
    (confFlag    "--with-cxx")
    (confFlag    "--without-shared")
    (confFlag    "--without-pthread")
    (confDisable "rpath")
    (confEnable  "colorfgbg")
    (confEnable  "ext-colors")
    (confEnable  "ext-mouse")
    (confDisable "symlinks")
    (confEnable  "warnings")
    (confEnable  "assertions")
    (confDisable "home-terminfo")
    (confEnable  "database")
    (confEnable  "sp-funcs")
    (confEnable  "term-driver")
    (confEnable  "interop")];

  libcaca = apply "libcaca" [
    (addPatch ./fixes/libcaca-win32.patch)
    (addPatch ./fixes/libcaca-msc.patch)];

  popt = apply "popt" [
    (addPatch ./fixes/popt-uid.patch)
    (addPatch ./fixes/popt-ioctl.patch)];

  libvpx = apply "libvpx" [
    (overrideAttrs (old: {
      configureFlags = [
        "--target=x86_64-win64-gcc"
        "--force-target=x86_64-win64-gcc"
        "--enable-static-msvcrt"
        "--enable-vp8"
        "--enable-vp9"
        "--enable-runtime-cpu-detect"
        "--enable-postproc"
        "--enable-pic"
        "--enable-shared"
        "--enable-static"
        "--enable-experimental"
        "--enable-spatial-svc"
        "--disable-examples"
        "--disable-docs"
        "--disable-install-docs"
        "--disable-install-srcs"
        "--disable-unit-tests"
        "--disable-decode-perf-tests"
        "--disable-encode-perf-tests"
        "--as=yasm"
      ];
    }))
    (addPatch ./fixes/libvpx-patch1.patch)
    (addPatch ./fixes/libvpx-patch2.patch)
    (addPatch ./fixes/libvpx-patch3.patch)
    (addPatch ./fixes/libvpx-patch5.patch)
    (addPatch ./fixes/libvpx-patch9.patch)
  ];

  # NOTE: libdv needs pthreads

  # a52dec = apply "a52dec" [
  #   (confDisable "static")
  #   (confEnable  "shared")
  #   (addPatch ./fixes/a52dec-build.patch)
  #   (addPatch ./fixes/a52dec-inline.patch)
  #   (overrideAttrs (old: { postPatch = (old.postPatch or "") + "\nsed -i 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/' configure.in"; }))];
}
