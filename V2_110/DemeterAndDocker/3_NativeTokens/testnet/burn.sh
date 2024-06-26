utxoin1="3217e43c7da8bdbe5f985b31fa40be0a937574c720494c12aaf22d6047f6dfd0#0"
utxoin2="c288698c70fea6628947d0d0a7267b611b768a2499903ad776d94d062f8fb2b5#0"
policyid=$(cat eaCoins.pid)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
output="10000000"
tokenamount="-17000"
tokenamount2="7000
tokenname="546f6e794261746368313037"
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
  --tx-in-collateral $collateral \
  --tx-out $(cat ../../WalletMine/5stake3.addr)+$output \
  --change-address $nami \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file eaCoins.plutus \
  --mint-redeemer-file ourRedeemer.json \
  --protocol-params-file protocol.params \
  --out-file burnTx.body

cardano-cli transaction sign \
    --tx-body-file burnTx.body \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file burnTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file burnTx.signed