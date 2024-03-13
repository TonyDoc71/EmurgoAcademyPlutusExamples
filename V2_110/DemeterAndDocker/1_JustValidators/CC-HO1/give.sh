utxoin="37d874dddec4e44e3f949fb71c920e0b6562fc4fb84d8f489fb0c551acdbf151#5"
address=$(cat conditionator.addr) 
output="65000000"
PREVIEW="--testnet-magic 2"
nami=$(cat ../../WalletMine/Nami.addr)

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file datum.json \
  --change-address "addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" \
  --protocol-params-file protocol.params \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file give.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed