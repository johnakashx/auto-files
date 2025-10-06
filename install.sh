#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed or not found in PATH"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Attempting to install Docker..."
    
    # Detect OS and install Docker accordingly
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                sudo apt-get update
                sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$ID $VERSION_CODENAME stable"
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io
                ;;
            centos|rhel)
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io
                sudo systemctl start docker
                sudo systemctl enable docker
                ;;
            *)
                echo "Unsupported operating system: $ID"
                echo "Please install Docker manually and rerun the script"
                exit 1
                ;;
        esac
    else
        echo "Cannot determine operating system. Please install Docker manually and rerun the script"
        exit 1
    fi

    # Verify Docker installation
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker installation failed"
        exit 1
    else
        echo "Docker installed successfully"
    fi
else
    echo "Docker is already installed"
fi

# Prompt for GitHub personal access token (hidden input)
read -s -p "Enter your GitHub personal access token: " token
echo ""

# Modify the URL to include the token
auth_url="https://$token@github.com/johnakashx/spark-hive-template-accesskey.git"

# Clone the repository to current directory
if git clone "$auth_url"; then
    echo "Repository successfully cloned to current directory"
else
    echo "Error cloning repository"
    exit 1
fi

# Change permissions of startup.sh and execute it
startup_script="spark-hive-template-accesskey/startup.sh"
if [ -f "$startup_script" ]; then
    chmod +x "$startup_script"
    sh "$startup_script"
else
    echo "Error: startup.sh not found in spark-hive-template-accesskey"
    exit 1
fi