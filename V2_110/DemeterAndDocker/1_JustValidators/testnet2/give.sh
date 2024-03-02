utxoin="4cc6a67111571267b30b146f818256e797004aa8592abb11b62dbf5d77bead47#1"
address=$(cat datum22.addr) 
output="60000000"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file value22.json \
  --change-address "addr_test1qq2e5wr44m7p92p9ts8cl642hra66rayfz9rp5jx0ycanfj0cmrp6ngfx32dn4l89t6yqkaqwf9hmlu7lwmcflgq0ggsfre70d" \
  --protocol-params-file protocol.params \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../WalletMine/3payment1.skey \
    $PREVIEW \
    --out-file give.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed