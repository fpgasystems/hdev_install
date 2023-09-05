#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
SGRT_INSTALL_PATH="/opt/sgrt"

#check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo. Please use 'sudo $0' to execute it."
    exit 1
fi

#prompt the user for the installation path
read -p "Please enter the installation path (default: $SGRT_INSTALL_PATH): " sgrt_install_path

#use default path if the user didn't provide one
if [ -z "$sgrt_install_path" ]; then
    sgrt_install_path=$SGRT_INSTALL_PATH
fi

echo $SGRT_INSTALL_PATH
echo $sgrt_install_path