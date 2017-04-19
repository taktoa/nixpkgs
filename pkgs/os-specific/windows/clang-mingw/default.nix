{ runCommand
, lib
, llvm
, clang
, binutils
, stdenv
, coreutils
, gnugrep
}:

{ prefix
, arch
}:

let
  # TODO: Properly integrate with gcc-cross-wrapper
  wrapper = import ../../../build-support/cc-wrapper {
    inherit stdenv coreutils gnugrep;
    nativeTools = false;
    nativeLibc = false;
    inherit binutils;
    libc = runCommand "empty-libc" {} "mkdir -p $out/{lib,include}";
    cc = clang;
    extraBuildCommands = ''
      tr '\n' ' ' < "$out/nix-support/cc-cflags" > cc-cflags.tmp
      mv cc-cflags.tmp "$out/nix-support/cc-cflags"
      echo " -target ${prefix} -arch ${arch} " \
          >> $out/nix-support/cc-cflags

      # Purposefully overwrite libc-ldflags-before, cctools ld doesn't know
      # dynamic-linker and cc-wrapper doesn't do cross-compilation well enough
      # to adjust
      echo " -arch ${arch} " \
          > $out/nix-support/libc-ldflags-before
    '';
  };
in {
  cc = runCommand "${prefix}-cc" {} ''
    mkdir -p $out/bin
    ln -sv ${wrapper}/bin/clang $out/bin/${prefix}-cc
    mkdir -p $out/nix-support
    echo ${llvm} > $out/nix-support/propagated-native-build-inputs
    cat > $out/nix-support/setup-hook <<EOF
    if test "\$dontSetConfigureCross" != "1"; then
        configureFlags="\$configureFlags --host=${prefix}"
    fi
    EOF
    fixupPhase
  '';

  binutils = runCommand "${prefix}-binutils" {} ''
    mkdir -p $out/bin
    ln -sv ${wrapper}/bin/ld $out/bin/${prefix}-ld
    for prog in ar nm ranlib; do
      ln -s ${binutils}/bin/$prog $out/bin/${prefix}-$prog
    done
    fixupPhase
  '';
}
