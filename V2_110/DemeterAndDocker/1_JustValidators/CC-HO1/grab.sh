utxoin="eb8e33b9cc85a8d73a8ad5afafc496cce8660aba4b64c6a7ac7eeb5ea973aff7#1"
address=$(cat ../../WalletMine/4stake2.addr) 
output="35000000"
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file conditionator.plutus \
  --tx-in-datum-file datum.json \
  --tx-in-redeemer-file redeemOwner.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file grab.unsigned

cardano-cli transaction sign \
    --tx-body-file grab.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file grab.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grab.signed