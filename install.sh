#! /bin/bash

if ! command -v clangd &> /dev/null; then
    echo "clangd not found, install clangd..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y clangd
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew not found, install brew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install llvm
    else
        echo "Cannot install clangd automatically, please install manually!"
    fi
else
    echo "Already installed clangd!"
fi

install_node() {
    echo "Install Node or update..."
     curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt update
    sudo apt install -y nodejs
}

if ! command -v node &> /dev/null; then
    echo "Node.js not found!Install..."
    install_node
elif [[ "$(node -v)" < "v18" ]]; then
    echo "Node.js version less then 18，update..."
    install_node
else
    echo "Node.js already installed!"
fi

if ! command -v pyright &> /dev/null; then
    echo "pyright not found, install..."
    npm install -g pyright
else
    echo "Already installed pyright!"
fi

echo "==============================================="
echo "OK"
echo "==============================================="
