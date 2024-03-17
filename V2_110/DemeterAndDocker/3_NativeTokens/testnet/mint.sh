utxoin1="bb9382e51cdbbcc2d8f87ad2efb3bc84991dbe8a03da1c091a0f1eb758919f2e#0"
utxoin2=""
policyid=$(cat EAcoins.pid)
nami="addr_test1qpc6mrwu9cucrq4w6y69qchflvypq76a47ylvjvm2wph4szeq579yu2z8s4m4tn0a9g4gfce50p25afc24knsf6pj96sz35wnt"
output="110000000"
tokenamount="10000"
tokenname=$(echo -n "TonyBatch107" | xxd -ps | tr -d '\n')
collateral="2b55046a8742d6e149e0c19cd920c691574133341bb695a952a946c45a000d0b#2"
signerPKH="697a501b7d05766b3d08e39dab43e0f170973d3398b28745b3b8ce55"
ownerPKH=""
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --required-signer-hash $ownerPKH \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
##  --tx-out $Adr01+"50000000" \
##  --tx-out $Adr01+"60000000" \
##  --tx-out $Adr01+$output \
##  --tx-out $Adr01+"220000000" \
  --tx-out $nami+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $nami \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file EAcoins.plutus \
  --mint-redeemer-file ourRedeemer.json \
  --protocol-params-file protocol.params \
  --out-file mintTx.body

cardano-cli transaction sign \
    --tx-body-file mintTx.body \
    --signing-key-file ../../../../../Wallets/Adr07.skey \
    --signing-key-file ../../../../../Wallets/Adr01.skey \
    $PREVIEW \
    --out-file mintTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file mintTx.signed