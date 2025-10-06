# sx - Interactive SSH Connection Manager

🚀 **Professional SSH connection management with lightning-fast search**

`sx` is a modern command-line tool that transforms SSH connection management. Import your existing FileZilla configurations or add servers manually, then use a single hotkey to search and connect instantly. Built for developers and system administrators who manage multiple servers.

<div align="center">

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/mart337i/sx)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

</div>

---

## ✨ Features

🔍 **Fuzzy Search** - Find servers instantly with intelligent search  
📁 **FileZilla Integration** - Import existing connections seamlessly  
⌨️ **Customizable Hotkeys** - Quick access with Ctrl+S, Ctrl+X, or custom keys  
👀 **Live Preview** - See connection details before connecting  
🎨 **Beautiful Interface** - Clean, professional terminal UI  
⚡ **Zero Latency** - Instant search across hundreds of servers  
🔧 **One-Command Setup** - Install and configure in seconds  
🔒 **Secure** - Uses your existing SSH keys and configuration  

---

## 📦 Installation

### Quick Install

```bash
git clone git@github.com:mart337i/sx.git
cd sx
./install.sh
```

The installer will:
- ✅ Check dependencies (fzf, ssh)
- ✅ Install sx to `~/.local/bin`
- ✅ Set up shell integration
- ✅ Configure hotkey binding

### Manual Installation

1. **Clone the repository:**
   ```bash
   git clone git@github.com:mart337i/sx.git
   cd sx
   ```

2. **Install dependencies:**
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install fzf openssh-client
   
   # macOS (Homebrew)
   brew install fzf openssh
   
   # Arch Linux
   sudo pacman -S fzf openssh
   
   # CentOS/RHEL/Fedora
   sudo dnf install fzf openssh-clients
   ```

3. **Install sx:**
   ```bash
   cp sx ~/.local/bin/
   chmod +x ~/.local/bin/sx
   ```

4. **Set up shell integration:**
   ```bash
   echo 'source ~/.config/sx/sx-integration.sh' >> ~/.bashrc
   source ~/.bashrc
   ```

---

## 🚀 Quick Start

### 1. Fix Key Binding (if needed)

If Ctrl+S doesn't work after installation (common with terminal flow control):
```bash
./fix-keybind.sh
```
Choose an alternative like Ctrl+X, Ctrl+O, or Ctrl+F1.

### 2. Import from FileZilla

**Export from FileZilla:**
1. Open FileZilla
2. **File** → **Export...**
3. Select **"Export site manager entries"**
4. Save as XML file

**Import to sx:**
```bash
sx --import /path/to/filezilla-export.xml
```

### 3. Add Servers Manually

```bash
sx --add "Production Server" "prod.example.com" "deploy" "22"
sx --add "Staging Server" "staging.example.com" "admin" "2222"
sx --add "Database Server" "db.example.com" "postgres" "22"
```

### 4. Start Using

```bash
# Interactive mode
sx

# Or use your configured hotkey (Ctrl+S, Ctrl+X, etc.)
# Press the hotkey from any bash prompt
```

---

## 📖 Usage Guide

### Command Line Interface

```bash
sx [OPTIONS]

OPTIONS:
    -i, --import FILE       Import servers from FileZilla XML export
    -a, --add NAME HOST [USER] [PORT]
                           Add server manually
    -l, --list             List all configured servers
    -h, --help             Show detailed help
    -v, --version          Show version information

EXAMPLES:
    sx                                    # Interactive server selection
    sx --import ~/filezilla-sites.xml    # Import FileZilla export
    sx --add "Web Server" "web.example.com" "www" "2222"
    sx --list                            # List all servers
```

### Interactive Mode

| Key | Action |
|-----|--------|
| `Enter` | Connect to selected server |
| `Ctrl+R` | Reload server list |
| `Ctrl+E` | Copy connection string to clipboard |
| `Esc` / `Ctrl+C` | Cancel and exit |
| `↑` `↓` | Navigate servers |
| `Type` | Search/filter servers |

### Advanced Examples

```bash
# Import multiple FileZilla exports
sx --import ~/work-servers.xml
sx --import ~/personal-servers.xml

# Add servers with custom configurations
sx --add "Jump Server" "bastion.company.com" "jump" "22"
sx --add "High Port Server" "secure.example.com" "admin" "9922"

# Quick server management
sx --list | grep "prod"  # Find production servers
```

---

## 🔧 Configuration

### File Locations

```
~/.config/sx/servers              # Server configuration database
~/.config/sx/sx-integration.sh    # Shell integration script
~/.local/bin/sx                   # Main executable
```

### Custom Key Bindings

Set a custom hotkey before loading integration:

```bash
# Add to ~/.bashrc
export SX_KEY_BINDING='\C-o'     # Use Ctrl+O
export SX_KEY_BINDING='\M-s'     # Use Alt+S
export SX_KEY_BINDING='\e[1;5P'  # Use Ctrl+F1

