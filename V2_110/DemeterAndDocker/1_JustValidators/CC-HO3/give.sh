utxoin1="b53199256af167160b155f678b9a42ce543eb109e413d6758c33fb7c761c25f9#0"
utxoin2="f02d07f68407583f7b36792ec231de4b3b37b7063c7029d76109b392f0429c55#4"
address=$(cat conditionator.addr) 
output="401000000"
PREVIEW="--testnet-magic 2"
nami=$(cat ../../WalletMine/Nami.addr)

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in $utxoin2 \
  --tx-out $address+$output \
  --tx-out-datum-hash-file datum.json \
  --change-address "addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" \
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