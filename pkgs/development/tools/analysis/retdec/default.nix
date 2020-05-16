{ stdenv
, fetchFromGitHub
, fetchpatch
, fetchzip
, lib
, callPackage
, cmake
, autoconf
, automake
, libtool
, pkgconfig
, bison
, flex
, groff
, perl
, python3
, time
, upx
, ncurses
, libffi
, libxml2
, zlib
, withPEPatterns ? false
}:

let
  capstone = fetchFromGitHub {
    owner = "aquynh";
    repo = "capstone";
    rev = "bc8a649b35188786754ea1b0bddd5cb48a039162";
    sha256 = "1qhy2p840qx8rccxc0axd3qj628k7xwsyw3ly4q2lm7vbm7mmjpa";
  };
  keystone = fetchFromGitHub { # only for tests
    owner = "keystone-engine";
    repo = "keystone";
    rev = "d7ba8e378e5284e6384fc9ecd660ed5f6532e922";
    sha256 = "1yzw3v8xvxh1rysh97y0i8y9svzbglx2zbsqjhrfx18vngh0x58f";
  };
  llvm = fetchFromGitHub {
    owner = "avast";
    repo = "llvm";
    rev = "d17df7fb9a1d585fdfa3643e666506d1bead4443";
    sha256 = "1lx8g5q2z2sl1agwx53mk3c12xwvfnnrgcz7ps3hxcnz2p67ka84";
  };
  openssl = fetchFromGitHub {
    owner = "openssl";
    repo = "openssl";
    rev = "97ace46e11dba4c4c2b7cb67140b6ec152cfaaf4";
    sha256 = "0rbs6acagzl1zpyv8r4pap85hx22cc6dpfkk1j9y167p26zw57l7";
  };
  yara = fetchFromGitHub {
    owner = "VirusTotal";
    repo = "yara";
    rev = "b9f925bb4e2b998bd6bb2f2e3cc2087c62fdd5b9";
    sha256 = "0mx3xm2a70fx8vlynkavq8gfd9w5yjcix5rx85444i2s1h6kcd0j";
  };
  yaramod = fetchFromGitHub {
    owner = "avast";
    repo = "yaramod";
    rev = "57f4ee87372aba7735bbcc1ed870f43faaa8127b";
    sha256 = "1rcsgrsvy8fpmxnr419bsyck18zhpk8mih32glng80h2s47dlzvh";
  };
  googletest = fetchFromGitHub { # only for tests
    owner = "google";
    repo = "googletest";
    rev = "90a443f9c2437ca8a682a1ac625eba64e1d74a8a";
    sha256 = "0adgfjm48nl624z77wpk492lddj7f6fm4imdafdchk8rnlqqysky";
  };

  retdec-support = let
    version = "2019-03-08"; # make sure to adjust both hashes (once with withPEPatterns=true and once withPEPatterns=false)
  in fetchzip {
    url = "https://github.com/avast/retdec-support/releases/download/${version}/retdec-support_${version}.tar.xz";
    sha256 = if withPEPatterns then "10w4k9pmsvj3fjsaz5hwwcwlhl5ccw6jbfdknmqgjnybqzh72nxp"
                               else "06rgxhnbgfs7f518xrgi5rhw46fvg31zmkx8p0qbn4yk2npqv9x5";
    stripRoot = false;
    # Removing PE signatures reduces this from 3.8GB -> 642MB (uncompressed)
    extraPostFetch = lib.optionalString (!withPEPatterns) ''
      rm -r "$out/generic/yara_patterns/static-code/pe"
    '';
  } // {
    inherit version; # necessary to check the version against the expected version
  };

