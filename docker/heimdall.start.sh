#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -e

init() {
    if [ ! -f "$HOME/heimdall_data/initialized" ]; then
        mkdir -p $HOME/heimdall_data
        heimdalld init --home $HOME/heimdall_data
        wget https://raw.githubusercontent.com/maticnetwork/launch/master/mainnet-v1/sentry/sentry/heimdall/config/genesis.json
        cp -rf genesis.json $HOME/heimdall_data/config/genesis.json
        # edit $HOME/heimdall_data/config/config.toml
        sed -i '/moniker/c\moniker = "MelandPolygonNode"' $HOME/heimdall_data/config/config.toml
        sed -i '/seeds/c\seeds = "f4f605d60b8ffaaf15240564e58a81103510631c@159.203.9.164:26656,4fb1bc820088764a564d4f66bba1963d47d82329@44.232.55.71:26656,2eadba4be3ce47ac8db0a3538cb923b57b41c927@35.199.4.13:26656,3b23b20017a6f348d329c102ddc0088f0a10a444@35.221.13.28:26656,25f5f65a09c56e9f1d2d90618aa70cd358aa68da@35.230.116.151:26656"' $HOME/heimdall_data/config/config.toml
        sed -i 's/127.0.0.1/0.0.0.0/g' $HOME/heimdall_data/config/config.toml
        # wget -c https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/heimdall-snapshot-2022-01-17.tar.gz -O - | tar -xz -C $HOME/heimdall_data/data
        touch $HOME/heimdall_data/initialized
    fi
}

init

echo "start heimdall";

nohup heimdalld start --home=/root/heimdall_data &

echo "start rest-server";

heimdalld rest-server --home $HOME/heimdall_data --chain-id=137
