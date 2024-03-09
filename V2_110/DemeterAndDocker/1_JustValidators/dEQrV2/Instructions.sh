## in the previous dEQr    datumEqualToRedeemer it used V1 plutus CIP31-CIP33, this example uses plutus V2 scripts
## this will allow you to store the plutus script on chain in an always fails Address to you can keep a record of all your 
## previous scripts and also to reduce the amount of resources consumed during transactions as you won't need to upload the script 
## for every piece of datum your are giving and consuming.
## dEQr.plutus script below
## the cborHex is the byte code for the script

## dEQr.plutus
{
    "type": "PlutusScriptV2",
    "description": "",
    "cborHex": "583658340100003233222225335333573466ebc00800c014010401854cd4ccd5cd19baf0023750900b00280208030b091001091000890009"
}

## make sure you create the dEQr.addr and all the .json files
## need to create the .plutus script first as it's needed to derive the address

## $ cabal repl                      --make sure you open the correct terminal folder before running
## $ :l AlwaysSucceedsandFail.hs
## $ :r             --reload if modifying
## $ saveAll


## createAddr.sh
cardano-cli address build --payment-script-file dEQr.plutus --testnet-magic 2 --out-file dEQr.addr
## $ chmod +x createAddr.sh
## ./createAddr.sh





## giveV2.sh

utxoin="37d874dddec4e44e3f949fb71c920e0b6562fc4fb84d8f489fb0c551acdbf151#4"
address=$(cat dEQr.addr) 
output="32000000"
address2=$(cat alwaysFails.addr)
output2="8000000"
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-inline-datum-file value999.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file True.json \
  --tx-out $address+$output \
  --tx-out-inline-datum-file unit.json \
  --tx-out $address2+$output2 \
  --tx-out-reference-script-file dEQr.plutus \
  --tx-out-inline-datum-file unit.json \
  --change-address $nami \
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




## second option with reference script for each to-out

utxoin="37d874dddec4e44e3f949fb71c920e0b6562fc4fb84d8f489fb0c551acdbf151#4"
address=$(cat dEQr.addr) 
output="32000000"
address2=$(cat alwaysFails.addr)
output2="8000000"
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params



cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-reference-script-file dEQr.plutus \      -- can also put different scripts on each tx-out
  --tx-out-inline-datum-file value999.json \
  --tx-out $address+$output \
  --tx-out-reference-script-file dEQr.plutus \      -- can also put different scripts on each tx-out
  --tx-out-inline-datum-file True.json \
  --tx-out $address+$output \
  --tx-out-reference-script-file dEQr.plutus \      -- can also put different scripts on each tx-out
  --tx-out-inline-datum-file unit.json \
  --tx-out $address2+$output2 \
  --tx-out-reference-script-file dEQr.plutus \      -- storing script on alwaysFails.addr for future reference & to reduce amount of reasouces consumed
  --tx-out-inline-datum-file unit.json \
  --change-address $nami \
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

## with the V2 script you can see the datum from the terminal 
bash $ cardano-cli query utxo --address addr_test1wpgqrpyzptllgg54t784ggnvq2ncrat2t4qg9wxgu30lwrcc9schw --testnet-magic 2

f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed     0        32000000 lovelace + TxOutDatumInline ReferenceTxInsScriptsInlineDatumsInBabbageEra (HashableScriptData "\EM\ETX\231" (ScriptDataNumber 999))
f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed     1        32000000 lovelace + TxOutDatumInline ReferenceTxInsScriptsInlineDatumsInBabbageEra (HashableScriptData "\216z\128" (ScriptDataConstructor 1 []))
f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed     2        32000000 lovelace + TxOutDatumInline ReferenceTxInsScriptsInlineDatumsInBabbageEra (HashableScriptData "\216y\128" (ScriptDataConstructor 0 []))


## grabV2.sh

## reference script can be called from the UTXO it was attached to in the alwaysFails.addr
refscript="2b52038cd7d2638980114a8f434108c11e845066c25977e0c4f9a4f5533a2449#0"

## public key hash can be puller from a file
#### PubKeyHash creation:
cardano-cli address key-hash --payment-verification-key-file benef1.vkey --out-file benef1.pkh
cardano-cli address key-hash --payment-verification-key-file datum22.vkey --out-file datum22.pkh

signerPKH=$(cat ../../WalletMine/5payment3.pkh)

## or you can put in the hash directly
signerPKH="a2a15a1901d0229101bcb316210ce8d2ccf058d05afea33a273"


## grabV2.sh

