utxoin1="721ede6f5113f91e1a90b919735667e202d6738d937f0857b00dbcef0287424a#1"
utxoin2="721ede6f5113f91e1a90b919735667e202d6738d937f0857b00dbcef0287424a#1"
policyid=$(cat EAcoins.pid)
nami="addr_test1qpc6mrwu9cucrq4w6y69qchflvypq76a47ylvjvm2wph4szeq579yu2z8s4m4tn0a9g4gfce50p25afc24knsf6pj96sz35wnt"
output="11000000"
tokenamount="-2200"
tokenname=$(echo -n "TonyBatch107" | xxd -ps | tr -d '\n') ## can put byte 16 code for the token here instead
collateral="2b55046a8742d6e149e0c19cd920c691574133341bb695a952a946c45a000d0b#2"
signerPKH="697a501b7d05766b3d08e39dab43e0f170973d3398b28745b3b8ce55"
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
  --required-signer-hash $ownerPKH \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $nami+$output \
  --change-address $nami \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file EAcoins.plutus \
  --mint-redeemer-file ourRedeemer.json \
  --protocol-params-file protocol.params \
  --out-file burnTx.body

cardano-cli transaction sign \
    --tx-body-file burnTx.body \
    --signing-key-file ../../../../../Wallets/Adr07.skey \
    --signing-key-file ../../../../../Wallets/Adr01.skey \
    $PREVIEW \
    --out-file burnTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file burnTx.signed