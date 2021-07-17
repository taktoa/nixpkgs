{ lib
, buildPythonPackage
, pytestCheckHook
, fetchPypi
, pkg-config
, setuptools-scm, cython
, glib, cairo, pango
}:

buildPythonPackage rec {
  pname = "ManimPango";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1j2mbhf7d82718nkc0r8x7cf35hlh13b67qkczjbbys3w24nyfsw";
  };

  patches = [ ./remove-intl.patch ];

  nativeBuildInputs = [ setuptools-scm cython pkg-config ];
  buildInputs = [ glib.dev cairo.dev pango.dev ];
  propagatedBuildInputs = [ ];

  dontUseCmakeConfigure = true;

  #checkInputs = [ pytestCheckHook ];

  dontUseSetuptoolsCheck = true;
  dontCheck = true;

  meta = with lib; {
    description = "ManimPango is a C binding for Pango using Cython.";
    homepage = "https://github.com/ManimCommunity/manimpango";
    license = licenses.gpl3;
    maintainers = with maintainers; [ taktoa ];
  };
}