utxoin1="2b52038cd7d2638980114a8f434108c11e845066c25977e0c4f9a4f5533a2449#1"
utxoin2="2b52038cd7d2638980114a8f434108c11e845066c25977e0c4f9a4f5533a2449#2"
utxoin3="2b52038cd7d2638980114a8f434108c11e845066c25977e0c4f9a4f5533a2449#3"
refscript="2b52038cd7d2638980114a8f434108c11e845066c25977e0c4f9a4f5533a2449#0"       ## UTXO you saved the plutus script on in the grabV2.sh (alwaysFails.addr)
address=$(cat ../../WalletMine/4stake2.addr)
output="1100000000"
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file value999.json \
  --tx-in $utxoin2 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file True.json \
  --tx-in $utxoin3 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file unit.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file grabV2.unsigned

cardano-cli transaction sign \
    --tx-body-file grabV2.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file grabV2.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grabV2.signed


## actual script used with all 3 UTXOs going to 1 address and changhe to nami wallet

utxoin1="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#0"
utxoin2="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#1"
utxoin3="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#2"
refscript="f25d0e1bd9b013753136b3563f7705eab9306b5f51ae1b45ce17895fa2da3fed#3"
address=$(cat ../../WalletMine/4stake2.addr)
output="31000000"
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file value999.json \
  --tx-in $utxoin2 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file True.json \
  --tx-in $utxoin3 \
  --spending-tx-in-reference $refscript \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file unit.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --tx-out $address+$output \
  --tx-out $address+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file grabV2.unsigned

cardano-cli transaction sign \
    --tx-body-file grabV2.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file grabV2.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grabV2.signed





## try this one to get a unique address for the always fails or just make an address for script storage with unique logic
## you can make a validator with a specific redeemer/datum to unlock and pass unit.json with the UTXO and reference script
## so it can't be unlocked.

