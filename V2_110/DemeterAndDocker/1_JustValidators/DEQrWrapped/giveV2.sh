utxoin="37d874dddec4e44e3f949fb71c920e0b6562fc4fb84d8f489fb0c551acdbf151#4"
address=$(cat dEQr.addr) 
output="32000000"
address2=$(cat alwaysFails.addr)
output2="8000000"
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-inline-datum-file value999.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file True.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file unit.json \
  --tx-out $address2+$output2 \
  --tx-out-reference-script-file dEQr.plutus \
  --tx-out-inline-datum-file unit.json \
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