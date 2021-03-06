{ lib
, attrs
, buildPythonPackage
, cattrs
, fetchFromGitHub
, itsdangerous
, poetry-core
, pytestCheckHook
, pythonOlder
, pyyaml
, requests
, requests-mock
, rich
, timeout-decorator
, ujson
, url-normalize
}:

buildPythonPackage rec {
  pname = "requests-cache";
  version = "0.7.0";
  disabled = pythonOlder "3.6";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "reclosedev";
    repo = "requests-cache";
    rev = "v${version}";
    sha256 = "sha256-P7JzImidUXOD4DUMdfy3sgM5RISti23wNnLwDHPoiTA=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    attrs
    cattrs
    itsdangerous
    pyyaml
    requests
    ujson
    url-normalize
  ];

  checkInputs = [
    pytestCheckHook
    requests-mock
    rich
    timeout-decorator
  ];

  # Integration tests require local DBs
  pytestFlagsArray = [ "tests/unit" ];

  pythonImportsCheck = [ "requests_cache" ];

  meta = with lib; {
    description = "Persistent cache for requests library";
    homepage = "https://github.com/reclosedev/requests-cache";
    license = licenses.bsd3;
    maintainers = with maintainers; [ fab ];
  };
}
