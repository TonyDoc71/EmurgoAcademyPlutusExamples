utxoin="1f8e50e891b0315753c21a03179574924f781680a4ee0509a3df5d96a9aa91f3#0"
output="49000000"
collateral="eeafd5c0f3d2c9c010a150a297a099ff973e73eca11a85bbcc9d083821758853#5"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"
Address1=$(cat ../../WalletMine/4stake2.addr) 


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file mathBounty.plutus \
  --tx-in-datum-file bountyConditions.json \
  --tx-in-redeemer-file redeemer+20.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $Address1+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --invalid-hereafter 45061349 \
  --out-file unlock.unsigned 

cardano-cli transaction sign \
    --tx-body-file unlock.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file unlock.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file unlock.signed