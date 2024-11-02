#!/bin/bash

# Define color variables for output
GR_FG="\033[32m"
RD_FG="\033[31m"
RESET="\033[0m"

# Define URLs for the .deb files
GIT_URL="http://security.debian.org/debian-security/pool/updates/main/g/git"
GIT_DEB="git_2.39.5-0+deb12u1_i386.deb"
GIT_MAN_DEB="git-man_2.39.5-0+deb12u1_all.deb"

LIBERROR_PERL_URL="http://ftp.us.debian.org/debian/pool/main/libe/liberror-perl"
LIBERROR_PERL_DEB="liberror-perl_0.17029-2_all.deb"

LINUX_URL="http://ftp.us.debian.org/debian/pool/main/l/linux86"
BIN86_DEB="bin86_0.16.17-3.4_i386.deb"
BCC_DEB="bcc_0.16.17-3.4_i386.deb"

VDEV_URL="http://ftp.us.debian.org/debian/pool/main/v/vdeplug4"
VDEV_DEB="libvdeplug2_4.0.1-4_i386.deb"
LIBSLIRP_URL="http://ftp.us.debian.org/debian/pool/main/libs/libslirp/"
LIBSLIRP_DEB="libslirp0_4.7.0-1_i386.deb"
RDMA_URL="http://ftp.us.debian.org/debian/pool/main/r/rdma-core/"
RDMA_VERBS_DEB="libibverbs1_44.0-2_i386.deb"
RDMA_CM_DEB="librdmacm1_44.0-2_i386.deb"
FTD_URL="http://ftp.us.debian.org/debian/pool/main/d/device-tree-compiler"
FTD_DEB="libfdt1_1.6.1-4+b1_i386.deb"
CAPSTONE_URL="http://ftp.us.debian.org/debian/pool/main/c/capstone"
CAPSTONE_DEB="libcapstone4_4.0.2-5_i386.deb"
LIBA_URL="http://ftp.us.debian.org/debian/pool/main/liba/libaio"
LIBA_DEB="libaio1_0.3.113-4_i386.deb"
IPXE_URL="http://ftp.us.debian.org/debian/pool/main/i/ipxe"
IPXE_DEB="ipxe-qemu_1.0.0+git-20190125.36a4c85-5.1_all.deb"
SEABIOS_URL="http://ftp.us.debian.org/debian/pool/main/s/seabios/"
SEABIOS_DEB="seabios_1.16.2-1_all.deb"
QEMU_URL="http://ftp.us.debian.org/debian/pool/main/q/qemu"
QEMU_SYSTEM_DATA_DEB="qemu-system-data_7.2+dfsg-7+deb12u7_all.deb"
QEMU_SYSTEM_COMMON_DEB="qemu-system-common_7.2+dfsg-7+deb12u7_i386.deb"
QEMU_DEB="qemu-system-x86_7.2+dfsg-7+deb12u7_i386.deb"

# Acquire sudo access
if ! sudo -v; then
  echo "Failed to acquire sudo priviledges. Exiting."; exit 1;
fi

( while true; do sudo -v; sleep 60; done ) &
trap 'kill $(jobs -p)' EXIT # kill background process on exit

# Function to check if a package is installed
check_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# Download and install a package if not already installed
install_package() {
  local package_url="$1"
  local package_deb="$2"
  local package_name="${2%%_*}"

  if check_installed "$package_name"; then
    echo -e "${GR_FG}${package_name} already installed.${RESET}"
  else
    echo -e "Installing $package_deb..."
    curl -O "${package_url}/${package_deb}" || { echo -e "$RD_FG}Failed to download $package_deb${RESET}"; exit 1; }
    sudo dpkg -i "$package_deb"

    if [ $? -eq 0 ]; then
      echo -e "${GR_FG}$package_name installed successfully.${RESET}"
    else
      echo -e "${RD_FG}Installation of $package_name failed.${RESET}"
    fi

    rm -f "$package_deb"
  fi
        
}

install_package "$LINUX_URL" "$BIN86_DEB"
install_package "$LINUX_URL" "$BCC_DEB"

install_package "$LIBERROR_PERL_URL" "$LIBERROR_PERL_DEB"
install_package "$GIT_URL" "$GIT_MAN_DEB"
install_package "$GIT_URL" "$GIT_DEB"


install_package "$LIBSLIRP_URL" "$LIBSLIRP_DEB"
install_package "$RDMA_URL" "$RDMA_VERBS_DEB"
install_package "$RDMA_URL" "$RDMA_CM_DEB"
install_package "$FTD_URL" "$FTD_DEB"
install_package "$CAPSTONE_URL" "$CAPSTONE_DEB"
install_package "$LIBA_URL" "$LIBA_DEB"
install_package "$IPXE_URL" "$IPXE_DEB"
install_package "$VDEV_URL" "$VDEV_DEB"
install_package "$SEABIOS_URL" "$SEABIOS_DEB"
install_package "$QEMU_URL" "$QEMU_SYSTEM_COMMON_DEB"
install_package "$QEMU_URL" "$QEMU_SYSTEM_DATA_DEB"
install_package "$QEMU_URL" "$QEMU_DEB"

