utxoin1="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#0"
utxoin2="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#1"
utxoin3="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#2"
refscript="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#3"
address=$(cat ../../WalletMine/4stake2.addr)
output="31000000"
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file value999.json \
  --tx-in $utxoin2 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file True.json \
  --tx-in $utxoin3 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file unit.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --tx-out $address+$output \
  --tx-out $address+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file grabV2.unsigned

cardano-cli transaction sign \
    --tx-body-file grabV2.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file grabV2.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grabV2.signed