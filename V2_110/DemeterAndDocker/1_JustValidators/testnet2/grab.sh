utxoin="f37b0b6773619a97ec28459bfc997eb9610c41a1c20d2d8e406823516d07f02c#0"
address=$(cat ialice.addr) 
output="450000000"
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0"
signerPKH=$(cat ialice.pkh)
nami="<provide a wallet to see the tx in blockchain explorers>" 
PREVIEW="--testnet-magic 2"

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file datum22.plutus \
  --tx-in-datum-file unit.json \
  --tx-in-redeemer-file unit.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file grab.unsigned

cardano-cli transaction sign \
    --tx-body-file grab.unsigned \
    --signing-key-file ialice.skey \
    $PREVIEW \
    --out-file grab.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grab.signed