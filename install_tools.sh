#!/bin/bash

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo -e "No supported package manager found (apt, dnf, yum). Please install tools manually."
    exit 1
fi

# Install Golang if missing
if ! command -v go &> /dev/null; then
    echo -e "Installing Golang..."
    if [ "$PKG_MANAGER" == "apt" ]; then
        sudo apt install golang -y
    elif [ "$PKG_MANAGER" == "dnf" ]; then
        sudo dnf install golang -y
    elif [ "$PKG_MANAGER" == "yum" ]; then
        sudo yum install golang -y
    fi
    echo -e "Golang installed."
fi

# Install tools
TOOLS=("amass" "sublist3r" "subfinder" "httpx" "nuclei" "ffuf")

for tool in "${TOOLS[@]}"; do
    case $tool in
        amass)
            echo -e "Installing amass..."
            sudo $PKG_MANAGER install amass -y || echo -e "Failed to install amass."
            ;;
        sublist3r)
            echo -e "Installing sublist3r..."
            sudo $PKG_MANAGER install python3-pip -y && pip3 install sublist3r || echo -e "Failed to install sublist3r."
            ;;
        subfinder)
            echo -e "Installing subfinder..."
            GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest || echo -e "Failed to install subfinder."
            ;;
        httpx)
            echo -e "Installing httpx..."
            GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest || echo -e "Failed to install httpx."
            ;;
        nuclei)
            echo -e "Installing nuclei..."
            GO111MODULE=on go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest || echo -e "Failed to install nuclei."
            ;;
        ffuf)
            echo -e "Installing ffuf..."
            GO111MODULE=on go install -v github.com/ffuf/ffuf@latest || echo -e "Failed to install ffuf."
            ;;
        *)
            echo -e "Unknown tool: $tool. Please install manually."
            ;;
    esac
done

echo -e "Tool installation complete."
