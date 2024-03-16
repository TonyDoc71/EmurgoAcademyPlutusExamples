{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.

module CommonConditions where

--PlutusTx 
import                  PlutusTx                       (BuiltinData, compile, unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Prelude               (traceIfFalse, otherwise, (==), Bool (..), Integer, ($), (>))
import                  Plutus.V1.Ledger.Value      as PlutusV1
import                  Plutus.V1.Ledger.Interval      (contains, to) 
import                  Plutus.V2.Ledger.Api        as PlutusV2
import                  Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent)
--Serialization
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)
import                  Prelude                         (IO)

--THE ON-CHAIN CODE
data ConditionsDatum = Conditions { owner :: PubKeyHash
                                  , timelimit :: POSIXTime
                                  , price :: Integer
                                  }
unstableMakeIsData ''ConditionsDatum

data ActionsRedeemer = Owner | Time | Price
unstableMakeIsData '' ActionsRedeemer


{-# INLINABLE conditionator #-}
conditionator :: ConditionsDatum -> ActionsRedeemer -> ScriptContext -> Bool
conditionator datum redeemer sContext = case redeemer of
                                         Owner   -> traceIfFalse    "Not signed properly!"  signedByOwner
                                         Time    -> traceIfFalse    "Your run out of time!" timeLimitNotReached                                         
                                         Price   -> traceIfFalse    "Price is not covered"  priceIsCovered
    where
        signedByOwner :: Bool
        signedByOwner = txSignedBy info $ owner datum

        timeLimitNotReached :: Bool
        timeLimitNotReached = contains (to $ timelimit datum) $ txInfoValidRange info 

        priceIsCovered :: Bool
        priceIsCovered =  assetClassValueOf (valueSpent info)  (AssetClass (adaSymbol,adaToken)) > price datum

        info :: TxInfo
        info = scriptContextTxInfo sContext


mappedCommonConditions :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCommonConditions = wrapValidator conditionator

conditionsValidator :: Validator
conditionsValidator =  PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCommonConditions ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveConditionsValidator :: IO ()
saveConditionsValidator =  writeValidatorToFile "./CC-TimeConst/conditionator.plutus" conditionsValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./CC-TimeConst/unit.json" ()

saveDatum :: IO ()
saveDatum  = writeDataToFile "./CC-TimeConst/datum.json" (Conditions "832bb3d5216092580bb596b6fd35ae845c63adececd7958466ec38a5" 1710592233000 50)

saveRedeemerOwner :: IO ()
saveRedeemerOwner = writeDataToFile "./CC-TimeConst/redeemOwner.json" Owner

saveRedeemerTime :: IO ()
saveRedeemerTime = writeDataToFile "./CC-TimeConst/redeemTime.json" Time

saveRedeemerPrice :: IO ()
saveRedeemerPrice = writeDataToFile "./CC-TimeConst/redeemPrice.json" Price

saveAll :: IO ()
saveAll = do
            saveConditionsValidator
            saveUnit
            saveDatum
            saveRedeemerOwner
            saveRedeemerPrice
            saveRedeemerTime
