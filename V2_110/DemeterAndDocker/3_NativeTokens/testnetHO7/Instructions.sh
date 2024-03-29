# HANDS ON 07 - EAcoins

## HANDSON No. 07:  Create a multisignature minting policy

1. Add a new minting policy module with the following logic:
   Must be signed by 2 accounts of your choosing.
2. Serialize the minting policy, and derive the corresponding Policy ID.
3. Mint 250 of your your tokens and send them to this address:
```Bash
addr_test1qpc6mrwu9cucrq4w6y69qchflvypq76a47ylvjvm2wph4szeq579yu2z8s4m4tn0a9g4gfce50p25afc24knsf6pj96sz35wnt
```











## unmodified EAcoins.hs script

{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings  #-}

module EAcoins where

import           PlutusTx                        (BuiltinData, compile, unstableMakeIsData, makeIsDataIndexed)
import           PlutusTx.Prelude                (Bool (..),traceIfFalse, otherwise, Integer, ($), (<=), (&&), (>))
import           Plutus.V2.Ledger.Api            (CurrencySymbol, MintingPolicy, ScriptContext, mkMintingPolicyScript)
import           Plutus.V2.Ledger.Api            as PlutusV2
import           Plutus.V1.Ledger.Value          as PlutusV1
import           Plutus.V1.Ledger.Interval      (contains, to) 
import           Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent, ownCurrencySymbol)
--Serialization
import           Mappers                (wrapPolicy)
import           Serialization          (currencySymbol, writePolicyToFile,  writeDataToFile) 
import           Prelude                (IO)

-- ON-CHAIN CODE

data Action = Owner | Time | Price
unstableMakeIsData ''Action

data OurRedeemer = OR { action :: Action
                   , owner :: PubKeyHash
                   , timelimit :: POSIXTime
                   , price :: Integer }

unstableMakeIsData ''OurRedeemer

{-# INLINABLE eaCoins #-}
eaCoins :: OurRedeemer -> ScriptContext -> Bool
eaCoins redeemer sContext = case action redeemer of
                            Owner   -> traceIfFalse    "Not signed properly!"  signedByOwner
                            Time    -> traceIfFalse    "Your run out of time!" timeLimitNotReached                                         
                            Price   -> traceIfFalse    "Price is not covered"  priceIsCovered
    where
        signedByOwner :: Bool
        signedByOwner = txSignedBy info $ owner redeemer

        timeLimitNotReached :: Bool
        timeLimitNotReached = contains (to $ timelimit redeemer) $ txInfoValidRange info 

        priceIsCovered :: Bool
        priceIsCovered =  assetClassValueOf (valueSpent info)  (AssetClass (adaSymbol,adaToken)) > price redeemer

        info :: TxInfo
        info = scriptContextTxInfo sContext



{-# INLINABLE wrappedEAcoinsPolicy #-}
wrappedEAcoinsPolicy :: BuiltinData -> BuiltinData -> ()
wrappedEAcoinsPolicy = wrapPolicy eaCoins

eaCoinsPolicy :: MintingPolicy
eaCoinsPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| wrappedEAcoinsPolicy ||])

-- Serialised Scripts and Values 

saveEAcoinsPolicy :: IO ()
saveEAcoinsPolicy = writePolicyToFile "testnetHO7/eaCoins.plutus" eaCoinsPolicy

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnetHO7/unit.json" ()

saveRedeemerOwner :: IO ()
saveRedeemerOwner = writeDataToFile "./testnetHO7/redeemOwner.json" Owner

saveRedeemerTime :: IO ()
saveRedeemerTime = writeDataToFile "./testnetHO7/redeemTime.json" Time

saveRedeemerPrice :: IO ()
saveRedeemerPrice = writeDataToFile "./testnetHO7/redeemPrice.json" Price

saveOR :: IO ()
saveOR  = writeDataToFile "./testnetHO7/ourRedeemer.json" (OR Owner "a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273" 1686837045000 50)

saveAll :: IO ()
saveAll = do
            saveEAcoinsPolicy
            saveUnit
            saveRedeemerOwner
            saveRedeemerPrice
            saveRedeemerTime
            saveOR