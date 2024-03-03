utxoin1="3464c7c26c75c99a989e39797ee6a2f161b63f826de53878f19c4724afaa8946#0"
utxoin2="3464c7c26c75c99a989e39797ee6a2f161b63f826de53878f19c4724afaa8946#1"
utxoin3="3464c7c26c75c99a989e39797ee6a2f161b63f826de53878f19c4724afaa8946#2"
address=$(cat ../../WalletMine/4stake2.addr) 
output="800000000"
collateral="6a2d6721fde0880c0e9eaa267eb038f0abce7462b915dad0cc903299053922b6#1"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in-script-file datumEqredeemer.plutus \
  --tx-in-datum-file True.json \
  --tx-in-redeemer-file True.json \
  --tx-in-script-file datumEqredeemer.plutus \
  --tx-in-datum-file unit.json \
  --tx-in-redeemer-file unit.json \
  --tx-in-script-file datumEqredeemer.plutus \
  --tx-in-datum-file value23.json \
  --tx-in-redeemer-file value23.json \
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