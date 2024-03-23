utxoin1="7cbd8e53bdbca00a812f6298d979d29b1e06e38b3ae45a4bbe2d06da7735ff4a#0"
utxoin2="a8099f785592c1872613b4f49d817f84facc74b8cde8230347cd602828417083#0"
policyid=$(cat eaCoins.pid)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
output="10000000"
tokenamount="-7500"
tokenname="746f6e794261746368313037" ##$(echo -n "tonyBatch107" | xxd -ps | tr -d '\n') ## can put byte 16 code for the token here instead
collateral="a8099f785592c1872613b4f49d817f84facc74b8cde8230347cd602828417083#0"
signerPKH="a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273"
ownerPKH=""
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"

## byte string from token name can be gotten from the cardano explorer when looking at the transaction

## cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params
## not needed already created with the mint.sh

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in $utxoin2 \
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
    $PREVIEW \
    --out-file burnTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file burnTx.signed