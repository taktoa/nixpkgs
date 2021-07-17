{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "decorator";
  version = "5.0.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0q7hl01w10qzix3wjhkl468q1v34jf5m07v6a9rihgdc9mn1l83g";
  };

  meta = with lib; {
    homepage = "https://pypi.python.org/pypi/decorator";
    description = "Better living through Python with decorators";
    license = lib.licenses.mit;
    maintainers = [ maintainers.costrouc ];
  };
}
