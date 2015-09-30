{ fetchgit, stdenv
, autoconf, automake, texinfo, pkgconfig            # build dependencies
, gtk, gconf, glib, gnome_vfs, pango                # non-Guile dependencies
, libglade, libgnome, libgnomecanvas, libgnomeui
, guile, gwrap, guileLib, guileCairo                # Guile dependencies
}:

stdenv.mkDerivation rec {
  name = "guile-gnome-20150123";

  src = fetchgit {
    url = "git://git.sv.gnu.org/guile-gnome.git";
    rev = "0fcbe69797b9501b8f1283a78eb92bf43b08d080";
    sha256 = "1vqlzb356ggmp8jh833gksg59c53vbmmhycbcf52qj0fdz09mpb5";
  };

  buildInputs = [
    autoconf
    automake
    texinfo
    pkgconfig
    gtk
    gconf
    glib
    gnome_vfs
    pango
    libglade
    libgnome
    libgnomecanvas
    libgnomeui
    guile
    gwrap
    guileLib
    guileCairo
  ];

  preConfigure = ''
      ./autogen.sh
  '';

  # The test suite tries to open an X display, which fails.
  doCheck = false;

  meta = {
    description = "guile-gnome: GNOME bindings for GNU Guile";
    longDescription = ''
        Guile-Gnome brings the power of Scheme to your graphical application.
        Guile-Gnome modules support the entire Gnome library stack: from
        Pango to GnomeCanvas, Gtk+ to GStreamer, Glade to GtkSourceView,
        it is a comprehensive environment for developing GUI applications.
    '';
    homepage = http://www.gnu.org/software/guile-gnome;
    license = stdenv.lib.licenses.lgpl3Plus;
    maintainers = [ stdenv.lib.maintainers.taktoa ];
    platforms = guile.meta.platforms;
  };
}
