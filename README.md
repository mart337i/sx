# sx

Simple SSH connection manager with fuzzy search.

## Install

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
sx --import sites.xml # Import from FileZilla
sx --ssh-config       # Import from ~/.ssh/config
```

Press **Ctrl+K** to open sx from anywhere.

## Import Servers

**From FileZilla:**
1. Open FileZilla → File → Export → Save as XML
2. Run: `sx --import exported-sites.xml`

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