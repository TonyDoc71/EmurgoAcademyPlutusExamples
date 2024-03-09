## wrapped Datum Transaction
## setup new alwaysFailsTT.addr for script storage 

## THIS ONE WILL BE USING TypesValidators.hs
## this will allow you to interact with other software as you are using actual types not BuiltinData
newtype OurWonderfullDatum = OWD Integer
unstableMakeIsData ''OurWonderfullDatum

{-# INLINABLE typedDatum22 #-}
typedDatum22 :: Integer -> () -> ScriptContext -> Bool
typedDatum22 datum _ _ = traceIfFalse "Not the right datum!" (datum ==  22)
## use unit in the declaration for the function to ignore the parameter you want to skip ()
## this method gives more functionality like traceIfFalse which makes errors easier to fix



## plus you can create custome data types
data OurWonderfullRedeemer = OWR Integer | JOKER Bool
makeIsDataIndexed ''OurWonderfullRedeemer [('OWR,0),('JOKER,1)]
## [('OWR,0),('JOKER,1)] -- the 0 & 1 are the constructor indexes
## constructors index start at 0 for cardano but start at 1 in Aiken
## you can let plutus assign them or you can do it manually


## data needs to be constructed in the correct order
## format of conversion
Constructor #
    | map (Data, Data)
    | list [Data]
    | bytestring 
    | Integer


## constructor index 0
const0 [I 22]
## constructor index 1
const1 [const0 []]

## constructors will always contain the value not a place holder with the exception of Bool you can use a place holder

## strings as datum will fail on compiling, they will need to be converted to bytestring first

## primitives like Bool, Int etc need to be wrapped to be converted into BuiltinData
mappedTypedDatum22 :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedTypedDatum22 = wrapValidator customTypedDatum22
## Wrappers.hs   -- under /Utilities/src


typedDatum22Val :: PlutusV2.Validator
typedDatum22Val = PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedTypedDatum22 ||])











----------------------------------------------------------------------------------------------------------------



# $ cabal repl
# $ :l TypedValidators
# $ :r                        -- to reload after modification
# $ saveAll                   -- to save all the files

## create a shell script in a new terminal where the files are stored
cardano-cli address build --payment-script-file customTypedDatum22.plutus --testnet-magic 2 --out-file ctd22.addr
cardano-cli address build --payment-script-file customTypedRedeemer11.plutus --testnet-magic 2 --out-file ctr11.addr
cardano-cli address build --payment-script-file typedDatum22.plutus --testnet-magic 2 --out-file td22.addr
cardano-cli address build --payment-script-file typedRedeemer11.plutus --testnet-magic 2 --out-file tr11.addr
# $ chmod +x createAddr.sh    -- to make executable
# $ ./createAddr.sh           -- to make Addresses from the plutus scripts
# $ ls -ll                    -- to see files and sizes plutus scripts much larger now but have more functionality



## TypedValidators.hs     -- unmodified --

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
saveTypedDatum22 =  writeValidatorToFile "./testnet/typedDatum22.plutus" typedDatum22Val

saveTypedRedeemer11 :: IO ()
saveTypedRedeemer11 =  writeValidatorToFile "./testnet/typedRedeemer11.plutus" typedRedeemer11Val

saveCustomTypedDatum22 :: IO ()
saveCustomTypedDatum22 =  writeValidatorToFile "./testnet/customTypedDatum22.plutus" customTypedDatum22Val

saveCustomTypedRedeemer11 :: IO ()
saveCustomTypedRedeemer11 =  writeValidatorToFile "./testnet/customTypedRedeemer11.plutus" customTypedRedeemer11Val

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet/unit.json" ()

saveValue11 :: IO ()
saveValue11 = writeDataToFile "./testnet/value11.json" (11 :: Integer)

saveValue22 :: IO ()
saveValue22 = writeDataToFile "./testnet/value22.json" (22 :: Integer)

saveGoodDatum  :: IO ()
saveGoodDatum = writeDataToFile "./testnet/goodOWD.json" (OWD 22)

saveBadDatum  :: IO ()
saveBadDatum = writeDataToFile "./testnet/badOWD.json" (OWD 23)

saveOWR  :: IO ()
saveOWR = writeDataToFile "./testnet/OWR.json" ()

saveGoodJOKER :: IO ()
saveGoodJOKER = writeDataToFile "./testnet/GoodJoker.json" (JOKER True)

saveBadJOKER :: IO ()
saveBadJOKER = writeDataToFile "./testnet/BadJoker.json" (JOKER False)

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


     