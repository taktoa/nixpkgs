{ stdenv, fetchurl    # general build dependencies
, gcc, texinfo        # non-Guile dependencies
, guile               # Guile dependencies
}:

assert stdenv ? cc && stdenv.cc.isGNU;

stdenv.mkDerivation rec {
  name = "guile-lib-0.2.2";

  src = fetchurl {
    url = "mirror://savannah/guile-lib/${name}.tar.gz";
    sha256 = "1f9n2b5b5r75lzjinyk6zp6g20g60msa0jpfrk5hhg4j8cy0ih4b";
  };

  buildInputs = [ guile texinfo ];

  doCheck = true;

  # Make libgcc_s.so visible for pthread_cancel.
  preCheck = ''
      ld-set () { export LD_LIBRARY_PATH="$1"; }
      ld-add () { ld-set "''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$1"; }
      ld-add "$(dirname $(echo ${gcc.cc}/lib*/libgcc_s.so))"
  '';

  meta = {
    description = "guile-lib: a collection of useful GNU Guile Scheme modules";
    longDescription = ''
        guile-lib is intended as an accumulation place for pure-scheme Guile
        modules, allowing for people to cooperate integrating their generic
        Guile modules into a coherent library.
    '';
    homepage = http://www.nongnu.org/guile-lib/;
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = [ stdenv.lib.maintainers.taktoa ];
    platforms = guile.meta.platforms;
  };
}
