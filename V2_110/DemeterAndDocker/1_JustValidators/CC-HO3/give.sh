utxoin1="f02d07f68407583f7b36792ec231de4b3b37b7063c7029d76109b392f0429c55#1"
address=$(cat conditionator.addr) 
output="111000000"
PREVIEW="--testnet-magic 2"
nami=$(cat ../../WalletMine/Nami.addr)

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-out $address+$output \
  --tx-out-datum-hash-file datum.json \
  --change-address $nami \
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