#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

echo End >> freenet.ini

# We keep application installers in case users want to perform updates
rm -f 1run.sh cleanup.sh detect_port_availability.sh install_freenet-ext.sh install_freenet-stable-latest.sh install_librarian.sh install_mdns.sh install_plugins.sh install_stun.sh install_updater.sh setup.sh install_startup_hook-mac.sh offline

echo "All done, please click Next"
