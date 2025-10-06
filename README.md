# sx - Interactive SSH Selector

🚀 **Fast, interactive SSH connection selector with FileZilla import support**

`sx` is a command-line tool that provides a fuzzy-searchable interface for your SSH connections, similar to how `fzf` works with command history (`Ctrl+R`). Import your servers from FileZilla or add them manually, then use `Ctrl+S` to quickly search and connect.

![sx demo](demo.gif)

## ✨ Features

- 🔍 **Fast fuzzy search** powered by [fzf](https://github.com/junegunn/fzf)
- 📁 **FileZilla import** - Import all your existing connections
- ⌨️ **Ctrl+S hotkey** - Quick access from any bash prompt
- 👀 **Live preview** - See connection details before connecting
- 🎨 **Beautiful interface** - Clean, modern terminal UI
- ⚡ **Instant search** - No lag, even with hundreds of servers
- 🔧 **Easy setup** - One command installation

## 📦 Installation

### Quick Install

```bash
git clone https://github.com/yourusername/sx.git
cd sx
./install.sh
```

### Manual Install

1. **Download sx:**
   ```bash
   git clone https://github.com/yourusername/sx.git
   cd sx
   ```

2. **Install dependencies:**
   ```bash
   # Ubuntu/Debian
   sudo apt install fzf openssh-client
   
   # macOS (Homebrew)
   brew install fzf openssh
   
   # Arch Linux
   sudo pacman -S fzf openssh
   ```

3. **Copy files:**
   ```bash
   cp sx ~/.local/bin/
   chmod +x ~/.local/bin/sx
   ```

4. **Add to bashrc:**
   ```bash
   echo 'source ~/sx/sx-integration.sh' >> ~/.bashrc
   source ~/.bashrc
   ```

## 🚀 Quick Start

### 1. Fix Key Binding (if needed)

If Ctrl+S doesn't work after installation:
```bash
./fix-keybind.sh
```
This will help you choose an alternative key like Ctrl+X or Ctrl+F1.

### 2. Import from FileZilla

Export your sites from FileZilla:
1. Open FileZilla
2. File → Export...
3. Select "Export site manager entries"
4. Save as XML file

Then import:
```bash
sx --import /path/to/filezilla-export.xml
```

### 3. Add servers manually

```bash
sx --add "Production Server" "prod.example.com" "deploy" "22"
sx --add "Staging" "staging.example.com" "admin" "2222"
```

### 4. Use sx

```bash
# Interactive mode
sx

# Or use the hotkey
Ctrl+S
```

## 📖 Usage

### Command Line Options

```bash
sx [OPTIONS]

OPTIONS:
    -i, --import FILE       Import servers from FileZilla XML
    -a, --add NAME HOST [USER] [PORT]
                           Add server manually
    -l, --list             List all servers
    -h, --help             Show help
    -v, --version          Show version
```

### Interactive Mode Keys

| Key | Action |
|-----|--------|
| `Enter` | Connect to selected server |
| `Ctrl+R` | Reload server list |
| `Ctrl+E` | Copy connection string to clipboard |
| `Esc`/`Ctrl+C` | Cancel and exit |

### Examples

```bash
# Import FileZilla export
sx --import ~/Downloads/filezilla-export.xml

# Add servers manually
sx --add "My VPS" "192.168.1.100" "root" "22"
sx --add "Web Server" "web.example.com" "www" "2222"

# List all configured servers
sx --list

# Interactive selection (same as Ctrl+S)
sx
```

## 🔧 Configuration

### Files and Directories

- `~/.config/sx/servers` - Server configuration file
- `~/.config/sx/sx-integration.sh` - Bash integration script

### Customization

You can customize fzf options by setting environment variables:

```bash
# Add to ~/.bashrc
export SX_FZF_OPTS="--height=80% --layout=reverse --border --preview-window=right:40%"
```

### Server File Format

The servers file uses a pipe-delimited format:
```
Name|user@host:port|host|user|port
Production|deploy@prod.example.com:22|prod.example.com|deploy|22
Staging|admin@staging.example.com:2222|staging.example.com|admin|2222
```

## 🎯 FileZilla Integration

### Exporting from FileZilla

1. **Open FileZilla**
2. **File Menu** → Export...
3. **Select** "Export site manager entries"
4. **Choose location** and save as XML file
5. **Import with sx:**
   ```bash
   sx --import /path/to/exported-file.xml
   ```

### Supported FileZilla Features

- ✅ Host, User, Port, Name
- ✅ SFTP/SSH connections (Protocol 1)
- ✅ Custom ports
- ❌ Passwords (for security)
- ❌ Private keys (use ssh-agent)
- ❌ FTP connections (SSH only)

## 🔑 SSH Key Management

`sx` uses your system's SSH configuration. For key-based authentication:

1. **Add keys to ssh-agent:**
   ```bash
   ssh-add ~/.ssh/id_rsa
   ```

2. **Or configure in ~/.ssh/config:**
   ```
   Host prod.example.com
       IdentityFile ~/.ssh/production_key
       User deploy
   ```

## 🛠️ Troubleshooting

### Common Issues

**"fzf command not found"**
```bash
# Install fzf
sudo apt install fzf  # Ubuntu/Debian
brew install fzf      # macOS
```

**"sx command not found"**
```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep -q ~/.local/bin || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

**"Ctrl+S doesn't work"**
```bash
# Ctrl+S might be taken by terminal flow control
# Use the fix script to set up an alternative key
./fix-keybind.sh

# Or manually set a different key:
export SX_KEY_BINDING='\C-x'  # Use Ctrl+X instead
source sx-integration.sh

# Check current binding
sx_status
```

**"No servers found"**
```bash
# Check servers file
cat ~/.config/sx/servers

# Import sample data
sx --import ~/.config/sx/sample-filezilla.xml
```

### Debug Mode

Run with debug output:
```bash
bash -x sx --list
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Setup

```bash
git clone https://github.com/yourusername/sx.git
cd sx

# Test the script
./sx --help

# Test installation
./install.sh
```

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Credits

- [fzf](https://github.com/junegunn/fzf) - The amazing fuzzy finder that powers sx
- [FileZilla](https://filezilla-project.org/) - For the inspiration and XML format

## 🔗 Related Projects

- [fzf](https://github.com/junegunn/fzf) - Command-line fuzzy finder
- [ssh-menu](https://github.com/karambaq/ssh-menu) - Another SSH selector
- [storm](https://github.com/emre/storm) - SSH connection manager

---

**Made with ❤️ for the terminal**