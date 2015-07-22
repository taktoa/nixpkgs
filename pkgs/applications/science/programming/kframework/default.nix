{ stdenv, maven, openjdk8, buildMaven }:

# TODO:
# - Investigate builds on platforms other than 64-bit linux

let maven8      = maven.override       { jdk = openjdk8; };
    buildMaven8 = buildMaven8.override { maven = maven8; };
    bm = (buildMaven8 { infoFile = ./project-info.json; });
in
stdenv.mkDerivation rec {
  name = "kframework-20150716";

  src = bm.build;

  buildInputs = [ ];

  preUnpack = ''
      ls -l
      exit -1
  '';

  meta = {
    description = "A rewrite-based framework for executable semantics.";
    longDescription = ''
        A rewrite-based executable semantic framework in
        which programming languages, type systems and
        formal analysis tools can be defined.
    '';
    homepage = http://www.kframework.org;
    license = stdenv.lib.licenses.bsd3;
    maintainers = [ stdenv.lib.maintainers.taktoa ];
    platforms = stdenv.lib.platforms.linux; # I haven't done testing on other
                                            # systems, but since it's Java
                                            # it should run anywhere
  };
}


#  settings = ./settings.xml;
# 
#  src = fetchFromGitHub {
#    owner = "kframework";
#    repo = "k";
#    rev = "85a41bc024"; # nightly build for April 15th, 2015
#    sha256 = "01ndfdnqxp2w86pg3ax39sxayb2pfm39lj1h3818zzn86gqwa1vc";
#  };
# 
#  buildInputs = [ mvn8 openjdk8 ];
# 
#  preSetupPhase = ''
#    # z3 needs this to pass tests
#    export LD_LIBRARY_PATH=$(cat $NIX_CC/nix-support/orig-cc)/lib
#    # not sure if this does anything, since it might only speed up incremental builds
#    export MAVEN_OPTS="-XX:+TieredCompilation"
#  '';
# 
#  mvnAssembly = ''
#    mvn package -Dcheckstyle.skip -Dmaven.test.skip=true -Dmaven.repo.local=$M2_REPO
#  '';
# 
#  mvnRelease = ''
#    true # do nothing, since mvn package is sufficient
#  '';
# 
#  # this is a custom version of k-distribution/src/main/scripts/lib/k
#  kscript = ''
#    #!/usr/bin/env bash
#    export JAVA=${openjdk8}/bin/java
# 
#    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$out/lib"
# 
#    export K_OPTS="-Xms64m -Xmx1024m -Xss32m -XX:+TieredCompilation"
#    export MISC_ARGS="-Djava.awt.headless=true"
#    export ARGS="$MISC_ARGS $K_OPTS"
#    $JAVA $ARGS -cp "$out/share/kframework/lib/java/*" org.kframework.main.Main "$@"
#  '';
# 
#  finalPhase = ''
#    # set some environment variables
#    export K_ROOT=$PWD/k-distribution/target/release/k/
#    export K_SHARE=$out/share/kframework/
#    # make requisite directories
#    mkdir -p $out/lib $K_SHARE/lib/native
#    # copy over bin
#    cp -R $K_ROOT/bin                             $K_SHARE/
#    # symlink $out/bin to $out/share/kframework/bin
#    ln -s $K_SHARE/bin                            $out/bin
#    # copy everything relevant to $out/share/kframework
#    # we may want to consider adding the documentation etc.
#    cp -R $K_ROOT/include                         $K_SHARE/
#    cp -R $K_ROOT/lib/java                        $K_SHARE/lib/
#    cp -R $K_ROOT/lib/native/linux                $K_SHARE/lib/native/
#    cp -R $K_ROOT/lib/native/linux64              $K_SHARE/lib/native/
#    # remove Windows batch scripts
#    rm $K_SHARE/bin/*.bat # */
#    # TODO: fix these scripts so they work
#    rm $K_SHARE/bin/kserver $K_SHARE/bin/stop-kserver
#    # make our k wrapper script and substitute $out for its value
#    echo -n "$kscript" | sed "s:\$out:$out:g" > $K_SHARE/lib/k
#    chmod +x $K_SHARE/lib/k
#    # symlink requisite binaries
#    ln -s $K_SHARE/lib/k                           $out/lib/k
#    ln -s $K_SHARE/lib/native/linux/sdf2table      $out/bin/sdf2table
#    ln -s $K_SHARE/lib/native/linux64/z3           $out/bin/z3
#    ln -s $K_SHARE/lib/native/linux64/libz3.so     $out/lib/libz3.so
#    ln -s $K_SHARE/lib/native/linux64/libz3java.so $out/lib/libz3java.so
#    # patch Z3 so it uses the right interpreter/libs
#    patchelf \
#      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
#      --set-rpath $(cat $NIX_CC/nix-support/orig-cc)/lib \
#      --force-rpath \
#      $K_SHARE/lib/native/linux64/z3
#  '';
