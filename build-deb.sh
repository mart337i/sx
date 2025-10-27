#!/bin/bash
set -e

echo "Building Debian package for sx..."

if ! command -v dpkg-deb &> /dev/null; then
    echo "Error: dpkg-deb not found. Install with: apt install dpkg-dev"
    exit 1
fi

VERSION=$(grep "^sx (" debian/changelog | head -1 | sed 's/sx (\(.*\)).*/\1/')
ARCH="all"
BUILD_DIR="build"
PACKAGE_DIR="${BUILD_DIR}/sx_${VERSION}_${ARCH}"

echo "Version: ${VERSION}"
echo "Architecture: ${ARCH}"

rm -rf "${BUILD_DIR}"
mkdir -p "${PACKAGE_DIR}/DEBIAN"
mkdir -p "${PACKAGE_DIR}/usr/bin"
mkdir -p "${PACKAGE_DIR}/usr/share/sx"
mkdir -p "${PACKAGE_DIR}/usr/share/doc/sx"

install -m 0755 sx "${PACKAGE_DIR}/usr/bin/sx"
install -m 0644 sx-integration.sh "${PACKAGE_DIR}/usr/share/sx/sx-integration.sh"

install -m 0644 README.md "${PACKAGE_DIR}/usr/share/doc/sx/"
install -m 0644 LICENSE "${PACKAGE_DIR}/usr/share/doc/sx/copyright"

cat > "${PACKAGE_DIR}/DEBIAN/control" << EOF
Package: sx
Version: ${VERSION}
Section: admin
Priority: optional
Architecture: ${ARCH}
Depends: fzf, openssh-client
Maintainer: Martin Egeskov <mart337i@gmail.com>
Homepage: https://github.com/mart337i/sx
Description: Simple SSH connection manager with fuzzy search
 sx is an interactive SSH connection selector that allows you to
 manage and connect to servers using fuzzy search with fzf.
 .
 Features:
  * Interactive server selection with fuzzy search
  * Import servers from FileZilla XML exports (with folder support)
  * Import servers from SSH config files
  * Add/remove servers via command line
  * Global hotkey (Ctrl+K) for quick access
  * Case-insensitive search
  * Server filtering by name, host, or username
EOF

cat > "${PACKAGE_DIR}/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

if [ "$1" = "configure" ]; then
    echo ""
    echo "sx has been installed successfully!"
    echo ""
    echo "To enable the global hotkey (Ctrl+K), add this to your ~/.bashrc:"
    echo "  source /usr/share/sx/sx-integration.sh"
    echo ""
    echo "Get started with:"
    echo "  sx --help"
    echo ""
fi

exit 0
EOF

chmod 0755 "${PACKAGE_DIR}/DEBIAN/postinst"

cd "${PACKAGE_DIR}"
find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P\n' | xargs md5sum > DEBIAN/md5sums
cd - > /dev/null

dpkg-deb --build --root-owner-group "${PACKAGE_DIR}"

echo ""
echo "Package built successfully:"
ls -lh "${BUILD_DIR}"/*.deb
echo ""
echo "To install locally:"
echo "  sudo dpkg -i ${BUILD_DIR}/sx_${VERSION}_${ARCH}.deb"
echo ""
echo "To test:"
echo "  dpkg-deb -I ${BUILD_DIR}/sx_${VERSION}_${ARCH}.deb"
echo "  dpkg-deb -c ${BUILD_DIR}/sx_${VERSION}_${ARCH}.deb"