source ~/.config/sx/sx-integration.sh
```

### Customizing fzf Options

```bash
# Add to ~/.bashrc for custom sx appearance
export SX_FZF_OPTS="--height=80% --layout=reverse --border --preview-window=right:40%"
```

### Server File Format

The server database uses pipe-delimited format:
```
Name|user@host:port|host|user|port
Production|deploy@prod.example.com:22|prod.example.com|deploy|22
Staging|admin@staging.example.com:2222|staging.example.com|admin|2222
```

---

## 🎯 FileZilla Integration

### Supported Features

- ✅ **Host, User, Port, Name** - Full server details
- ✅ **SFTP/SSH connections** (Protocol 1)
- ✅ **Custom ports** - Non-standard SSH ports
- ✅ **Bulk import** - Import hundreds of servers at once

### Not Supported (by design)

- ❌ **Passwords** - Use SSH keys for security
- ❌ **Private key files** - Configure in `~/.ssh/config`
- ❌ **FTP connections** - SSH/SFTP only

### FileZilla Export Process

1. **Open FileZilla Site Manager** (Ctrl+S)
2. **File Menu** → **Export...**
3. **Select** "Export site manager entries"
4. **Choose location** and save as `.xml` file
5. **Import with sx:**
   ```bash
   sx --import /path/to/exported-sites.xml
   ```

---

## 🔑 SSH Key Management

`sx` integrates seamlessly with your existing SSH setup:

### Using ssh-agent

```bash
# Add your SSH keys
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_ed25519

# Verify loaded keys
ssh-add -l
```

### Using SSH Config

Create/edit `~/.ssh/config`:

```ssh-config
Host prod.example.com
    User deploy
    Port 22
    IdentityFile ~/.ssh/production_key
    StrictHostKeyChecking no

Host *.staging.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/staging_key
```

### Jump Hosts / Bastion Servers

```ssh-config
Host bastion
    HostName bastion.company.com
    User jump
    IdentityFile ~/.ssh/jump_key

Host internal-server
    HostName 10.0.1.100
    User admin
    ProxyJump bastion
```

---

## 🛠️ Troubleshooting

### Common Issues

<details>
<summary><strong>"sx: command not found"</strong></summary>

```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep -q ~/.local/bin || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
</details>

<details>
<summary><strong>"fzf: command not found"</strong></summary>

```bash
# Install fzf
sudo apt install fzf              # Ubuntu/Debian
brew install fzf                  # macOS
sudo pacman -S fzf               # Arch Linux
sudo dnf install fzf             # Fedora/RHEL
```
</details>

<details>
<summary><strong>"Hotkey doesn't work"</strong></summary>

```bash
# Use the interactive key binding fixer
./fix-keybind.sh

# Or manually check current binding
sx_status

# Reload integration
source ~/.bashrc
```
</details>

<details>
<summary><strong>"No servers found"</strong></summary>

```bash
# Check if servers file exists and has content
ls -la ~/.config/sx/servers
cat ~/.config/sx/servers

# Re-import from FileZilla if needed
sx --import /path/to/filezilla-export.xml
```
</details>

<details>
<summary><strong>"Connection refused / timeout"</strong></summary>

```bash
# Test SSH connection manually
ssh -p 22 user@hostname

# Check if server is reachable
ping hostname

# Verify SSH service is running on target
nmap -p 22 hostname
```
</details>

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Debug sx command
bash -x ~/.local/bin/sx --list

# Debug shell integration
bash -x ~/.config/sx/sx-integration.sh
```

### Getting Help

```bash
# Built-in help
sx --help

# Check integration status
sx_status

# List current servers
sx --list
```

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Setup

```bash
git clone git@github.com:mart337i/sx.git
cd sx

# Test your changes
./sx --help
./sx --list

# Run tests
./test.sh
```

### Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature-name`
3. **Make** your changes with tests
4. **Test** thoroughly across different environments
5. **Submit** a pull request with clear description

### Code Style

- Follow existing bash scripting conventions
- Add comments for complex logic
- Test on multiple Linux distributions
- Ensure compatibility with different shell configurations

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### MIT License Summary

- ✅ **Commercial use** - Use in commercial projects
- ✅ **Modification** - Modify the source code
- ✅ **Distribution** - Distribute the software
- ✅ **Private use** - Use privately
- ❌ **Liability** - No warranty provided
- ❌ **Warranty** - No warranty provided

---

## 🙏 Acknowledgments

- **[fzf](https://github.com/junegunn/fzf)** - The incredible fuzzy finder that powers sx
- **[FileZilla](https://filezilla-project.org/)** - For the excellent XML export format
- **The SSH community** - For building robust, secure remote access tools

---

## 🔗 Related Projects

- **[fzf](https://github.com/junegunn/fzf)** - Command-line fuzzy finder
- **[tmux](https://github.com/tmux/tmux)** - Terminal multiplexer 
- **[ssh-config](https://man.openbsd.org/ssh_config)** - SSH client configuration

---

<div align="center">

**Made with ❤️ for system administrators and developers**

[Report Bug](https://github.com/mart337i/sx/issues) • [Request Feature](https://github.com/mart337i/sx/issues) • [Documentation](https://github.com/mart337i/sx)

</div>