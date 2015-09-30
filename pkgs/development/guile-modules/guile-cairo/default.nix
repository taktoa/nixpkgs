{ fetchurl, stdenv, pkgconfig    # general build dependencies
, cairo, expat                   # non-Guile dependencies
, guile, guileLib                # Guile dependencies
}:

stdenv.mkDerivation rec {
  name = "guile-cairo-1.9.91";

  src = fetchurl {
    url = "mirror://savannah/guile-cairo/${name}.tar.gz";
    sha256 = "03g0vjcrfy5frfnhqv0ihhzwi3vx366b2rkkjqxwbpwl6c43cf0s";
  };

  buildInputs = [ pkgconfig cairo expat guile guileLib ];

  doCheck = true;

  meta = {
    description = "guile-cairo: Cairo bindings for GNU Guile Scheme";
    longDescription = ''
        Guile-Cairo wraps the Cairo graphics library for Guile Scheme.

        Guile-Cairo is complete, wrapping almost all of the Cairo API. It is API
        stable, providing a firm base on which to do graphics work. Finally, and
        importantly, it is pleasant to use.

        Guile-Cairo is a powerful, well-maintained Scheme graphics library.
    '';
    homepage = http://www.nongnu.org/guile-cairo;
    license = stdenv.lib.licenses.lgpl3Plus;
    maintainers = [ stdenv.lib.maintainers.taktoa ];
    platforms = guile.meta.platforms;
  };
}
