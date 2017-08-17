#!/bin/bash

if [ "$1" = "--numeric-version" ]
  then
    echo "8.0.2"
    exit
fi

mkdir -p $out/logs
INDEXER_OUTPUT_DIR=$out/logs
# GHC wrapper for indexing Haskell packages.
# Note that variables INDEXER_OUTPUT_DIR and REALGHC are set outside this script.
log() {
    echo "$1" >> "$INDEXER_OUTPUT_DIR/$PKG.log"
}

#log "GHC $*"
PKG=ghc
# First run GHC as normal
ghc $@
# Use standard procedure to produce ghc_kythe_wrapper, see https://github.com/google/haskell-indexer
if ! ghc_kythe_wrapper \
        --prepend_path_prefix "$PKG/" \
        -- \
        "$@" >> "$INDEXER_OUTPUT_DIR/$PKG.entries" 2>> "$INDEXER_OUTPUT_DIR/$PKG.stderr"; then
    echo "$PKG had error" >> "$INDEXER_OUTPUT_DIR/errors"
fi
