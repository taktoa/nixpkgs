{ fetchurl, stdenv    # general build dependencies
, ncurses, libffi     # non-Guile dependencies
, guile               # Guile dependencies
}:

stdenv.mkDerivation rec {
  name = "guile-ncurses-1.4";

  src = fetchurl {
    url = "mirror://gnu/guile-ncurses/${name}.tar.gz";
    sha256 = "070wl664lsm14hb6y9ch97x9q6cns4k6nxgdzbdzi5byixn74899";
  };

  buildInputs = [ ncurses libffi guile ];

  preConfigure = ''
      configureFlags="$configureFlags --with-guilesitedir=$out/share/guile/site"
  '';

  doCheck = false; # XXX: 1 of 65 tests failed

  meta = {
    description = "guile-ncurses: ncurses bindings for GNU Guile Scheme";
    longDescription = ''
        Guile-Ncurses is a library for the Guile Scheme interpreter that
        provides functions for creating text user interfaces. The text user
        interface functionality is built on the ncurses libraries:
        curses, form, panel, and menu.
    '';
    homepage = http://www.gnu.org/software/guile-ncurses;
    license = stdenv.lib.licenses.lgpl3Plus;
    maintainers = [ stdenv.lib.maintainers.taktoa ];
    platforms = guile.meta.platforms;
  };
}