## try, this may work 
{-# INLINABLE allFailTony71Tutorials #-}
allFailTony71Tutorials :: BuiltinData -> BuiltinData -> BuiltinData -> ()   
allFailTony71Tutorials _ _ _ = customErrorFunction

customErrorFunction :: a
customErrorFunction = error ()



## AlwaysSucceedandFail.hs
## new save file and new alwaysFailsTT.addr and validator script to make it easier to find my transactions

{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax

module AlwaysSucceedandFail where

--PlutusTx 
import                  PlutusTx                       (BuiltinData, compile)
import                  PlutusTx.Builtins              as Builtins (mkI)
import                  PlutusTx.Prelude               (error, otherwise, (==), Bool (..), Integer)
import                  Plutus.V2.Ledger.Api        as PlutusV2
--Serialization
import                  Serialization    (writeValidatorToFile, writeDataToFile)
import                  Prelude                     (IO)
 
--THE ON-CHAIN CODE

{-# INLINABLE alwaysSucceeds #-}                                    -- Everything that its supposed to run in on-chain code need this program
alwaysSucceeds :: BuiltinData -> BuiltinData -> BuiltinData -> ()   -- the value of this function is on its sideeffects
alwaysSucceeds _ _ _ = () 

{-# INLINABLE alwaysFails #-}
alwaysFails :: BuiltinData -> BuiltinData -> BuiltinData -> ()   
alwaysFails _ _ _ = error ()

{-# INLINABLE alwaysFailsTonyTutorials #-}
alwaysFailsTonyTutorials :: BuiltinData -> BuiltinData -> BuiltinData -> ()   
alwaysFailsTonyTutorials _ _ _ = error ()

{-# INLINABLE redeemer11 #-}
redeemer11 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
redeemer11 _ redeemer _ 
 | redeemer == mkI 11  = ()
 | otherwise           = error ()

{-# INLINABLE datum22 #-}
datum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
datum22 datum _ _ 
 | datum == mkI 22     = ()
 | otherwise           = error ()

{-# INLINABLE datum23 #-}
datum23 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
datum23 datum _ _ 
 | datum == mkI 23     = ()
 | otherwise           = error ()

{-# INLINABLE datum999 #-}
datum999 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
datum999 datum _ _ 
 | datum == mkI 999    = ()
 | otherwise           = error ()


{-# INLINABLE datumEqredeemer #-}
datumEqredeemer :: BuiltinData -> BuiltinData -> BuiltinData -> ()
datumEqredeemer datum redeemer _ 
 | redeemer == datum    = ()
 | redeemer == mkI 11   = ()
 | otherwise            = error ()


{-# INLINEABLE dEQr #-}
dEQr :: BuiltinData -> BuiltinData -> BuiltinData -> ()
dEQr datum redeemer _
 | redeemer == datum    = ()
 | redeemer == mkI 11   = ()
 | otherwise            = error ()


alwaysSucceedsValidator :: Validator
alwaysSucceedsValidator = mkValidatorScript $$(PlutusTx.compile [|| alwaysSucceeds ||])  

alwaysFailsValidator :: Validator
alwaysFailsValidator = mkValidatorScript $$(PlutusTx.compile [|| alwaysFails ||])

alwaysFailsTonyTutorialsValidator :: Validator
alwaysFailsTonyTutorialsValidator = mkValidatorScript $$(PlutusTx.compile [|| alwaysFailsTonyTutorials ||])  

redeemer11Validator :: Validator
redeemer11Validator = mkValidatorScript $$(PlutusTx.compile [|| redeemer11 ||])  

datum22Validator :: Validator
datum22Validator = mkValidatorScript $$(PlutusTx.compile [|| datum22 ||])

datum23Validator :: Validator
datum23Validator = mkValidatorScript $$(PlutusTx.compile [|| datum23 ||])

datum999Validator :: Validator
datum999Validator = mkValidatorScript $$(PlutusTx.compile [|| datum999 ||])

datumEqredeemerValidator :: Validator
datumEqredeemerValidator = mkValidatorScript $$(PlutusTx.compile [|| datumEqredeemer ||])

dEQrValidator :: Validator
dEQrValidator = mkValidatorScript $$(PlutusTx.compile [|| dEQr ||])


{- Serialised Scripts and Values -}

saveAlwaysSucceeds :: IO ()
saveAlwaysSucceeds =  writeValidatorToFile "./DEQrWrapped/alwaysSucceeds.plutus" alwaysSucceedsValidator

saveAlwaysFails :: IO ()
saveAlwaysFails =  writeValidatorToFile "./DEQrWrapped/alwaysFails.plutus" alwaysFailsValidator

saveAlwaysFailsTonyTutorials :: IO ()
saveAlwaysFailsTonyTutorials =  writeValidatorToFile "./DEQrWrapped/alwaysFailsTT.plutus" alwaysFailsTonyTutorialsValidator

saveRedeemer11 :: IO ()
saveRedeemer11 =  writeValidatorToFile "./DEQrWrapped/redeemer11.plutus" redeemer11Validator

saveDatum22 :: IO ()
saveDatum22 =  writeValidatorToFile "./DEQrWrapped/datum22.plutus" datum22Validator

saveDatum23 :: IO ()
saveDatum23 =  writeValidatorToFile "./DEQrWrapped/datum23.plutus" datum23Validator

saveDatum999 :: IO ()
saveDatum999 =  writeValidatorToFile "./DEQrWrapped/datum999.plutus" datum999Validator

saveDatumEqredeemer :: IO ()
saveDatumEqredeemer = writeValidatorToFile "./DEQrWrapped/datumEqredeemer.plutus" datumEqredeemerValidator

saveDEQr :: IO ()
saveDEQr = writeValidatorToFile "./DEQrWrapped/dEQr.plutus" dEQrValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./DEQrWrapped/unit.json" ()

saveTrue :: IO ()
saveTrue = writeDataToFile "./DEQrWrapped/True.json" True

saveFalse :: IO ()
saveFalse = writeDataToFile "./DEQrWrapped/False.json" False

saveValue11 :: IO ()
saveValue11 = writeDataToFile "./DEQrWrapped/value11.json" (11 :: Integer)

saveValue22 :: IO ()
saveValue22 = writeDataToFile "./DEQrWrapped/value22.json" (22 :: Integer)

saveValue23 :: IO ()
saveValue23 = writeDataToFile "./DEQrWrapped/value23.json" (23 :: Integer)

saveValue999 :: IO ()
saveValue999 = writeDataToFile "./DEQrWrapped/value999.json" (999 :: Integer)

saveAll :: IO ()
saveAll = do
            saveAlwaysSucceeds
            saveAlwaysFails
            saveAlwaysFailsTonyTutorials
            saveRedeemer11
            saveDatum22
            saveDatum23
            saveDatum999
            saveDatumEqredeemer
            saveDEQr
            saveUnit
            saveTrue
            saveFalse
            saveValue11
            saveValue22
            saveValue23
            saveValue999

saveDEQRv2 :: IO ()
saveDEQRv2 = do
            saveAlwaysFailsTonyTutorials
            saveDatum999
            saveTrue
            saveDEQr
            saveUnit
            saveValue11
            saveValue22
            saveValue23
            saveValue999
            saveFalse