#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -e

BOR_DIR=${BOR_DIR:-~/bor_data} # data folder of bor
DATA_DIR=$BOR_DIR/data
HEIMDALL_ADDRESS=${HEIMDALL_ADDRESS:-"polygon-heimdall"}

init() {
    if [ -f $HOME/bor_data/initialized ]; then
        return 0
    fi
    mkdir -p $HOME/bor_data
    mkdir -p $HOME/bor_data/data
    wget https://raw.githubusercontent.com/maticnetwork/launch/master/mainnet-v1/sentry/sentry/bor/genesis.json
    cp -rf genesis.json $HOME/bor_data/gensis.json
    bor --datadir $HOME/bor_data/data init genesis.json
    wget -c https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/bor-fullnode-snapshot-2022-01-02.tar.gz -O - | tar -xz -C $HOME/bor_data/data
    touch $HOME/bor_data/initialized
}

start() {
    bor --datadir $DATA_DIR \
        --port 30303 \
        --http --http.addr '0.0.0.0' \
        --http.vhosts '*' \
        --http.corsdomain '*' \
        --http.port 8545 \
        --ws --ws.addr '0.0.0.0' \
        --ws.port 8546 \
        --ipcpath $DATA_DIR/bor.ipc \
        --http.api 'debug,eth,net,web3,txpool,bor' \
        --syncmode 'full' \
        --bor.heimdall="http://${HEIMDALL_ADDRESS}:1317" \
        --gcmode 'full' \
        --networkid '137' \
        --miner.gaslimit '200000000' \
        --miner.gastarget '20000000' \
        --txpool.nolocals \
        --txpool.accountslots '128' \
        --txpool.globalslots '20000' \
        --txpool.lifetime '0h16m0s' \
        --maxpeers 200 \
        --metrics \
        --bootnodes "enode://0cb82b395094ee4a2915e9714894627de9ed8498fb881cec6db7c65e8b9a5bd7f2f25cc84e71e89d0947e51c76e85d0847de848c7782b13c0255247a6758178c@44.232.55.71:30303,enode://88116f4295f5a31538ae409e4d44ad40d22e44ee9342869e7d68bdec55b0f83c1530355ce8b41fbec0928a7d75a5745d528450d30aec92066ab6ba1ee351d710@159.203.9.164:30303"
}

default() {
    echo "{}"
}

wait() {
    while true; do
        sleep 1
        catching_up=$((curl http://$HEIMDALL_ADDRESS:26657/status || default) | jq -r '.sync_info.catching_up')
        echo "wait for catching_up: $catching_up";
        if [ "$catching_up" == "false" ]; then
            break
        fi
    done
}

init

wait

start
