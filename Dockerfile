# Use Node.js as base image
FROM node:22

# Create working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json for dependencies installation
COPY package*.json ./

# Install Node.js dependencies
# RUN npm install -g yarn
RUN yarn install

# Install Hardhat
RUN yarn add hardhat

# Copy the rest of the project files
COPY . .

# Expose ports as needed, e.g., port 8545 for local blockchain
EXPOSE 8545

# Default command
CMD ["yarn", "hardhat", "node"]