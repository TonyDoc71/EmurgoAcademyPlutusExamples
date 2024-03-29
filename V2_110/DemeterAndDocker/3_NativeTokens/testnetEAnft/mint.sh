utxoin1="a05752aada03e18697527b3d19a68089a9b67c796b55139346d0f5cfcf05c762#0"
utxoin2=""
policyid=$(cat eaCoins.pid)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
output="10000000"
tokenamount="50"
tokenname=$(echo -n "tony2Batch107" | xxd -ps | tr -d '\n')
collateral="05c86cc4c89456e804dab704bc70bc18447635ec1ff9c908044eedb253d47f35#0"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
ownerPKH=""
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"
address5=$(cat ../../WalletMine/5stake3.addr)
address4=$(cat ../../WalletMine/4stake2.addr)

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address4+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $nami \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file eaCoins.plutus \
  --mint-redeemer-file ourRedeemer.json \
  --protocol-params-file protocol.params \
  --out-file mintTx.body

cardano-cli transaction sign \
    --tx-body-file mintTx.body \
    --signing-key-file ../../WalletMine/5payment3.skey \
    --out-file mintTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file mintTx.signed