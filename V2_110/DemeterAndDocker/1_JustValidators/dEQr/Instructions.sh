## took 1 UTXO and locked it on address dEQr.addr with 3 different datum  value999 (INT), True (Bool) and unit ()
## and redeemed using those datum
## always check your collateral UTXO is valid before transacting to avoid failure from already getting consumed on previous 
## failed transaction.



## give.sh

utxoin="8951465cfda3103f7662306936c38bbf62b236352fafa6063eb43dcd3ae3a22c#4"
address=$(cat dEQr.addr) 
output="15000000"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file value999.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file unit.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file True.json \
  --change-address "addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" \
  --protocol-params-file protocol.params \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../WalletMine/4payment2.skey \
    $PREVIEW \
    --out-file give.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed

## grab.sh

utxoin1="71a70a012d131efc9fb14de9f56913bc6f03e955f60b866688dad479e2590664#0"
utxoin2="71a70a012d131efc9fb14de9f56913bc6f03e955f60b866688dad479e2590664#1"
utxoin3="71a70a012d131efc9fb14de9f56913bc6f03e955f60b866688dad479e2590664#2"
address=$(cat ../../WalletMine/4stake2.addr) 
output="14000000"
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in-script-file dEQr.plutus \
  --tx-in-datum-file value999.json \
  --tx-in-redeemer-file value999.json \
  --tx-in $utxoin2 \
  --tx-in-script-file dEQr.plutus \
  --tx-in-datum-file unit.json \
  --tx-in-redeemer-file unit.json \
  --tx-in $utxoin3 \
  --tx-in-script-file dEQr.plutus \
  --tx-in-datum-file True.json \
  --tx-in-redeemer-file True.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \                    ## need 1 tx-out per UTXO or the others will gett bundled in with the change and sent to change address
  --tx-out $address+$output \
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

