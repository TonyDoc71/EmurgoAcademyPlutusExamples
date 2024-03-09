## took 1 UTXO and locked it on address dEQr.addr with 3 different datum  value999 (INT), True (Bool) and unit ()
## and redeemed using those datum
## always check your collateral UTXO is valid before transacting to avoid failure from already getting consumed on previous 
## failed transaction.

## with datum22, datum23, datum999 these will only be able to unlock UTXOs with that specific value
## any other value will be locked forever.
## use datumEqredeemer or dEQr  to lock UTXOs with any datum and still be able to unlock



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



## AlwaysSucceedandFail.hs

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

{-# INLINABLE datum999 #-}
datum999 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
datum999 datum _ _ 
 | datum == mkI 999    = ()                      -- this will only allow you to unlock UTXOs with this value, *** no other value will be able to be redeemed
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
 | redeemer == datum    = ()                           -- this allows you to use any value to lock and unlock instead of just the value in the logic
 | redeemer == mkI 11   = ()                           -- this is the escape clause that will always allow you to redeem the UTXO
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

datum999Validator :: Validator
datum999Validator = mkValidatorScript $$(PlutusTx.compile [|| datum999 ||])

datumEqredeemerValidator :: Validator
datumEqredeemerValidator = mkValidatorScript $$(PlutusTx.compile [|| datumEqredeemer ||])

dEQrValidator :: Validator
dEQrValidator = mkValidatorScript $$(PlutusTx.compile [|| dEQr ||])


{- Serialised Scripts and Values -}

saveAlwaysSucceeds :: IO ()
saveAlwaysSucceeds =  writeValidatorToFile "./dEQr/alwaysSucceeds.plutus" alwaysSucceedsValidator

saveAlwaysFails :: IO ()
saveAlwaysFails =  writeValidatorToFile "./dEQr/alwaysFails.plutus" alwaysFailsValidator

saveRedeemer11 :: IO ()
saveRedeemer11 =  writeValidatorToFile "./dEQr/redeemer11.plutus" redeemer11Validator

saveDatum22 :: IO ()
saveDatum22 =  writeValidatorToFile "./dEQr/datum22.plutus" datum22Validator

saveDatum23 :: IO ()
saveDatum23 =  writeValidatorToFile "./dEQr/datum23.plutus" datum23Validator

saveDatum999 :: IO ()
saveDatum999 =  writeValidatorToFile "./dEQr/datum999.plutus" datum999Validator

saveDatumEqredeemer :: IO ()
saveDatumEqredeemer = writeValidatorToFile "./dEQr/datumEqredeemer.plutus" datumEqredeemerValidator

saveDEQr :: IO ()
saveDEQr = writeValidatorToFile "./dEQr/dEQr.plutus" dEQrValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./dEQr/unit.json" ()

saveTrue :: IO ()
saveTrue = writeDataToFile "./dEQr/True.json" True

saveFalse :: IO ()
saveFalse = writeDataToFile "./dEQr/False.json" False

saveValue11 :: IO ()
saveValue11 = writeDataToFile "./dEQr/value11.json" (11 :: Integer)

saveValue22 :: IO ()
saveValue22 = writeDataToFile "./dEQr/value22.json" (22 :: Integer)

saveValue23 :: IO ()
saveValue23 = writeDataToFile "./dEQr/value23.json" (23 :: Integer)

saveValue999 :: IO ()
saveValue999 = writeDataToFile "./dEQr/value999.json" (999 :: Integer)

saveAll :: IO ()
saveAll = do
            saveAlwaysSucceeds
            saveAlwaysFails
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