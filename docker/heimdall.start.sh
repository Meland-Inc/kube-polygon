#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -e

init() {
    if [ -f $HOME/heimdall_data/initialized ]; then
        return 0;
    fi
    mkdir -p $HOME/heimdall_data
    heimdalld init --home $HOME/heimdall_data
    wget https://raw.githubusercontent.com/maticnetwork/launch/master/mainnet-v1/sentry/sentry/heimdall/config/genesis.json
    cp -rf genesis.json $HOME/heimdall_data/config/genesis.json
    # edit $HOME/heimdall_data/config/config.toml
    sed -i '/moniker/c\moniker = "MelandPolygonNode"' $HOME/heimdall_data/config/config.toml
    sed -i '/seeds/c\seeds = "f4f605d60b8ffaaf15240564e58a81103510631c@159.203.9.164:26656,4fb1bc820088764a564d4f66bba1963d47d82329@44.232.55.71:26656"' $HOME/heimdall_data/config/config.toml
    wget -c https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/heimdall-snapshot-2022-01-17.tar.gz -O - | tar -xz -C $HOME/heimdall_data/data
    touch $HOME/heimdall_data/initialized
}

init

systemctl start heimdalld

heimdalld rest-server --home $HOME/heimdall_data --chain-id=137