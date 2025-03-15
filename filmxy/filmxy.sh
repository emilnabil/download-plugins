#!/bin/sh

plugin="filmxy"
git_url="https://gitlab.com/eliesat/extensions/-/raw/main/filmxy"
version=""
plugin_path="/usr/lib/enigma2/python/Plugins/Extensions/$plugin"
package="enigma2-plugin-extensions-$plugin"
targz_file="$plugin.tar.gz"
url="$git_url/$targz_file"
temp_dir="/tmp"

if command -v dpkg &> /dev/null; then
    package_manager="apt"
    status_file="/var/lib/dpkg/status"
    uninstall_command="apt-get purge --auto-remove -y"
else
    package_manager="opkg"
    status_file="/var/lib/opkg/status"
    uninstall_command="opkg remove --force-depends"
fi

check_and_remove_package() {
    if [ -d "$plugin_path" ]; then
        echo "> Removing old version of $plugin, please wait..."
        sleep 3
        rm -rf "$plugin_path" > /dev/null 2>&1

        if grep -q "$package" "$status_file"; then
            echo "> Removing existing $package package, please wait..."
            $uninstall_command "$package" > /dev/null 2>&1
        fi

        echo "*******************************************"
        echo "*             Removal Finished            *"
        echo "*******************************************"
        sleep 1
        echo ""
    fi
}
check_and_remove_package

download_and_install_package() {
    echo "> Downloading $plugin-$version package, please wait..."
    sleep 1
    wget --show-progress -qO "$temp_dir/$targz_file" --no-check-certificate "$url"
    
    if [ $? -eq 0 ]; then
        tar -xzf "$temp_dir/$targz_file" -C / > /dev/null 2>&1
        extract=$?
        rm -rf "$temp_dir/$targz_file" > /dev/null 2>&1

        if [ $extract -eq 0 ]; then
            echo "> $plugin-$version package installed successfully"
        else
            echo "> Extraction failed"
        fi
    else
        echo "> Download failed"
    fi
    sleep 2
    echo ""
}
download_and_install_package

print_message() {
    echo "> [$(date +'%Y-%m-%d')] $1"
}
exit
