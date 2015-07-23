{ stdenv, openjdk8, buildMaven, runCommand, writeText, lib
, fetchFromGitHub, nailgun, ocamlPackages, ocaml, ocamlnat
, skipKTest   ? false
, includeMisc ? true
, isWindows   ? false # set to true on Windows systems
}:

with builtins;

let kscript = writeText "kscript" ''
        #!/usr/bin/env bash
        export JAVA=${openjdk8}/bin/java
        export K_OPTS="-Xms64m -Xmx1024m -Xss32m -XX:+TieredCompilation"
        export K_ARGS="-Djava.awt.headless=true $K_OPTS"
        export CLASSPATH_DIR="$(basename $0)/../share/kframework/lib/java/*"
        $JAVA $K_ARGS -cp "$CLASSPATH_DIR" org.kframework.main.Main "$@"
    '';

    incMisc = toString includeMisc;

    mapSet = val: set: getAttr (if hasAttr val set then val else "_") set;

    checkSys = mapSet currentSystem {
      "i686-linux"    = x: (x.plat == "linux") && (x.arch == "32");
      "x86_64-linux"  = x: (x.plat == "linux") && (x.arch == "64");
      "i686-darwin"   = x: (x.plat == "osx")   && (x.arch == "32");
      "x86_64-darwin" = x: (x.plat == "osx")   && (x.arch == "64");
      "_"             = x: true;
    };

    libSuffix = p: mapSet p {
      "linux"   = "so";
      "osx"     = "dylib";
      "windows" = "dll";
      "_"       = (assert false; "");
    };

    normDir = set@{ name, plat, arch, ... }: ({ dir = "${plat}${arch}"; } // set);

    linkBin = { name, dir, plat, ... }: ''
        mkdir -p $K_SHARE/lib/native/${dir}
        cp $K_ROOT/lib/native/${dir} \
           $K_SHARE/lib/native/${dir}/${name}
        ln -s $K_SHARE/lib/native/${dir}/${name} \
              $out/lib/${name};
    '';

    linkLib = { name, dir, plat, ... }: ''
        mkdir -p $K_SHARE/lib/native/${dir}
        cp $K_ROOT/lib/native/${dir} \
           $K_SHARE/lib/native/${dir}/${name}.${libSuffix plat}
        ln -s $K_SHARE/lib/native/${dir}/${name}.${libSuffix plat} \
              $out/lib/${name}.${libSuffix plat};
    '';

    patchBin = { name, dir, ... }: ''
        patchelf \
          --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath $(cat $NIX_CC/nix-support/orig-cc)/lib \
          --shrink-rpath \
          $K_SHARE/lib/native/${dir}/${name};
    '';
    
    patchBins   = map (a: patchBin (normDir a));
    genBinLinks = map (a: linkBin (normDir a));
    genLibLinks = map (a: linkLib (normDir a));

    nativeBins = filter checkSys [
      { name = "sdf2table";     plat = "linux";   arch = "";   }
      { name = "ng";            plat = "linux";   arch = "";   }
      { name = "z3";            plat = "linux";   arch = "32"; }
      { name = "z3";            plat = "linux";   arch = "64"; }

      { name = "sdf2table";     plat = "osx";     arch = "";   }
      { name = "ng";            plat = "osx";     arch = "";   }
      { name = "z3";            plat = "osx";     arch = "";   }

      { name = "sdf2table.exe"; plat = "windows"; arch = "";   }
      { name = "ng.exe";        plat = "windows"; arch = "";   }
      { name = "z3.exe";        plat = "windows"; arch = "32"; }
      { name = "z3.exe";        plat = "windows"; arch = "64"; }
    ];

    nativeLibs = filter checkSys [
      { name = "libz3";         plat = "linux";   arch = "32"; }
      { name = "libz3java";     plat = "linux";   arch = "32"; }
      { name = "libz3";         plat = "linux";   arch = "64"; }
      { name = "libz3java";     plat = "linux";   arch = "64"; }
                                
      { name = "libz3";         plat = "osx";     arch = "";   }
      { name = "libz3java";     plat = "osx";     arch = "";   }
                                
      { name = "cygwin1";       plat = "windows"; arch = "";   }
      { name = "libz3";         plat = "windows"; arch = "32"; }
      { name = "z3java";        plat = "windows"; arch = "32"; }
      { name = "msvcp100";      plat = "windows"; arch = "32"; dir = "32"; }
      { name = "msvcr100";      plat = "windows"; arch = "32"; dir = "32"; }
      { name = "vcomp100";      plat = "windows"; arch = "32"; dir = "32"; }
      { name = "msvcp100";      plat = "windows"; arch = "64"; dir = "64"; }
      { name = "msvcr100";      plat = "windows"; arch = "64"; dir = "64"; }
      { name = "vcomp100";      plat = "windows"; arch = "64"; dir = "64"; }
    ];
in
buildMaven rec {
  name = "kframework-20150716";

  infoFile = ./project-info.json;

  src = fetchFromGitHub {
    owner = "kframework";
    repo = "k";
    rev = "9847224ab0"; # nightly build for July 16th, 2015
    sha256 = "1agyycavlp9083w2kgxvxhv14kpd3dcbmq64vq546ikl63w13pby";
  };

  overrideJDK = openjdk8;

  buildInputs = [
    nailgun
    ocaml
    ocamlnat
    ocamlPackages.zarith
    ocamlPackages.findlib
  ];

  genDoc = includeMisc;
  
  testFlags = if skipKTest then "-DskipKTest" else "";

  preConfigure = ''
      export MAVEN_OPTS="-XX:+TieredCompilation"
  '';
    
  postBuild = ''
      # z3 needs this to pass tests
      export LD_LIBRARY_PATH=$(cat $NIX_CC/nix-support/orig-cc)/lib
      export K_ROOT=$PWD/k-distribution/target/release/k/
  '';

  postPackagePhase = ''
      export K_SHARE=$out/share/kframework/
      mkdir -p $out/lib

      # TODO: fix kserver
      rm $K_ROOT/bin/kserver     $K_ROOT/bin/stop-kserver
      rm $K_ROOT/bin/kserver.bat $K_ROOT/bin/stop-kserver.bat

      ${if isWindows then "" else "rm $K_ROOT/bin/*.bat"}

      cp -R $K_ROOT/bin                                   $K_SHARE/bin
      cp -R $K_ROOT/include                               $K_SHARE/include
      cp -R $K_ROOT/lib/java                              $K_SHARE/lib/java
      
      ${incMisc} && cp -R $K_ROOT/documentation           $K_SHARE/documentation
      ${incMisc} && cp -R $K_ROOT/samples                 $K_SHARE/samples
      ${incMisc} && cp -R $K_ROOT/tutorial                $K_SHARE/tutorial
      ${incMisc} && cp -R target/site/apidocs             $K_SHARE/javadocs

      ${lib.concatStrings (genBinLinks nativeBins ++ genLibLinks nativeLibs)}

      ${lib.concatStrings (patchBins nativeBins)}

      cat ${kscript} > $K_SHARE/lib/k
      chmod 755 $K_SHARE/lib/k

      ln -s $K_SHARE/bin                                  $out/bin
      ln -s $K_SHARE/lib/k                                $out/lib/k
  '';
}





# // This file was generated by running the following commands:
# //
# //     test -f project-info.json && rm project-info.json
# //     cp header.txt project-info.json
# //     echo "\n// Commit: $COMMIT\n" >> project-info.json
# //     wget "https://github.com/kframework/k/archive/$COMMIT.zip"
# //     unzip $COMMIT.zip && rm $COMMIT.zip && cd k-$COMMIT
# //     mvn org.nixos.mvn2nix:mvn2nix-maven-plugin:mvn2nix
# //     cat project-info.json | jq '.' >> ../project-info.json
# //     cd .. && rm -rf k-$COMMIT
# //
# // where header.txt is the file containing this text
# //   and $COMMIT is the commit for which this was run
# //
# // Dependencies: jq, wget, unzip, maven 3, bash (or similar)
#
# // Commit: 9847224ab03bca5d37394cb04cf1dbe9e6c5298b
