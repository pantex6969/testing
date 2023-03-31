#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "        Automatic Installer for ixoworld  | Chain ID : ixo-5 ";
echo -e "\e[0m"
sleep 1

# Variable
IXO_WALLET=wallet
IXO=ixod
IXO_ID=ixo-5
IXO_FOLDER=.ixod
IXO_REPO=https://github.com/ixofoundation/ixo-blockchain.git
IXO_VERSION=v0.20.0
IXO_GENESIS=https://snapshots.ezstaking.xyz/genesis/ixo/genesis.json
IXO_ADDRBOOK=https://snapshots.ezstaking.xyz/addrbook/ixo/addrbook.json
IXO_DENOM=uixo
IXO_PORT=10

echo "export IXO_WALLET=${IXO_WALLET}" >> $HOME/.bash_profile
echo "export IXO=${IXO}" >> $HOME/.bash_profile
echo "export IXO_ID=${IXO_ID}" >> $HOME/.bash_profile
echo "export IXO_FOLDER=${IXO_FOLDER}" >> $HOME/.bash_profile
echo "export IXO_VER=${IXO_VER}" >> $HOME/.bash_profile
echo "export IXO_REPO=${IXO_REPO}" >> $HOME/.bash_profile
echo "export IXO_DENOM=${IXO_DENOM}" >> $HOME/.bash_profile
echo "export IXO_PORT=${IXO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $IXO_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " IXO_NODENAME
        echo 'export IXO_NODENAME='$IXO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$IXO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$IXO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$IXO_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.6"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get version of IXO World
cd $HOME
rm -rf ixo-blockchain
cd $HOME
git clone $IXO_REPO
cd ixo-blockchain
git checkout $IXO_VERSION
make install

# Init
$IXO config chain-id $IXO_ID
$IXO config keyring-backend file
$IXO config node tcp://localhost:${IXO_PORT}657
$IXO init $IXO_NODENAME --chain-id $IXO_ID

# Set peers and seeds
SEEDS=""
PEERS="1919e0d12d907529fba03c615b02acb648b0c3d4@144.76.97.251:30656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$IXO_FOLDER/config/config.toml

# Download genesis
curl -Ls $IXO_GENESIS > $HOME/$IXO_FOLDER/config/genesis.json
curl -Ls $IXO_ADDRBOOK > $HOME/$IXO_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${IXO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${IXO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${IXO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${IXO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${IXO_PORT}660\"%" $HOME/$IXO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${IXO_PORT}317\"%; s%^address = \":8080\"%address = \":${IXO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${IXO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${IXO_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${IXO_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${IXO_PORT}546\"%" $HOME/$IXO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$IXO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$IXO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$IXO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$IXO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$IXO_DENOM\"/" $HOME/$IXO_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$IXO_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$IXO_FOLDER/config/app.toml

# Enable Snapshot
$IXO tendermint unsafe-reset-all --home $HOME/$IXO_FOLDER --keep-addr-book
curl -L https://snap.hexnodes.co/ixo/ixo.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.ixod

# Create Service
sudo tee /etc/systemd/system/$IXO.service > /dev/null <<EOF
[Unit]
Description=$IXO
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $IXO) start --home $HOME/$IXO_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $IXO
sudo systemctl start $IXO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $IXO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${IXO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
