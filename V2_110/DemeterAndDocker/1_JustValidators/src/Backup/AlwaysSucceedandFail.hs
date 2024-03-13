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

{-# INLINABLE allFailTony71Tutorials #-}
allFailTony71Tutorials :: BuiltinData -> BuiltinData -> BuiltinData -> ()   
allFailTony71Tutorials _ _ _ = error ()

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

allFailTony71TutorialsValidator :: Validator
allFailTony71TutorialsValidator = mkValidatorScript $$(PlutusTx.compile [|| allFailTony71Tutorials ||])  

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

saveAllFailTony71Tutorials :: IO ()
saveAllFailTony71Tutorials =  writeValidatorToFile "./DEQrWrapped/allFail71TT.plutus" allFailTony71TutorialsValidator

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
            saveAllFailTony71Tutorials
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
            saveAllFailTony71Tutorials
            saveDatum999
            saveTrue
            saveDEQr
            saveUnit
            saveValue11
            saveValue22
            saveValue23
            saveValue999
            saveFalse