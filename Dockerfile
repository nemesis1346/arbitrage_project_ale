# Use Node.js as base image
FROM node:22

# Create working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json for dependencies installation
COPY package*.json ./
RUN npm install

# Install Hardhat globally and any other necessary dependencies
RUN npm install -g hardhat

# Copy the rest of your app
COPY . .

# Expose ports as needed, e.g., port 8545 for local blockchain
EXPOSE 8545

# Default command
CMD ["yarn", "hardhat", "node"]