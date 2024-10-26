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

if ! command -v pyright &> /dev/null; then
    echo "pyright not found,instal pyright..."
    if ! command -v npm &> /dev/null; then
        echo "npm not found,instal npm..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt update
            sudo apt install -y npm
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install npm
        else
            echo "Cannot install npm automatically, please install manually!"
        fi
    fi
sudo npm install -g pyright
sudo npm install n -g
sudo n stable
else
    echo "Already installed pyright!"
fi

echo "==============================================="
echo "OK"
echo "==============================================="
