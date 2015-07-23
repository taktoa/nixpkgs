{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "nailgun-20150615";

  src = fetchFromGitHub {
    owner = "martylamb";
    repo = "nailgun";
    rev = "7e66308811";
    sha256 = "045iyliwq6smrzx1wsqgfl194q3wqaimnzal5gwbbjcyb13xvkll";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp ng $out/bin
    chmod 755 $out/bin/ng
  '';

  meta = {
    description = "Avoid the JVM startup overhead with a Nailgun server";
    longDescription = ''
        Nailgun is a client, protocol, and server for running Java programs
        from the command line without incurring the JVM startup overhead.
    '';
    homepage = http://www.martiansoftware.com/nailgun/;
    license = stdenv.lib.licenses.asl20;
    maintainers = [ stdenv.lib.maintainers.taktoa ];
    platforms = stdenv.lib.platforms.linux;
  };
}
