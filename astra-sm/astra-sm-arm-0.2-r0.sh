#!/bin/sh

# Config
plugin="astra-sm"
version="0.2-r0"
ipk="astra-sm.ipk"
package="/var/volatile/tmp/${plugin}-${version}.tar.gz"
url="https://gitlab.com/eliesat/softcams/-/raw/main/astra-sm/${plugin}-${version}.tar.gz"
url_ipk="https://gitlab.com/eliesat/softcams/-/raw/main/astra-sm/${ipk}"
status="/var/lib/opkg/status"
install="opkg install --force-reinstall"

# Cleanup unnecessary files
rm -rf /CONTROL /control /postinst /preinst /prerm /postrm >/dev/null 2>&1
rm -rf /tmp/*.ipk /tmp/*.tar.gz >/dev/null 2>&1

# Download and install
echo "> Downloading and installing $plugin-$version, please wait..."
sleep 2

# Try to install from repository first
opkg install $plugin >/dev/null 2>&1

if grep -q "$plugin" "$status"; then
    echo "> $plugin installed successfully from repo"
else
    echo "> Installing $plugin from .ipk file"
    cd /tmp || exit 1
    wget -q --no-check-certificate "$url_ipk"
    $install "$ipk"
    rm -f "/tmp/$ipk"
fi

# Download and extract .tar.gz package
wget -qO "$package" --no-check-certificate "$url"
if [ -f "$package" ]; then
    tar -xzf "$package" -C /
    extract=$?
    rm -f "$package"
else
    extract=1
fi

# Download architecture-specific binary
arch=$(uname -m)
case "$arch" in
    aarch64)
        wget -qO /etc/astra/scripts/abertis https://gitlab.com/eliesat/softcams/-/raw/main/astra-sm/aarch/abertis
        ;;
    mips)
        wget -qO /etc/astra/scripts/abertis https://gitlab.com/eliesat/softcams/-/raw/main/astra-sm/mips/abertis
        ;;
    sh4)
        wget -qO /etc/astra/scripts/abertis https://gitlab.com/eliesat/softcams/-/raw/main/astra-sm/sh4/abertis
        ;;
    *)
        echo "> Unknown architecture: $arch"
        ;;
esac

# Final status
echo ""
if [ "$extract" -eq 0 ]; then
    echo "> $plugin-$version installed successfully"
    echo "> Uploaded by ElieSat"
    sleep 3
    echo "> Your device may reboot now. Please wait..."
    sleep 3
else
    echo "> Installation of $plugin-$version failed"
    sleep 3
fi
exit

