{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.

module TypedValidators where

--PlutusTx 
import                  PlutusTx                       (BuiltinData, compile,unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Prelude               (traceIfFalse, otherwise, (==), Bool (..), Integer, ($))
import                  Plutus.V2.Ledger.Api        as PlutusV2
--Serialization
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)
import                  Prelude                     (IO)

------------------------------------------------------------------------------------------
-- Primites Types
------------------------------------------------------------------------------------------

{-# INLINABLE typedDatum22 #-}
typedDatum22 :: Integer -> () -> ScriptContext -> Bool
typedDatum22 datum _ _ = traceIfFalse "Not the right datum!" (datum ==  22)

-- recreate datum equas redeemer here for the new Typed format
-- then make all the supporting scripts below

{-# INLINABLE typedRedeemer11 #-}
typedRedeemer11 ::  () -> Integer -> ScriptContext -> Bool
typedRedeemer11 _ redeemer _ = traceIfFalse "Not the right redeemer!" (redeemer ==  11)

------------------------------------------------------------------------------------------
-- Custom Types
------------------------------------------------------------------------------------------

newtype OurWonderfullDatum = OWD Integer
unstableMakeIsData ''OurWonderfullDatum

data OurWonderfullRedeemer = OWR Integer | JOKER Bool
makeIsDataIndexed ''OurWonderfullRedeemer [('OWR,0),('JOKER,1)]

{-# INLINABLE customTypedDatum22 #-}
customTypedDatum22 :: OurWonderfullDatum -> () -> ScriptContext -> Bool
customTypedDatum22 (OWD datum) _ _ = traceIfFalse "Not the right datum!" (datum ==  22)

{-# INLINABLE customTypedRedeemer11 #-}
customTypedRedeemer11 ::  () -> OurWonderfullRedeemer -> ScriptContext -> Bool
customTypedRedeemer11 _ (OWR number) _    =  traceIfFalse "Not the right redeemer!" (number ==  11)
customTypedRedeemer11 _ (JOKER boolean) _ =  traceIfFalse "The Joker sais no!" boolean

------------------------------------------------------------------------------------------
-- Mappers and Compiling expresions
------------------------------------------------------------------------------------------

-- for primitives types

mappedTypedDatum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedTypedDatum22 = wrapValidator customTypedDatum22

typedDatum22Val :: PlutusV2.Validator
typedDatum22Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedTypedDatum22 ||])

mappedTypedRedeemer11 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedTypedRedeemer11 = wrapValidator typedRedeemer11

typedRedeemer11Val :: Validator
typedRedeemer11Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedTypedRedeemer11 ||])


-- for custom types

mappedCustomTypedDatum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCustomTypedDatum22 = wrapValidator customTypedDatum22

mappedCustomTypedRedeemer11 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCustomTypedRedeemer11 = wrapValidator customTypedRedeemer11

customTypedDatum22Val :: Validator
customTypedDatum22Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCustomTypedDatum22 ||])

customTypedRedeemer11Val :: Validator
customTypedRedeemer11Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCustomTypedRedeemer11 ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveTypedDatum22 :: IO ()
saveTypedDatum22 =  writeValidatorToFile "./TypeWrap/typedDatum22.plutus" typedDatum22Val

saveTypedRedeemer11 :: IO ()
saveTypedRedeemer11 =  writeValidatorToFile "./TypeWrap/typedRedeemer11.plutus" typedRedeemer11Val

saveCustomTypedDatum22 :: IO ()
saveCustomTypedDatum22 =  writeValidatorToFile "./TypeWrap/customTypedDatum22.plutus" customTypedDatum22Val

saveCustomTypedRedeemer11 :: IO ()
saveCustomTypedRedeemer11 =  writeValidatorToFile "./TypeWrap/customTypedRedeemer11.plutus" customTypedRedeemer11Val

saveUnit :: IO ()
saveUnit = writeDataToFile "./TypeWrap/unit.json" ()

saveValue11 :: IO ()
saveValue11 = writeDataToFile "./TypeWrap/value11.json" (11 :: Integer)

saveValue22 :: IO ()
saveValue22 = writeDataToFile "./TypeWrap/value22.json" (22 :: Integer)

saveGoodDatum  :: IO ()
saveGoodDatum = writeDataToFile "./TypeWrap/goodOWD.json" (OWD 22)

saveBadDatum  :: IO ()
saveBadDatum = writeDataToFile "./TypeWrap/badOWD.json" (OWD 23)

saveOWR  :: IO ()
saveOWR = writeDataToFile "./TypeWrap/OWR.json" ()

saveGoodJOKER :: IO ()
saveGoodJOKER = writeDataToFile "./TypeWrap/GoodJoker.json" (JOKER True)

saveBadJOKER :: IO ()
saveBadJOKER = writeDataToFile "./TypeWrap/BadJoker.json" (JOKER False)

saveAll :: IO ()
saveAll = do
            saveTypedDatum22
            saveTypedRedeemer11
            saveCustomTypedDatum22
            saveCustomTypedRedeemer11
            saveUnit
            saveValue11
            saveValue22
            saveGoodDatum
            saveBadDatum
            saveOWR
            saveGoodJOKER
            saveBadJOKER
            