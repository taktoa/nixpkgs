{ stdenv, fetchurl, binutilsCross ? null, gccCross ? null
, onlyHeaders ? false
, onlyPthreads ? false
}:

let
  version = "5.0.2";
  name = "mingw-w64-${version}";
in
stdenv.mkDerivation ({
  inherit name;

  src = fetchurl {
    url = "mirror://sourceforge/mingw-w64/mingw-w64-v${version}.tar.bz2";
    sha256 = "1z9cv77k4x7g95jk0ibwp8n2d66zx7d46ds5lcvjl459y47yhijz";
  };
} //
(if onlyHeaders then {
  name = name + "-headers";
  preConfigure = ''
    cd mingw-w64-headers
  '';
  configureFlags = "--without-crt";
} else if onlyPthreads then {
  name = name + "-pthreads";
  preConfigure = ''
    cd mingw-w64-libraries/winpthreads
  '';
} else {
  buildInputs = [ gccCross binutilsCross ];

  crossConfig = gccCross.crossConfig;

  dontStrip = true;
})
)
