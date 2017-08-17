{ stdenv, binutils , fetchurl, glibc }:

stdenv.mkDerivation rec {
  version = "0.0.26";
  name = "kythe-${version}";

  src = fetchurl {
    url = "https://github.com/google/kythe/releases/download/v0.0.26/kythe-v0.0.26.tar.gz";
    sha256 = "0dij913fjymrbdlfjnr65ib90x5xd3smia3bh83q9prh7sfi5h07";
  };

  buildInputs =
    [ binutils ];

  doCheck = false;

  buildPhase = ''
  '';

  testPhase = ''
  '';

  installPhase = ''
    cd tools
    for exe in http_server \
                kwazthis kythe read_entries triples verifier \
                write_entries write_tables; do
      echo "Patching:" $exe
      patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $exe
      patchelf --set-rpath "${stdenv.cc.cc.lib}/lib64" $exe
    done
    cd ../
    cp -R ./ $out
  '';

  meta = with stdenv.lib; {
    description = "kythe";
    longDescription = ''
      The Kythe project was founded to provide and support tools and standards
      that encourage interoperability among programs that manipulate source
      code. At a high level, the main goal of Kythe is to provide a standard,
      language-agnostic interchange mechanism, allowing tools that operate on
      source code including build systems, compilers, interpreters, static
      analyses, editors, code-review applications, and more to share
      information with each other smoothly.
    '';
    homepage = https://kythe.io/;
    license = stdenv.lib.licenses.asl20;
    platforms = stdenv.lib.platforms.all;
  };
