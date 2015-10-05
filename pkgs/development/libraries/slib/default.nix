{ fetchurl, stdenv, unzip, findutils, texinfo  # Build dependencies
, scheme                                       # Scheme compiler
}:

stdenv.mkDerivation rec {
  name = "slib-3.5";

  src = fetchurl {
    url = "http://groups.csail.mit.edu/mac/ftpdir/scm/slib-3b5.zip";
    sha256 = "0q0p2d53p8qw2592yknzgy2y1p5a9k7ppjx0cfrbvk6242c4mdpq";
  };

  patches = [ ./catalog-in-library-vicinity.patch ];

  buildInputs = [ unzip findutils scheme texinfo ];

  preConfigure = ''
      find . -type f -exec chmod -x {} \;
      chmod +x configure
      mkdir -p "$out"
  '';

  buildPhase = "make infoz";

  installPhase = ''
      make install
   
      ln -s mklibcat.scm mklibcat
      SCHEME_LIBRARY_PATH="$out/lib/slib" make catalogs
   
      sed -i "$out/bin/slib" \
          -e "/^SCHEME_LIBRARY_PATH/i export PATH=\"${scheme}/bin:\$PATH\""
  '';

  # There's no test suite (?!).
  doCheck = false;

  setupHook = ./setup-hook.sh;

  meta = {
    description = "A portable Scheme utility library";
    longDescription = ''
      SLIB is a portable library for the programming language Scheme.  It
      provides a platform independent framework for using packages of Scheme
      procedures and syntax.

      SLIB supports Bigloo, Chez, ELK 3.0, Gambit 4.0, Guile, JScheme, Kawa,
      Larceny, MacScheme, MIT Scheme, Pocket Scheme, RScheme, scheme->C,
      Scheme48, SCM, SCM Mac, scsh, sisc, Stk, T3.1, umb-scheme, and VSCM.
    '';
    license = stdenv.lib.licenses.publicDomain;
    homepage = http://people.csail.mit.edu/jaffer/SLIB;
    maintainers = with stdenv.lib.maintainers; [ taktoa ];
  };
}
