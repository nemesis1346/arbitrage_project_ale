#!/bin/bash

# Update package lists and install prerequisites
echo "Updating package lists..."
apt-get update -y

# Initialize a new Hardhat project if none exists
if [ ! -f "hardhat.config.js" ]; then
    echo "Initializing a new Hardhat project..."
    npx hardhat init --force
fi

# Install Hardhat and related dependencies locally
echo "Installing Hardhat and related dependencies..."
npm install 

# Success message
echo "All dependencies installed successfully. You can now run tests using 'npx hardhat test'."
