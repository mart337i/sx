# sx
<img width="1914" height="609" alt="image" src="https://github.com/user-attachments/assets/17d25196-b2c5-4516-a49d-4c9e7f94e475" />

Fast SSH connection manager with fuzzy search. Connect to servers instantly from anywhere.

```bash
sx prod        # Search and connect
sx --import    # Import from FileZilla or SSH config
```

Press **Ctrl+K** from any terminal to launch.

---

## Quick Start

```bash
# Ubuntu/Debian
wget https://github.com/mart337i/sx/releases/latest/download/sx_1.0.1-1_all.deb
sudo dpkg -i sx_1.0.1-1_all.deb

# Fedora/RHEL
wget https://github.com/mart337i/sx/releases/latest/download/sx-1.0.1-1.fc39.noarch.rpm
sudo dnf install sx-1.0.1-1.fc39.noarch.rpm

# Arch Linux (AUR)
yay -S sx

# From source
curl -fsSL https://raw.githubusercontent.com/mart337i/sx/main/install.sh | bash
```

Enable global hotkey:
```bash
echo 'source /usr/share/sx/sx-integration.sh' >> ~/.bashrc
```

---

## Features

**Interactive Search**
- Fuzzy search through all servers
- Filter by name, hostname, or user
- Single match auto-connects

**Import Existing Servers**
- FileZilla XML (supports folder organization)
- SSH config files
- Manual entry

**Smart Workflow**
- Global Ctrl+K hotkey
- Case-insensitive search
- Store unlimited servers
- Zero configuration needed

---

## Usage

```bash
# Interactive selection
sx

# Search for servers
sx prod
sx database
sx 192.168

# Manage servers
sx --add myserver 192.168.1.100 admin 22
sx --remove myserver
sx --list

# Import servers
sx --import filezilla-export.xml
sx --ssh-config ~/.ssh/config
```

**Navigation:**
- Type to filter servers
- Arrow keys to select
- Enter to connect
- Ctrl+C to cancel

---

## Import

**FileZilla**
```bash
# 1. Export from FileZilla
FileZilla → File → Export → Save as sites.xml

# 2. Import
sx --import sites.xml
```

**SSH Config**
```bash
# Import default config
sx --ssh-config

# Import custom config
sx --ssh-config ~/work/ssh-config
```

**Folder Support:** FileZilla exports with nested folders are fully supported.

---

## Configuration

Servers stored in: `~/.config/sx/servers`

Custom hotkey:
```bash
export SX_KEY_BINDING='\C-x'  # Change to Ctrl+X
```

File format (pipe-delimited):
```
prod-web|admin@192.168.1.10:22|192.168.1.10|admin|22
dev-db|root@localhost:3306|localhost|root|3306
```

---

## Requirements

- `fzf` - fuzzy finder
- `ssh` - SSH client

Install on Ubuntu/Debian:
```bash
apt install fzf openssh-client
```

Install on Fedora/RHEL:
```bash
dnf install fzf openssh-clients
```

Install on Arch:
```bash
pacman -S fzf openssh
```

---

## License

MIT License - See LICENSE file for details
