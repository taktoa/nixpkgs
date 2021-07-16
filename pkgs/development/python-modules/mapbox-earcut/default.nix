{ lib
, buildPythonPackage
, pytestCheckHook
, fetchPypi
, cmake
, setuptools-scm, numpy, pybind11
}:

buildPythonPackage rec {
  pname = "mapbox_earcut";
  version = "0.12.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ly48lijgd9inq07x42pfp9c24fn16vn9axpmfwqrkn979krbnah";
  };

  nativeBuildInputs = [ cmake setuptools-scm ];
  buildInputs = [ pybind11 ];
  propagatedBuildInputs = [ numpy ];

  dontUseCmakeConfigure = true;

  # checkInputs = [ pytestCheckHook pybind11 ];
  # dontUseSetuptoolsCheck = true;

  dontCheck = true;

  meta = with lib; {
    description = "Python bindings for the Mapbox Earcut library.";
    homepage = "https://github.com/skogler/mapbox_earcut_python";
    license = licenses.isc;
    maintainers = with maintainers; [ taktoa ];
  };
}
