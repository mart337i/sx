Name:           sx
Version:        1.0.1
Release:        1%{?dist}
Summary:        Simple SSH connection manager with fuzzy search

License:        MIT
URL:            https://github.com/mart337i/sx
Source0:        https://github.com/mart337i/sx/archive/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       bash
Requires:       fzf
Requires:       openssh-clients

%description
sx is an interactive SSH connection selector that allows you to
manage and connect to servers using fuzzy search with fzf.

Features:
- Interactive server selection with fuzzy search
- Import servers from FileZilla XML exports (with folder support)
- Import servers from SSH config files
- Add/remove servers via command line
- Global hotkey (Ctrl+K) for quick access
- Case-insensitive search
- Server filtering by name, host, or username

All server configurations are stored in ~/.config/sx/servers

%prep
%setup -q

%build
# No build step required for bash script

%install
# Install main script
install -Dm755 sx %{buildroot}%{_bindir}/sx

# Install integration script
install -Dm644 sx-integration.sh %{buildroot}%{_datadir}/sx/sx-integration.sh

# Install documentation
install -Dm644 README.md %{buildroot}%{_docdir}/%{name}/README.md

%files
%license LICENSE
%doc README.md
%{_bindir}/sx
%{_datadir}/sx/sx-integration.sh
%{_docdir}/%{name}/README.md

%post
echo ""
echo "sx has been installed successfully!"
echo ""
echo "To enable the global hotkey (Ctrl+K), add this to your ~/.bashrc:"
echo "  source %{_datadir}/sx/sx-integration.sh"
echo ""
echo "Get started with:"
echo "  sx --help"
echo ""

%changelog
* Mon Oct 27 2025 Martin Egeskov <martin@egeskov.dk> - 1.0.1-1
- Initial RPM release
- Interactive SSH connection selector with fuzzy search
- Import servers from FileZilla XML exports
- Import servers from FileZilla XML with folder sections
- Import servers from SSH config files
- Add/remove servers via command line
- Global hotkey support (Ctrl+K)
- Case-insensitive server search
- Comprehensive test suite with 27 tests
- GitHub Actions CI/CD integration