in stdenv.mkDerivation rec {
  pname = "retdec";

  # If you update this you will also need to adjust the versions of the updated dependencies. You can do this by first just updating retdec
  # itself and trying to build it. The build should fail and tell you which dependencies you have to upgrade to which versions.
  # I've notified upstream about this problem here:
  # https://github.com/avast/retdec/issues/412
  # gcc is pinned to gcc8 in all-packages.nix. That should probably be re-evaluated on update.
  version = "4.0";

  src = fetchFromGitHub {
    owner = "avast";
    repo = "retdec";
    name = "retdec-${version}";
    rev = "refs/tags/v${version}";
    sha256 = "0s2rhd7xaa4qxnxa0b0h1jvkx47m53mz02zb1qarvg4d1vld972j";
  };

  nativeBuildInputs = [
    cmake
    autoconf
    automake
    libtool
    pkgconfig
    bison
    flex
    groff
    perl
    python3
  ];

  buildInputs = [
    ncurses
    libffi
    libxml2
    zlib
  ];

  cmakeFlags = [
    "-DRETDEC_TESTS=ON" # build tests
  ];

  # all dependencies that are normally fetched during build time (the subdirectories of `deps`)
  # all of these need to be fetched through nix and the CMakeLists files need to be patched not to fetch them themselves
  external_deps = [
    (capstone // { dep_name = "capstone"; })
    (googletest // { dep_name = "googletest"; })
    (keystone // { dep_name = "keystone"; })
    (llvm // { dep_name = "llvm"; })
    (yara // { dep_name = "yara"; })
    (yaramod // { dep_name = "yaramod"; })
  ];

  # patches = [
  #   ./temp.patch
  # ];

  postPatch = ''
    # install retdec-support
    mkdir -p "$out/share/retdec"
    cp -r ${retdec-support} "$out/share/retdec/support" # write permission needed during install
    chmod -R u+w "$out/share/retdec/support"
    # python file originally responsible for fetching the retdec-support archive to $out/share/retdec
    # that is not necessary anymore, so empty the file
    echo > support/install-share.py

    mkdir -p "./local-deps"

    cp -r ${capstone} "./local-deps/capstone"
    chmod -R u+w "./local-deps/capstone"
    cmakeFlags="$cmakeFlags -DCAPSTONE_LOCAL_DIR=$(pwd)/local-deps/capstone"

    cp -r ${googletest} "./local-deps/googletest"
    chmod -R u+w "./local-deps/googletest"
    cmakeFlags="$cmakeFlags -DGOOGLETEST_LOCAL_DIR=$(pwd)/local-deps/googletest"

    cp -r ${keystone} "./local-deps/keystone"
    chmod -R u+w "./local-deps/keystone"
    cmakeFlags="$cmakeFlags -DKEYSTONE_LOCAL_DIR=$(pwd)/local-deps/keystone"

    cp -r ${llvm} "./local-deps/llvm"
    chmod -R u+w "./local-deps/llvm"
    cmakeFlags="$cmakeFlags -DLLVM_LOCAL_DIR=$(pwd)/local-deps/llvm"

    cmakeFlags="$cmakeFlags -DOPENSSL_URL=${openssl}"

    cp -r ${yara} "./local-deps/yara"
    chmod -R u+w "./local-deps/yara"
    cmakeFlags="$cmakeFlags -DYARA_URL=$(pwd)/local-deps/yara"

    cp -r ${yaramod} "./local-deps/yaramod"
    chmod -R u+w "./local-deps/yaramod"
    cmakeFlags="$cmakeFlags -DYARAMOD_LOCAL_DIR=$(pwd)/local-deps/yaramod"

    # call correct `time` and `upx` programs
    substituteInPlace scripts/retdec-config.py --replace /usr/bin/time ${time}/bin/time
    substituteInPlace scripts/retdec-unpacker.py --replace "'upx'" "'${upx}/bin/upx'"
  '';


  enableParallelBuilding = true;

  meta = with lib; {
    description = "A retargetable machine-code decompiler based on LLVM";
    homepage = "https://retdec.com";
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill timokau ];
    platforms = ["x86_64-linux" "i686-linux"];
  };
}
