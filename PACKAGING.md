# Packaging Guide for sx

This document explains how to build and distribute `sx` packages for multiple Linux distributions.

## Quick Start

### Build Debian/Ubuntu Package (.deb)

```bash
# Install build dependencies
sudo apt-get install dpkg-dev debhelper

# Build the package
./build-deb.sh

# Install locally
sudo dpkg -i build/sx_1.0.1-1_all.deb
```

### Build RPM Package (Fedora/RHEL/openSUSE)

```bash
# Install build dependencies
# Fedora/RHEL:
sudo dnf install rpm-build rpmdevtools

# openSUSE:
sudo zypper install rpm-build

# Build the package
./build-rpm.sh

# Install locally (Fedora/RHEL)
sudo dnf install build/sx-1.0.1-1.*.noarch.rpm

# Install locally (openSUSE)
sudo zypper install build/sx-1.0.1-1.*.noarch.rpm
```

### Build Arch Linux Package

```bash
# Build from arch/ directory
cd arch/
makepkg -si
```

## Package Structure

### Debian/Ubuntu (.deb)
```
debian/
├── changelog          # Version history and release notes
├── control            # Package metadata and dependencies
├── copyright          # License information
├── rules              # Build instructions
├── install            # Files to install
├── compat             # Debhelper compatibility level
└── source/
    └── format         # Source package format
```

### RPM (Fedora/RHEL/openSUSE)
```
rpm/
└── sx.spec            # RPM specification file
```

### Arch Linux (AUR)
```
arch/
├── PKGBUILD           # Build script
├── .SRCINFO           # Package metadata
└── README.md          # AUR-specific documentation
```

## Versioning

Version format: `MAJOR.MINOR.PATCH-REVISION`
- Example: `1.0.1-1`
- Update `debian/changelog` for each release

### Update Version for Debian/Ubuntu

```bash
# Edit debian/changelog - add new entry at the top:
sx (1.0.2-1) focal; urgency=medium

  * New feature description
  * Bug fix description

 -- Your Name <email@example.com>  Mon, 27 Oct 2025 12:00:00 +0000
```

### Update Version for RPM

```bash
# Edit rpm/sx.spec:
# 1. Update Version: field
# 2. Add entry to %changelog section at the bottom
```

### Update Version for Arch

```bash
# Edit arch/PKGBUILD:
# 1. Update pkgver
# 2. Optionally increment pkgrel
# 3. Run: cd arch && makepkg --printsrcinfo > .SRCINFO
```

## GitHub Releases

### Automatic Build on Tag

```bash
# Tag a new release
git tag -a v1.0.1 -m "Release version 1.0.1"
git push origin v1.0.1
```

This triggers `.github/workflows/release.yml` which:
1. Builds .deb package (Ubuntu/Debian)
2. Builds .rpm package (Fedora/RHEL/openSUSE)
3. Runs package tests
4. Creates a GitHub Release
5. Uploads all packages as release assets

### Manual Release

```bash
# Trigger workflow manually from GitHub Actions tab
# Or use gh CLI:
gh workflow run release.yml
```

## Installation Methods

### Method 1: Direct Download (Recommended for Users)

```bash
# Download from GitHub Releases
wget https://github.com/mart337i/sx/releases/download/v1.0.1/sx_1.0.1-1_all.deb

# Install
sudo dpkg -i sx_1.0.1-1_all.deb

# Install dependencies if needed
sudo apt-get install -f
```

### Method 2: Custom APT Repository (Future)

You can host .deb files in a custom APT repository:

1. Create `Packages` file:
```bash
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
```

2. Users add repository:
```bash
echo "deb [trusted=yes] https://yoursite.com/debian/ ./" | sudo tee /etc/apt/sources.list.d/sx.list
sudo apt-get update
sudo apt-get install sx
```

### Method 3: PPA (Future - Official Ubuntu)

To migrate to Launchpad PPA:

1. Create Launchpad account
2. Generate and upload GPG key
3. Build source package:
```bash
debuild -S -sa
```
4. Sign and upload:
```bash
debsign -k YOUR_KEY_ID ../sx_1.0.1-1_source.changes
dput ppa:your-username/sx ../sx_1.0.1-1_source.changes
```

Users install via:
```bash
sudo add-apt-repository ppa:your-username/sx
sudo apt-get update
sudo apt-get install sx
```

## Testing the Package

### Before Release

```bash
# Build package
./build-deb.sh

# Inspect package contents
dpkg-deb -I build/sx_1.0.1-1_all.deb
dpkg-deb -c build/sx_1.0.1-1_all.deb

# Test installation in Docker
docker run -it ubuntu:22.04
apt-get update && apt-get install -y fzf openssh-client
dpkg -i sx_1.0.1-1_all.deb
sx --version
```

### Lintian Check

```bash
# Install lintian
sudo apt-get install lintian

# Check package quality
lintian build/sx_1.0.1-1_all.deb
```

## Package Contents

**Installed files:**
- `/usr/bin/sx` - Main executable
- `/usr/share/sx/sx-integration.sh` - Shell integration script
- `/usr/share/doc/sx/README.md` - Documentation
- `/usr/share/doc/sx/copyright` - License

**User files (created at runtime):**
- `~/.config/sx/servers` - Server list

## Maintenance

### Update Changelog

For each release, update `debian/changelog`:

```bash
# Template
sx (VERSION-REVISION) DISTRIBUTION; urgency=URGENCY

  * Change description
  * Another change

 -- Maintainer Name <email@example.com>  DATE
```

**Urgency levels:** low, medium, high, emergency, critical

### Dependencies

