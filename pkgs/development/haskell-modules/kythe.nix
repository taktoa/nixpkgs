{ stdenv, lib, kythe, runCommand, writeScriptBin, packages }:

with rec {
  bs = builtins;
  uniquify = f: list: bs.attrValues (
    bs.foldl' (xs: x: xs // { ${f x} = x; }) {} list);
  uniquifyDrvs = uniquify (x: bs.unsafeDiscardStringContext (x.outPath or ""));

  computeClosure = (
    with rec {
      isDrv = drv: (bs.isAttrs drv) && ((drv.type or "") == "derivation");

      hasIndex = drv: (
        bs.pathExists
        "${bs.unsafeDiscardStringContext drv.outPath}/share/kythe/${drv.name}.entries");

      go = package: (
        rec {
          inputs = uniquifyDrvs (bs.filter isDrv (bs.concatLists [
            (package.buildInputs                 or [])
            (package.nativeBuildInputs           or [])
            (package.propagatedBuildInputs       or [])
            (package.propagatedNativeBuildInputs or [])
          ]));
          result = (
            if isDrv package
            then uniquifyDrvs ([package] ++ bs.concatLists (bs.map go inputs))
            else []);
        }).result;
    };
    pkg: bs.filter hasIndex (uniquifyDrvs (bs.filter isDrv (go pkg))));
  computeClosureAll = (
    ps: uniquifyDrvs (bs.concatLists (bs.map computeClosure ps)));
};

assert (bs.isList packages);
assert (lib.all (x: x.isHaskellLibrary or false) packages);

with rec {
  closure = computeClosureAll packages;
  toEntries = p: "${p.outPath}/share/kythe/${p.name}.entries";
  entries = bs.concatStringsSep " " (bs.map toEntries closure);

  graphStore = runCommand "kythe-gs" {} ''
    mkdir -pv "$out"
    for entries_file in ${entries}; do
        ${kythe}/tools/write_entries        \
            --graphstore "$out"             \
            --workers    "$NIX_BUILD_CORES" \
            < "$entries_file"
    done
  '';

  servingTable = runCommand "kythe-table" {} ''
    mkdir -pv "$out"
    cp -R --reflink=auto --no-preserve=mode,ownership ${graphStore} ./gs
    ${kythe}/tools/write_tables --graphstore ./gs --out "$out"
  '';

  # FIXME: this script is broken because serving table must be writable
  result = writeScriptBin "kythe-local" ''
    KYTHE_TEMP="$(mktemp -d --tmpdir "kythe-local-db.XXXXXX")"
    trap 'rm -rf "$KYTHE_TEMP"' EXIT
    cp -R --reflink=auto --no-preserve=mode,ownership \
        ${servingTable} "$KYTHE_TEMP/serve"
    ${kythe}/tools/http_server             \
        --listen           localhost:8080  \
        --public_resources ${kythe}/web/ui \
        --serving_table    "$KYTHE_TEMP/serve"
    rm -rf "$KYTHE_TEMP"
  '';
};

result
