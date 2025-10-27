#!/bin/bash
set -e

echo "Building RPM package for sx..."

if ! command -v rpmbuild &> /dev/null; then
    echo "Error: rpmbuild not found."
    echo "Install with:"
    echo "  Fedora/RHEL: dnf install rpm-build rpmdevtools"
    echo "  openSUSE:    zypper install rpm-build"
    exit 1
fi

VERSION=$(grep "^Version:" rpm/sx.spec | awk '{print $2}')
RELEASE=$(grep "^Release:" rpm/sx.spec | awk '{print $2}' | cut -d'%' -f1)

echo "Version: ${VERSION}-${RELEASE}"

# Setup RPM build environment
RPMBUILD_DIR="${HOME}/rpmbuild"
mkdir -p "${RPMBUILD_DIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Create source tarball
TARBALL_NAME="sx-${VERSION}.tar.gz"
TEMP_DIR=$(mktemp -d)
SOURCE_DIR="${TEMP_DIR}/sx-${VERSION}"

mkdir -p "${SOURCE_DIR}"
cp sx "${SOURCE_DIR}/"
cp sx-integration.sh "${SOURCE_DIR}/"
cp README.md "${SOURCE_DIR}/"
cp LICENSE "${SOURCE_DIR}/"

cd "${TEMP_DIR}"
tar czf "${TARBALL_NAME}" "sx-${VERSION}"
mv "${TARBALL_NAME}" "${RPMBUILD_DIR}/SOURCES/"
cd - > /dev/null

rm -rf "${TEMP_DIR}"

# Copy spec file
cp rpm/sx.spec "${RPMBUILD_DIR}/SPECS/"

# Build RPM
echo "Building RPM package..."
rpmbuild -ba "${RPMBUILD_DIR}/SPECS/sx.spec"

# Copy built packages to build directory
BUILD_DIR="build"
mkdir -p "${BUILD_DIR}"

if [ -d "${RPMBUILD_DIR}/RPMS/noarch" ]; then
    cp "${RPMBUILD_DIR}/RPMS/noarch/sx-${VERSION}-${RELEASE}"*.rpm "${BUILD_DIR}/" 2>/dev/null || true
fi

if [ -d "${RPMBUILD_DIR}/SRPMS" ]; then
    cp "${RPMBUILD_DIR}/SRPMS/sx-${VERSION}-${RELEASE}"*.rpm "${BUILD_DIR}/" 2>/dev/null || true
fi

echo ""
echo "Package built successfully:"
ls -lh "${BUILD_DIR}"/*.rpm 2>/dev/null || echo "RPM files in ${RPMBUILD_DIR}/RPMS/"
echo ""
echo "To install locally:"
echo "  sudo dnf install ${BUILD_DIR}/sx-${VERSION}-${RELEASE}.*.noarch.rpm"
echo "  # or"
echo "  sudo rpm -ivh ${BUILD_DIR}/sx-${VERSION}-${RELEASE}.*.noarch.rpm"
echo ""
echo "To test:"
echo "  rpm -qip ${BUILD_DIR}/sx-${VERSION}-${RELEASE}.*.noarch.rpm"
echo "  rpm -qlp ${BUILD_DIR}/sx-${VERSION}-${RELEASE}.*.noarch.rpm"
