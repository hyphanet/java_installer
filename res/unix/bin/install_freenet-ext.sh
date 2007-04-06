#!/bin/bash

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

echo "Downloading freenet-ext.jar"
java -jar bin/sha1test.jar freenet-ext.jar "$INSTALL_PATH" &>/dev/null || exit 1
