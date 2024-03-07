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


## this is the new section for hands on one.
## make sure you use this logic in the grab.sh script to redeem
{-# INLINABLE datumEqredeemer #-}
datumEqredeemer :: BuiltinData -> BuiltinData -> BuiltinData -> ()
datumEqredeemer datum redeemer _ 
 | redeemer == datum    = ()                   ## this makes the redeemer equal to the datum for redeeming the UTXos
 | redeemer == mkI 11   = ()                   ## this makes the redeemer value 11 to recover funds in an emergency
 | otherwise            = error ()


alwaysSucceedsValidator :: Validator
alwaysSucceedsValidator = mkValidatorScript $$(PlutusTx.compile [|| alwaysSucceeds ||])  

alwaysFailsValidator :: Validator
alwaysFailsValidator = mkValidatorScript $$(PlutusTx.compile [|| alwaysFails ||])  

redeemer11Validator :: Validator
redeemer11Validator = mkValidatorScript $$(PlutusTx.compile [|| redeemer11 ||])  

datum22Validator :: Validator
datum22Validator = mkValidatorScript $$(PlutusTx.compile [|| datum22 ||])

datum23Validator :: Validator
datum23Validator = mkValidatorScript $$(PlutusTx.compile [|| datum23 ||])

## new for hands on one
datumEqredeemerValidator :: Validator
datumEqredeemerValidator = mkValidatorScript $$(PlutusTx.compile [|| datumEqredeemer ||])


{- Serialised Scripts and Values -}

saveAlwaysSucceeds :: IO ()
saveAlwaysSucceeds =  writeValidatorToFile "./HandsOnOne/alwaysSucceeds.plutus" alwaysSucceedsValidator

saveAlwaysFails :: IO ()
saveAlwaysFails =  writeValidatorToFile "./HandsOnOne/alwaysFails.plutus" alwaysFailsValidator

saveRedeemer11 :: IO ()
saveRedeemer11 =  writeValidatorToFile "./HandsOnOne/redeemer11.plutus" redeemer11Validator

saveDatum22 :: IO ()
saveDatum22 =  writeValidatorToFile "./HandsOnOne/datum22.plutus" datum22Validator

saveDatum23 :: IO ()
saveDatum23 =  writeValidatorToFile "./HandsOnOne/datum23.plutus" datum23Validator

## new for hands on one
saveDatumEqredeemer :: IO ()
saveDatumEqredeemer = writeValidatorToFile "./HandsOnOne/datumEqredeemer.plutus" datumEqredeemerValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./HandsOnOne/unit.json" ()

saveTrue :: IO ()
saveTrue = writeDataToFile "./HandsOnOne/True.json" True

saveFalse :: IO ()
saveFalse = writeDataToFile "./HandsOnOne/False.json" False

saveValue11 :: IO ()
saveValue11 = writeDataToFile "./HandsOnOne/value11.json" (11 :: Integer)

saveValue22 :: IO ()
saveValue22 = writeDataToFile "./HandsOnOne/value22.json" (22 :: Integer)

saveValue23 :: IO ()
saveValue23 = writeDataToFile "./HandsOnOne/value23.json" (23 :: Integer)


saveAll :: IO ()
saveAll = do
            saveAlwaysSucceeds
            saveAlwaysFails
            saveRedeemer11
            saveDatum22
            saveDatum23
            saveUnit
            saveTrue
            saveFalse
            saveValue11
            saveValue22
            saveValue23
            saveDatumEqredeemer


## to create all the save files for plutus scripts and .json files
## start cabal in the 1-JustValidators folder in terminal
$ cabal repl
$ saveAll

## use the create.sh script to create all the addresses

bash $ chmod +x create.sh
bash $ ./create.sh

## create a new shell script file createAddr.sh
cardano-cli address build --payment-script-file alwaysSucceeds.plutus --testnet-magic 2 --out-file alwaysSucceeds.addr
cardano-cli address build --payment-script-file alwaysFails.plutus --testnet-magic 2 --out-file alwaysFails.addr
cardano-cli address build --payment-script-file redeemer11.plutus --testnet-magic 2 --out-file redeemer11.addr
cardano-cli address build --payment-script-file datum22.plutus --testnet-magic 2 --out-file datum22.addr
cardano-cli address build --payment-script-file datum23.plutus --testnet-magic 2 --out-file datum23.addr
cardano-cli address build --payment-script-file datum23.plutus --testnet-magic 2 --out-file datumEqredeemer.addr
cardano-cli address build --payment-script-file datum23.plutus --testnet-magic 2 --out-file datum999.addr



## this is using the logic from the plutus scripts to derive the addresses
## in cardano the adresses already exist you just need to discover them through your logic in the plutus script or the arbitary logic from the keys
## if you want a unique address you need to have unique logic in your script
## as these are from the course everyone is using the same logic logic so get the same address

bash $ chmod +x createAddr.sh
bash $ ./createAddr.sh





## give.sh script

utxoin="4cc6a67111571267b30b146f818256e797004aa8592abb11b62dbf5d77bead47#3"
address=$(cat datumEqredeemer.addr) 
output="829000000"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

## below will creat 3 separate UTXOs of 829000000 
## you will need to look at the explorer to determine the datum for each UTXO for your grab.sh script

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \  ##only put in script once don't repeat for each TX-out
  --tx-out $address+$output \
  --tx-out-datum-hash-file value23.json \     ## these won't nessesarily be in the same order on the output UXTOs 
  --tx-out $address+$output \
  --tx-out-datum-hash-file True.json \
  --tx-out $address+$output \
  --tx-out-datum-hash-file unit.json \
  --change-address "addr_test1qra8rx05s9dv4690meheacnnjhs6uj49x24jmtp76e9c2ylede7uzn8enzys93d8735fa93ltmnpnp578vkhkf37a7eqwqcecv" \
  --protocol-params-file protocol.params \
  --out-file give.unsigned

cardano-cli transaction sign \
    --tx-body-file give.unsigned \
    --signing-key-file ../../WalletMine/2batch107.skey \
    $PREVIEW \
    --out-file give.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file give.signed



## new transaction ##

## give.sh

utxoin="30e919fd41fc46e1adb2039ed89b25a4f14e7816674b4ff5fd5966c182e65376#0"
address=$(cat datum999.addr) 
output="9000000"
PREVIEW="--testnet-magic 2"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file value999.json \
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

utxoin1="eb096e45ae95f270129d2884063efd3df3c7fb69a2a50b1d519e9aaddfa74fe2#0"
address=$(cat ../../WalletMine/4stake2.addr) 
output="6000000"
collateral="6a2d6721fde0880c0e9eaa267eb038f0abce7462b915dad0cc903299053922b6#1"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in-script-file datum999.plutus \
  --tx-in-datum-file value999.json \
  --tx-in-redeemer-file unit.json \               ## wasn't using the redeemer so it was ok to pass unit.json
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


## needed to use value999.json as the value was locked on address datum999.addr which is 
## uses the logic from t he plutus script and was expecting a value of type Int 999
## this validator datum999.plutus will only be able to be unlocked when you attach a datum with a value of 999