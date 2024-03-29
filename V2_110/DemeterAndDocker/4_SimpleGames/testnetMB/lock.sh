utxoin="b00e051c45fdd9d20b28a0712718e9bf50f541b1ff660b8939d224901edc9ece#0"
address=$(cat mathBounty.addr) 
output="77000000"
PREVIEW="--testnet-magic 2"
# Provide a wallet to see the tx in blockchain explorers
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file bountyConditions.json \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file lock.unsigned

cardano-cli transaction sign \
    --tx-body-file lock.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file lock.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file lock.signed