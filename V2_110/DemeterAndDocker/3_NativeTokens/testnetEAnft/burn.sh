utxoin1="a5580562b61f21c66f0f702e190c93e1be75f85fcc6eaf0c4948b8b41dd8874b#0"
utxoin2="bbc76f91ff462df678ee67867e660468b5b231828c11c7669785c1a2b9e9fa1f#0"
policyid=$(cat eaCoins.pid)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
output="10000000"
tokenamount="-50"
tokenname=$(echo -n "tony2Batch107" | xxd -ps | tr -d '\n')
collateral="05c86cc4c89456e804dab704bc70bc18447635ec1ff9c908044eedb253d47f35#0"
signerPKH="a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273"
ownerPKH=""
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"



cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in $utxoin2 \
  --required-signer-hash $signerPKH \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $nami+$output \
  --change-address $nami \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file eaCoins.plutus \
  --mint-redeemer-file ourRedeemer.json \
  --protocol-params-file protocol.params \
  --out-file burnTx.body

cardano-cli transaction sign \
    --tx-body-file burnTx.body \
    --signing-key-file ../../WalletMine/5payment3.skey \
    --signing-key-file ../../WalletMine/4payment2.skey \
    $PREVIEW \
    --out-file burnTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file burnTx.signed