{ stdenv, fetchurl, binutilsCross ? null, gccCross ? null
, onlyHeaders ? false
, onlyPthreads ? false
}:

let
  version = "5.0.2";

  headersBuild = {
    name = "mingw-w64-headers-${version}";

    preConfigure = ''
        cd mingw-w64-headers
    '';
  };

  pthreadsBuild = {
    name = "mingw-w64-pthreads-${version}";

    preConfigure = ''
        cd mingw-w64-libraries/winpthreads
    '';
  };

  genericBuild = {
    name = "mingw-w64-${version}";

    buildInputs = [ gccCross binutilsCross ];

    crossConfig = gccCross.crossConfig;

    dontStrip = true;
  };

  common = {
    src = fetchurl {
      url = "mirror://sourceforge/mingw-w64/mingw-w64-v${version}.tar.bz2";
      sha256 = "1z9cv77k4x7g95jk0ibwp8n2d66zx7d46ds5lcvjl459y47yhijz";
    };

    configureFlags = [
      "--enable-idl"
      "--enable-secure-api"
    ];
  };

  specific = (
    if      onlyHeaders  then headersBuild
    else if onlyPthreads then pthreadsBuild
    else                      genericBuild
  );
in stdenv.mkDerivation (common // specific)
