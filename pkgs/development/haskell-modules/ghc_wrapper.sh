#!/usr/bin/env bash

if [ "$1" = "--numeric-version" ]; then
    echo "8.4.3"
    exit
fi

INDEXER_OUTPUT_DIR="${out}/share/kythe/"

mkdir -p "${INDEXER_OUTPUT_DIR}"

# GHC wrapper for indexing Haskell packages.
function log () { echo "$1" >> "${INDEXER_OUTPUT_DIR}/${PKG}.log"; }

PKG="${NIX_HASKELL_PACKAGE_NAME}-${NIX_HASKELL_PACKAGE_VERSION}"

printf "\n%s\n" "${*}" >> "${INDEXER_OUTPUT_DIR}/${PKG}.args"

# First run GHC as normal
ghc "$@"
RETVAL="$?"

# Use standard procedure to produce ghc_kythe_wrapper,
# see https://github.com/google/haskell-indexer
if ! ghc_kythe_wrapper                                       \
         --drop_path_prefix    "${NIX_HASKELL_STRIP_PREFIX}" \
         --prepend_path_prefix "${PKG}/"                     \
         -- "$@"                                             \
         >>  "${INDEXER_OUTPUT_DIR}/${PKG}.entries"          \
         2>> "${INDEXER_OUTPUT_DIR}/${PKG}.stderr"; then
    echo "${PKG} had error" >> "${INDEXER_OUTPUT_DIR}/errors"
fi

exit "${RETVAL}"
