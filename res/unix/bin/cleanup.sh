#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
rm -f "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH/bin"

# We keep application installers in case users want to perform updates
rm -f 1run.sh cleanup.sh detect_port_availability.sh setup.sh offline install_*.sh
touch "$INSTALL_PATH/.isInstalled"

echo "All done, please click Next"
