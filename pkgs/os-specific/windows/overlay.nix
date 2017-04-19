self: super:

with rec {
  inherit (super) lib buildEnv;
  nullAllInSet    = lib.attrsets.mapAttrs (k: v: null);
  makeDummy       = name: buildEnv { name = "${name}-dummy"; paths = []; };
  compose         = lib.foldl' (f: g: x: (f (g x))) (x: x);
  apply           = str: fs: ((compose fs) (lib.getAttr str super));
  override        = args:   drv: drv.override args;
  overrideAttrs   = cb:     drv: drv.overrideAttrs cb;
  addBuildInputs  = inputs: drv: drv; # FIXME
  addNativeInputs = inputs: drv: drv; # FIXME
  addPatch        = patch:  drv: drv; # FIXME
  confFlags       = flags:  drv: drv; # FIXME
  confFlag        = str:    confFlags [str];
  confDisable     = str:    confFlag "--disable-${str}";
  confEnable      = str:    confFlag "--enable-${str}";
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

  lzip              = null;
  libedit           = null;
  libgnome_keyring  = null;
  libgnome_keyring3 = null;
  gnutls            = null;
  libsoup           = null;

  # Media-related broken libraries

  a52dec         = null;
  aalib          = null;
  libass         = null;
  libcaca        = null;
  libdv          = null;
  libmpeg2       = null;
  libpulseaudio  = null;
  librsvg        = null;
  libshout       = null;
  libvpx         = null;
  libwebp        = null;
  mjpegtools     = null;
  mjpegtoolsFull = null;
  openjpeg       = null;
  speex          = null;
  taglib         = null;
  fluidsynth     = null;
  wildmidi       = null;

  # Font/rendering-related broken libraries

  cairo        = null;
  pango        = null;
  fontconfig   = null;
  freetype     = null;
  ghostscript  = null;
  harfbuzz     = null;
  harfbuzz-icu = null;
  icu          = null;
  mesa         = null;

  # Broken executables

  mariadb              = null;
  postgresql           = null;
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

  ### Other Unix-specific packages

  cups              = null;
  systemd           = null;
  linuxHeadersCross = null;

  # ----------------------------------------------------------------------------
  # -- Packages that should be native ------------------------------------------
  # ----------------------------------------------------------------------------

  ### Build tools

  # cmake        = super.buildPackages.cmake;
  # cmakeCurses  = super.buildPackages.cmakeCurses;
  # cmake_2_8    = super.buildPackages.cmake_2_8;
  # cmakeWithGui = super.buildPackages.cmakeWithGui;
  # autogen      = super.buildPackages.autogen;
  # pkgconfig    = super.buildPackages.pkgconfig;
  # m4           = super.buildPackages.m4;
  # help2man     = super.buildPackages.help2man;
  # intltool     = super.buildPackages.intltool;
  # texinfo      = super.buildPackages.texinfo;

  ### Languages and compilers

  # perl        = super.buildPackages.perl;
  # ruby        = super.buildPackages.ruby;
  # python      = super.buildPackages.python;
  # vala        = super.buildPackages.vala;
  # guile       = super.buildPackages.guile;
  # yasm        = super.buildPackages.yasm;
  # bison       = super.buildPackages.bison;
  # bison2      = super.buildPackages.bison2;
  # bison3      = super.buildPackages.bison3;
  # flex        = super.buildPackages.flex;
  # flex_2_5_35 = super.buildPackages.flex_2_5_35;
  # flex_2_6_1  = super.buildPackages.flex_2_6_1;
  # yacc        = super.buildPackages.yacc;

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

  gettext = apply "gettext" [
    (addBuildInputs [super.libiconv])];

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
    (addNativeInputs [self.m4])];

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

  groff = apply "groff" [
    (overrideAttrs (old: {
      crossAttrs = {};
    }))
  ];
}
