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