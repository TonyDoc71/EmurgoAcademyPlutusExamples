utxoin="bbc76f91ff462df678ee67867e660468b5b231828c11c7669785c1a2b9e9fa1f#1"
address=$(cat ../../WalletMine/4stake2.addr)
scAddr=$(cat conditionator.addr)
output="75000000"
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
collateralPKH=$(cat ../../WalletMine/5payment3.pkh)
signerPKH=$(cat ../../WalletMine/1ent107.pkh)
ownerPKH=$(cat ../../WalletMine/4payment2.pkh)
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
  --required-signer-hash $collateralPKH \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file grabNext.unsigned

cardano-cli transaction sign \
    --tx-body-file grabNext.unsigned \
    --signing-key-file ../../WalletMine/4payment2.skey \
    --signing-key-file ../../WalletMine/5payment3.skey \
    --signing-key-file ../../WalletMine/1ent107.skey \
    $PREVIEW \
    --out-file grabNext.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grabNext.signed