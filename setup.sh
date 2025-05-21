#!/bin/bash
set -e

echo "
                    
              __________  ____ ________  ___
             / ____/ __ \/  _//_  __/  |/  /
            / /   / /_/ // /   / / / /|_/ /
           / /___/ ____// / _ / / / /  / /
           \____/_/   /___/(_)_/ /_/  /_/
                    
                    
"
echo  "___________________________________________________"

# Оновлення системи
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Створення директорій
mkdir -p ~/sepolia-node/{geth,lighthouse,data,logs}
cd ~/sepolia-node

# Встановлення залежностей
sudo apt install -y build-essential git wget software-properties-common cmake clang curl openssl

# Встановлення Go
if ! command -v go &> /dev/null; then
  wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile && source ~/.profile
  rm go1.21.3.linux-amd64.tar.gz
fi

# Встановлення Rust
if ! command -v rustc &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env
fi

# Встановлення Geth
if ! command -v geth &> /dev/null; then
  sudo add-apt-repository -y ppa:ethereum/ethereum
  sudo apt update && sudo apt install -y ethereum
fi

# Встановлення Lighthouse
if ! command -v lighthouse &> /dev/null; then
  git clone https://github.com/sigp/lighthouse.git && cd lighthouse && git checkout stable && make && cd ..
fi

# JWT секрет
openssl rand -hex 32 > ~/sepolia-node/data/jwtsecret

# Копіювання сервісів
sudo cp ./services/geth-sepolia.service /etc/systemd/system/
sudo cp ./services/lighthouse-sepolia.service /etc/systemd/system/
sudo systemctl daemon-reload

# Копіювання скриптів
cp ./scripts/*.sh ~/sepolia-node/
chmod +x ~/sepolia-node/*.sh

echo "Встановлення завершено. Запустіть: ~/sepolia-node/start.sh"
