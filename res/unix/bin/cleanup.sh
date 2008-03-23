#!/bin/sh

. _install_toSource.sh
rm -f _install_toSource.sh
cd "$INSTALL_PATH"

# We keep application installers in case users want to perform updates
rm -f 1run.sh cleanup.sh detect_port_availability.sh install_freenet-ext.sh install_freenet-stable-latest.sh install_librarian.sh install_mdns.sh install_plugins.sh install_stun.sh install_updater.sh install_frost.sh setup.sh install_startup_hook-mac.sh offline opennet.install


echo "All done, please click Next"
