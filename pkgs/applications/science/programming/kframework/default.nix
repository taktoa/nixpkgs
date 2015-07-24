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

    normDir = set@{ name, plat, arch, ... }: { dir = "${plat}${arch}"; } // set;

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
buildMaven {
#  inherit extraDepends;
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


  # Needs to be added because of a bug in mvn2nix
  # https://github.com/NixOS/mvn2nix-maven-plugin/issues/4
  extraDeps = let
    mavenRepo = "https://repo.maven.apache.org/maven2";
    rvRepo = "http://office.runtimeverification.com:8888/repository/internal";
    genPath = lib.replaceChars ["."] ["/"];
    genDep = args@{ repo, aid, gid, ver, ext, sha1 }:
      let groupId = gid; artifactId = aid; extension = ext; version = ver;
          file = "${aid}-${ver}${ext}";
          url = "${repo}/${genPath gid}/${aid}/${ver}/${file}";
      in { inherit artifactId groupId version extension url sha1;
           classifier = ""; dependencies = []; relocations = [];
           authenticated = false;
         };
    genDeps = common: diff: map genDep (map (x: common // x) diff);
    genPom = args: [ (genDep ({ ext = ".pom"; } // args)) ];
    genJar = args: [ (genDep ({ ext = ".jar"; } // args)) ];
    genPomAndJar = args@{ repo, aid, gid, ver, pomSHA1, jarSHA1 }:
      genDeps { inherit repo aid gid ver; }
              [ { ext = ".pom"; sha1 = pomSHA1; }
                { ext = ".jar"; sha1 = jarSHA1; } ];

  in concatLists [
    (genDeps {
      repo = mavenRepo;
      aid  = "compiler-interface";
      gid  = "com.typesafe.sbt";
      ver  = "0.13.5";
      ext  = "-sources.jar";
      sha1 = "g2v2p2hgdyg34dgdm18p95gxwxv0xi3x";
    } [{}])
  
    (genPom {
      repo = mavenRepo;
      aid  = "maven-shared-components";
      gid  = "org.apache.maven.shared";
      ver  = "9";
      sha1 = "pbk9yfid09giz19h4l9n6v0l5kzhpkmz";
    })
    (genPom {
      repo = mavenRepo;
      aid  = "doxia";
      gid  = "org.apache.maven.doxia";
      ver  = "1.1.2";
      sha1 = "8qymijv07raw5p8lzm53xaxamhr813v6";
    })

    (genPomAndJar {
      repo = mavenRepo;
      aid  = "doxia-logging-api";
      gid  = "org.apache.maven.doxia";
      ver  = "1.1.2";
      pomSHA1 = "p97mn0cxxc8c4gshc1gpbw6w84iyp6sb";
      jarSHA1 = "zmyjrscxq0ap3dc1gnzy0qicj1dkidqk";
    })
    (genPomAndJar {
      repo = mavenRepo;
      aid  = "scala-library";
      gid  = "org.scala-lang";
      ver  = "2.10.4";
      pomSHA1 = "34nrw9msw6d61db9ng6jhdwnw8kzc7ck";
      jarSHA1 = "gldb6izz8jvwm21nw02dcdr5h2qlrbls";
    })
    (genPomAndJar {
      repo = mavenRepo;
      aid  = "incremental-compiler";
      gid  = "com.typesafe.sbt";
      ver  = "0.13.5";
      pomSHA1 = "jr6yray5w5rgzcc7l2nvrmzr14hydhw8";
      jarSHA1 = "rw6ni54m2s281gcahks370mvv07qn76j";
    })
    (genPomAndJar {
      repo = mavenRepo;
      aid  = "scala-maven-plugin";
      gid  = "net.alchim31.maven";
      ver  = "3.2.0";
      pomSHA1 = "dmf68jxvi9wjsq64xs34a9ywczszhkx5";
      jarSHA1 = "pp105s861l359z47qyr6gadrv1xpyzdg";
    })
    (genPomAndJar {
      repo = mavenRepo;
      aid  = "maven-dependency-tree";
      gid  = "org.apache.maven.shared";
      ver  = "1.2";
      pomSHA1 = "80n819x595jilzxkdvcp4yydampg42lq";
      jarSHA1 = "0lw44c0x5dgnxx90zivwasvqxz8nlfk5";
    })
    (genPomAndJar {
      repo = mavenRepo;
      aid  = "commons-exec";
      gid  = "org.apache.commons";
      ver  = "1.1";
      pomSHA1 = "j3pc9akrfw78qdk56nh440k1hp8sa3l2";
      jarSHA1 = "l55s84frsrg851j3aq060wnyz8bdzpq7";
    })
    (genPomAndJar {
      repo = mavenRepo;
      aid  = "doxia-sink-api";
      gid  = "org.apache.maven.doxia";
      ver  = "1.1.2";
      pomSHA1 = "0vjd99ws5jd1wf76l1i2qrfy7pnnw4vm";
      jarSHA1 = "xi7kbh78z84zvyargy2v39hw69mk66mn";
    })
    (genPomAndJar {
      repo = mavenRepo;
      aid  = "zinc";
      gid  = "com.typesafe.zinc";
      ver  = "0.3.5";
      pomSHA1 = "fad7vpjjd2fm5nmdsmac4q7mchj4a6pq";
      jarSHA1 = "yd0wgw7v0b1bp20ni8dl1l7aymr7i2xa";
    })

    (genPomAndJar {
      repo = rvRepo;
      aid  = "pcollections";
      gid  = "org.pcollections";
      ver  = "2.1.2";
      pomSHA1 = "ay1h16jjvk2hssq58d5z4xvx9diynq8m";
      jarSHA1 = "ca1wnn6aqlwd4j5080zzwa9aqgb5z4hm";
    })
    (genPomAndJar {
      repo = rvRepo;
      aid  = "automaton";
      gid  = "dk.brics.automaton";
      ver  = "1.11-8";
      pomSHA1 = "ynr2kgbyw3m4zjy9j38xk499z5q6mqaf";
      jarSHA1 = "1xnwjk5w1ispmgi3b9qlpzrinigadgvf";
    })
    (genPomAndJar {
      repo = rvRepo;
      aid  = "scala-java8-compat_2.11";
      gid  = "org.scala-lang.modules";
      ver  = "0.3.0";
      pomSHA1 = "kvpcxply5y23lydvl749pn8x0l8pd8jv";
      jarSHA1 = "ym4dnqnbj79fp714725i2phz09d2yrpc";
    })
  ];
}

#      authenticated = false;
#      url = "FIX";
#      sha1 = "FIX";
#      relocations = [];




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
