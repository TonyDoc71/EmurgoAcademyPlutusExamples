utxoin="027e4f8af09c8649c81c4defc7cde6a8d077439a894a604ee57c62375f2143ef#0"
address=$(cat ../../WalletMine/4stake2.addr) 
output="49000000"
collateral="6a2d6721fde0880c0e9eaa267eb038f0abce7462b915dad0cc903299053922b6#1"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qz32zkseq8gz9ygphje3v2tzjggvarfveuzc6pd0age7yumayw8ggdd4v37lthf9pq4tn9pzq2v6njtn8s748wrkw9tqszuju7" 
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file datum22.plutus \
  --tx-in-datum-file unit.json \
  --tx-in-redeemer-file unit.json \
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