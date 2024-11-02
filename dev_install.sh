#!/bin/bash

# Define color variables for output
GR_FG="\033[32m"
RD_FG="\033[31m"
RESET="\033[0m"

# Acquire sudo access
if ! sudo -v; then
  echo "Failed to acquire sudo privileges. Exiting."; exit 1;
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
  local package_name="${package_deb%%_*}"

  if check_installed "$package_name"; then
    echo -e "${GR_FG}${package_name} already installed.${RESET}"
  else
    echo -e "Installing $package_deb..."
    curl -O "${package_url}/${package_deb}" || { echo -e "${RD_FG}Failed to download $package_deb${RESET}"; exit 1; }
    sudo dpkg -i "$package_deb"

    if [ $? -eq 0 ]; then
      echo -e "${GR_FG}$package_name installed successfully.${RESET}"
    else
      echo -e "${RD_FG}Installation of $package_name failed.${RESET}"
    fi

    rm -f "$package_deb"
  fi
}

# Loop through the CSV file and read URL and deb pairs
while IFS=',' read -r url deb; do
  # Skip empty lines
  if [ -n "$url" ] && [ -n "$deb" ]; then
    install_package "$url" "$deb"
  fi
done < <(grep -v '^\s*$' "packages.csv")