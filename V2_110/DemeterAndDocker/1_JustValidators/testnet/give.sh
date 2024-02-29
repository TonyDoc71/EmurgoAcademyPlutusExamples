utxoin="eeafd5c0f3d2c9c010a150a297a099ff973e73eca11a85bbcc9d083821758853#0"
address=$(cat datum22.addr) 
output="54000000"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file unit.json \
  --change-address "addr_test1qrpzz8whcft2g6z24ft4072s76x8gmj5wn32dxvtr4zcpuqltc67z9ljrqml3hc5mutuher549lwgv2g6n4z0a3ztyesj7sd80" \
  --protocol-params-file protocol.params \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../WalletMine/4payment2.skey \
    $PREVIEW \
    --out-file give.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed