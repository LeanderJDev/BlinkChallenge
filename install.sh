#!/bin/bash
# Installs all necessary dependencies for the project. Uses apt for system packages

set -euo pipefail
# Update package lists
sudo apt update
# Install system dependencies
sudo apt install -y build-essential avrdude gcc-avr binutils-avr avr-libc avrdude avrdude-doc python3 python3-pip
