{ lib
, buildPythonPackage
, pytestCheckHook
, fetchPypi
, setuptools-scm
, click, typing-extensions
}:

buildPythonPackage rec {
  pname = "cloup";
  version = "0.7.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0yyxibwlxmdkm4866fm4rwpdgy3d6y18n061992ckr54vl0cav7j";
  };

  nativeBuildInputs = [ setuptools-scm ];
  buildInputs = [ ];
  propagatedBuildInputs = [ click typing-extensions ];

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;

  meta = with lib; {
    description = "Cloup enriches Click with several features.";
    homepage = "https://github.com/janLuke/cloup";
    license = licenses.bsd3;
    maintainers = with maintainers; [ taktoa ];
  };
}
