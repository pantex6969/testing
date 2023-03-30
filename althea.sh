#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ¦¦   ¦¦ ¦¦¦¦¦¦¦ ¦¦   ¦¦ ¦¦¦    ¦¦  ¦¦¦¦¦¦  ¦¦¦¦¦¦  ¦¦¦¦¦¦¦ ¦¦¦¦¦¦¦";
echo "    ¦¦   ¦¦ ¦¦       ¦¦ ¦¦  ¦¦¦¦   ¦¦ ¦¦    ¦¦ ¦¦   ¦¦ ¦¦      ¦¦     "; 
echo "    ¦¦¦¦¦¦¦ ¦¦¦¦¦     ¦¦¦   ¦¦ ¦¦  ¦¦ ¦¦    ¦¦ ¦¦   ¦¦ ¦¦¦¦¦   ¦¦¦¦¦¦¦"; 
echo "    ¦¦   ¦¦ ¦¦       ¦¦ ¦¦  ¦¦  ¦¦ ¦¦ ¦¦    ¦¦ ¦¦   ¦¦ ¦¦           ¦¦"; 
echo "    ¦¦   ¦¦ ¦¦¦¦¦¦¦ ¦¦   ¦¦ ¦¦   ¦¦¦¦  ¦¦¦¦¦¦  ¦¦¦¦¦¦  ¦¦¦¦¦¦¦ ¦¦¦¦¦¦¦";
echo "        Automatic Installer for Althea  | Chain ID : althea_7357-1 ";
echo -e "\e[0m"
sleep 1

# Variable
ALT_WALLET=wallet
ALT=althea
ALT_ID=althea_7357-1
ALT_FOLDER=.althea
ALT_REPO=https://github.com/althea-net/althea-chain.git
ALT_VERSION=v0.3.2
ALT_GENESIS=https://snapshots.kjnodes.com/althea-testnet/genesis.json
ALT_ADDRBOOK=https://snapshots.kjnodes.com/althea-testnet/addrbook.json
ALT_DENOM=ualthea
ALT_PORT=14

echo "export ALT_WALLET=${ALT_WALLET}" >> $HOME/.bash_profile
echo "export ALT=${ALT}" >> $HOME/.bash_profile
echo "export ALT_ID=${ALT_ID}" >> $HOME/.bash_profile
echo "export ALT_FOLDER=${ALT_FOLDER}" >> $HOME/.bash_profile
echo "export ALT_VER=${ALT_VER}" >> $HOME/.bash_profile
echo "export ALT_REPO=${ALT_REPO}" >> $HOME/.bash_profile
echo "export ALT_DENOM=${ALT_DENOM}" >> $HOME/.bash_profile
echo "export ALT_PORT=${ALT_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $ALT_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " ALT_NODENAME
        echo 'export ALT_NODENAME='$ALT_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$ALT_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$ALT_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$ALT_PORT\e[0m"
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

# Get version of ALT Blockchain
cd $HOME
rm -rf althea-chain
cd $HOME
git clone $ALT_REPO
cd althea-chain
make install

$ALT config chain-id $ALT_ID
$ALT config keyring-backend test
$ALT config node tcp://localhost:${ALT_PORT}657
$ALT init $ALT_NODENAME --chain-id $ALT_ID

# Set peers and seeds
SEEDS=""
PEERS="d5519e378247dfb61dfe90652d1fe3e2b3005a5b@althea-testnet.rpc.kjnodes.com:52656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$ALT_FOLDER/config/config.toml

# Download genesis
curl -Ls $ALT_GENESIS > $HOME/$ALT_FOLDER/config/genesis.json
curl -Ls $ALT_ADDRBOOK > $HOME/$ALT_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ALT_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ALT_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ALT_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ALT_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ALT_PORT}660\"%" $HOME/$ALT_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ALT_PORT}317\"%; s%^address = \":8080\"%address = \":${ALT_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ALT_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ALT_PORT}091\"%" $HOME/$ALT_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$ALT_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$ALT_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$ALT_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$ALT_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$ALT_DENOM\"/" $HOME/$ALT_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$ALT_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$ALT_FOLDER/config/app.toml

# Enable Snapshot
$ALT tendermint unsafe-reset-all --home $HOME/$ALT_FOLDER --keep-addr-book
STATE_SYNC_RPC=https://althea-testnet.rpc.kjnodes.com:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
  $HOME/.althea/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$ALT.service > /dev/null <<EOF
[Unit]
Description=$ALT
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $ALT) start --home $HOME/$ALT_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ALT
sudo systemctl start $ALT

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $ALT -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${ALT_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
