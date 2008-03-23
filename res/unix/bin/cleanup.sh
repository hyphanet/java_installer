#!/bin/sh

. "$HOME/_install_toSource.sh"
rm -f "$HOME/_install_toSource.sh"
cd "$INSTALL_PATH/bin"

# We keep application installers in case users want to perform updates
rm -f 1run.sh cleanup.sh detect_port_availability.sh setup.sh offline install_*.sh

echo "All done, please click Next"
