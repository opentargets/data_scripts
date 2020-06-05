#!/usr/bin/env bash

# Check that only one argument is passed
if [[ $# -ne 1 ]]; then
    echo ""
    echo "[ERROR] Illegal number of parameters, one release prefix is required. Run as:"
    echo "> $0 release_prefix"
    echo ""
    exit 1
fi


release_prefix=$1

# Make dir named as the release and work in there
mkdir -p $release_prefix
cd $release_prefix


