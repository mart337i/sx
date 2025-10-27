# sx - Arch Linux Package

## Installation from AUR

### Using an AUR helper (recommended):

```bash
# With yay
yay -S sx

# With paru
paru -S sx

# With aurman
aurman -S sx
```

### Manual installation:

```bash
# Clone the AUR repository
git clone https://aur.archlinux.org/sx.git
cd sx

# Build and install
makepkg -si
```

## Building Locally

If you want to build from this repository instead of AUR:

```bash
cd arch/
makepkg -si
```

## Post-Installation

To enable the global hotkey (Ctrl+K), add to your `~/.bashrc`:

```bash
source /usr/share/sx/sx-integration.sh
```

## Updating the AUR Package

For maintainers:

1. Update version in `PKGBUILD`
2. Update checksums:
   ```bash
   updpkgsums
   ```
3. Generate `.SRCINFO`:
   ```bash
   makepkg --printsrcinfo > .SRCINFO
   ```
4. Commit and push to AUR:
   ```bash
   git add PKGBUILD .SRCINFO
   git commit -m "Update to version X.Y.Z"
   git push
   ```
