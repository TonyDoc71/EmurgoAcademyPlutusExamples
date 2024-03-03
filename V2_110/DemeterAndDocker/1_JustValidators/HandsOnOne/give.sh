utxoin="4cc6a67111571267b30b146f818256e797004aa8592abb11b62dbf5d77bead47#3"
address=$(cat datum22.addr) 
output="829000000"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params



cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file value23.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file True.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file unit.json \
  --change-address "addr_test1qra8rx05s9dv4690meheacnnjhs6uj49x24jmtp76e9c2ylede7uzn8enzys93d8735fa93ltmnpnp578vkhkf37a7eqwqcecv" \
  --protocol-params-file protocol.params \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../WalletMine/2batch107.skey \
    $PREVIEW \
    --out-file give.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed