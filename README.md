# sx

Simple SSH connection manager with fuzzy search.

## Install

### Ubuntu/Debian

```bash
wget https://github.com/mart337i/sx/releases/latest/download/sx_1.0.1-1_all.deb
sudo dpkg -i sx_1.0.1-1_all.deb
sudo apt-get install -f
```

### Fedora/RHEL/Rocky/Alma

```bash
wget https://github.com/mart337i/sx/releases/latest/download/sx-1.0.1-1.fc39.noarch.rpm
sudo dnf install sx-1.0.1-1.fc39.noarch.rpm
```

### openSUSE

```bash
wget https://github.com/mart337i/sx/releases/latest/download/sx-1.0.1-1.noarch.rpm
sudo zypper install sx-1.0.1-1.noarch.rpm
```

### Arch Linux

```bash
# From AUR (coming soon)
yay -S sx
# or
paru -S sx

# Manual build
git clone https://github.com/mart337i/sx.git
cd sx/arch
makepkg -si
```

### From Source

```bash
git clone https://github.com/mart337i/sx.git
cd sx
./install.sh
```

## Usage

```bash
sx                    # Show all servers
sx prod               # Search for "prod" servers
sx --add web 1.2.3.4 admin 22  # Add server
sx --remove web       # Remove server
sx --import sites.xml # Import from FileZilla
sx --ssh-config       # Import from ~/.ssh/config
```

Press **Ctrl+K** to open sx from anywhere.

## Import Servers

**From FileZilla:**
1. Open FileZilla → File → Export → Save as XML
2. Run: `sx --import exported-sites.xml`

**Note:** FileZilla exports with folder organization are fully supported - all servers from nested folders will be imported.

**From SSH config:**
```bash
sx --ssh-config              # Import ~/.ssh/config
sx --ssh-config ~/work.conf  # Import specific file
```

## Configuration

Servers are stored in `~/.config/sx/servers`

Override hotkey: `export SX_KEY_BINDING='\C-x'` in ~/.bashrc

## Dependencies

- `fzf` - fuzzy finder
- `ssh` - SSH client

Install on Ubuntu/Debian: `apt install fzf openssh-client`

## Testing

### Test Coverage

sx is tested on multiple distributions to ensure compatibility:

**Tested Distributions:**
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- Fedora 38, 39, 40
- Arch Linux (latest)

**Test Suite:**
- 27 automated tests (BATS framework)
- Import functionality (FileZilla XML, SSH config)
- Search and filtering
- Package installation (.deb, .rpm)

### Run Tests Locally

```bash
# Install BATS testing framework
npm install -g bats

# Run all tests (27 tests)
bats tests/

# Run specific test suite
bats tests/test_import.bats  # 16 tests
bats tests/test_search.bats  # 11 tests
```

All tests run automatically on GitHub Actions for every push and pull request across all supported distributions.