Update `debian/control` if dependencies change:

```
Depends: ${misc:Depends}, fzf, openssh-client
Recommends: bash-completion
Suggests: another-optional-package
```

## Troubleshooting

### Build Fails

```bash
# Clean build artifacts
rm -rf build/ debian/sx/ debian/.debhelper/

# Rebuild
./build-deb.sh
```

### Installation Issues

```bash
# Check dependencies
dpkg -I build/sx_*.deb | grep Depends

# Force install dependencies
sudo apt-get install -f

# Remove and reinstall
sudo dpkg -r sx
sudo dpkg -i build/sx_*.deb
```

### Permission Errors

Ensure scripts are executable:
```bash
chmod +x sx build-deb.sh debian/rules
```

## Resources

- [Debian Packaging Guide](https://www.debian.org/doc/manuals/maint-guide/)
- [Ubuntu Packaging Guide](https://packaging.ubuntu.com/html/)
- [Launchpad PPA Help](https://help.launchpad.net/Packaging/PPA)
- [dpkg-deb Manual](https://manpages.ubuntu.com/manpages/focal/man1/dpkg-deb.1.html)

## Distribution-Specific Guides

### Arch Linux (AUR)

#### Publishing to AUR

1. **Create AUR account** at https://aur.archlinux.org

2. **Setup SSH key** for AUR:
```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub  # Add to AUR account settings
```

3. **Clone AUR repository**:
```bash
git clone ssh://aur@aur.archlinux.org/sx.git sx-aur
cd sx-aur
```

4. **Copy files**:
```bash
cp ../arch/PKGBUILD .
cp ../arch/.SRCINFO .
```

5. **Commit and push**:
```bash
git add PKGBUILD .SRCINFO
git commit -m "Initial commit: sx 1.0.1"
git push
```

#### Updating AUR Package

```bash
cd sx-aur
# Update PKGBUILD with new version
vim PKGBUILD

# Update checksums
updpkgsums

# Generate .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# Commit and push
git add PKGBUILD .SRCINFO
git commit -m "Update to version X.Y.Z"
git push
```

### RPM (Fedora/RHEL/openSUSE)

#### COPR Repository (Fedora's PPA equivalent)

1. **Create COPR account** at https://copr.fedorainfracloud.org

2. **Create new COPR project**:
   - Name: sx
   - Instructions: Point to GitHub releases or upload SRPM

3. **Build from GitHub**:
   - Add GitHub webhook
   - Builds trigger on new releases automatically

4. **Users install via**:
```bash
# Fedora
sudo dnf copr enable your-username/sx
sudo dnf install sx

# RHEL/Rocky/Alma (need EPEL)
sudo dnf install epel-release
sudo dnf copr enable your-username/sx
sudo dnf install sx
```

#### openSUSE Build Service (OBS)

1. **Create account** at https://build.opensuse.org
2. **Create project** and add sx package
3. **Upload** rpm/sx.spec
4. **Users install via** 1-click install or zypper

### Package Testing

#### Test .deb Package

```bash
# Ubuntu 22.04
docker run -it ubuntu:22.04 bash
apt-get update
apt-get install -y wget
wget https://github.com/mart337i/sx/releases/latest/download/sx_1.0.1-1_all.deb
apt-get install -y ./sx_1.0.1-1_all.deb
sx --version
```

#### Test .rpm Package

```bash
# Fedora
docker run -it fedora:latest bash
dnf install -y wget
wget https://github.com/mart337i/sx/releases/latest/download/sx-1.0.1-1.fc*.noarch.rpm
dnf install -y sx-1.0.1-1.fc*.noarch.rpm
sx --version
```

#### Test Arch Package

```bash
# Build in clean chroot (recommended)
cd arch/
makepkg --clean --syncdeps

# Or use extra-x86_64-build (requires devtools)
extra-x86_64-build
```

## Release Checklist

Before releasing a new version:

- [ ] Update version in all package files:
  - [ ] `debian/changelog`
  - [ ] `rpm/sx.spec`
  - [ ] `arch/PKGBUILD`
  - [ ] `sx` script (VERSION variable)
- [ ] Run all tests: `bats tests/`
- [ ] Build all packages locally:
  - [ ] `./build-deb.sh`
  - [ ] `./build-rpm.sh`
  - [ ] `cd arch && makepkg`
- [ ] Test packages in containers
- [ ] Update `arch/.SRCINFO`: `makepkg --printsrcinfo > .SRCINFO`
- [ ] Commit all changes
- [ ] Tag release: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Push tag: `git push origin vX.Y.Z`
- [ ] Wait for GitHub Actions to build packages
- [ ] Update AUR repository
- [ ] (Optional) Update COPR/OBS if configured

## Troubleshooting

### Debian Package Issues

**Error: `dpkg-deb: error: failed to open package info file`**
- Solution: Run `./build-deb.sh` instead of manual dpkg-deb

**Error: `dependency problems`**
- Solution: Run `sudo apt-get install -f` after dpkg

### RPM Package Issues

**Error: `rpmbuild: command not found`**
- Solution: Install rpm-build: `dnf install rpm-build rpmdevtools`

**Error: `File not found: /builddir/build/SOURCES/sx-1.0.1.tar.gz`**
- Solution: Run `./build-rpm.sh` which creates the tarball automatically

### Arch Package Issues

**Error: `==> ERROR: One or more PGP signatures could not be verified!`**
- Solution: Skip PGP check during testing: `makepkg --skippgpcheck`

**Error: `updpkgsums: command not found`**
- Solution: Install pacman-contrib: `pacman -S pacman-contrib`

