Name:       harbour-sail-cycle
Summary:    A private menstrual cycle tracker for Sailfish OS
Version:    0.1
Release:    1
Group:      Applications
License:    BSD-3-Clause
URL:        https://example.invalid/harbour-sail-cycle
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-sail-cycle.yaml

Requires:   sailfishsilica-qt5
BuildRequires: pkgconfig(sailfishapp) >= 1.0.2
BuildRequires: pkgconfig(Qt5Core)
BuildRequires: pkgconfig(Qt5Qml)
BuildRequires: pkgconfig(Qt5Quick)
BuildRequires: desktop-file-utils

%description
Sail Cycle is a private and easy-to-use cycle tracker for Sailfish OS.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5
make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original \
    --dir %{buildroot}%{_datadir}/applications \
    %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/harbour-sail-cycle
%{_datadir}/harbour-sail-cycle
%{_datadir}/applications/harbour-sail-cycle.desktop
%{_datadir}/icons/hicolor/*/apps/harbour-sail-cycle.png
