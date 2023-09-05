#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo. Please use 'sudo $0' to execute it."
    exit 1
fi

echo "hola!"