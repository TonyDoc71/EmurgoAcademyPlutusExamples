## MathsBountny2.hs



{-# LANGUAGE DataKinds           #-}  --Enable datatype promotions
{-# LANGUAGE NoImplicitPrelude   #-}  --Don't load native prelude to avoid conflict with PlutusTx.Prelude
{-# LANGUAGE TemplateHaskell     #-}  --Enable Template Haskell splice and quotation syntax
{-# LANGUAGE OverloadedStrings   #-}  --Enable passing strings as other character formats, like bytestring.

module MathsBounty2 where

--PlutusTx 
import                  PlutusTx                       (BuiltinData, compile, unstableMakeIsData, makeIsDataIndexed)
import                  PlutusTx.Prelude               (traceIfFalse, otherwise, (==), Bool (..), Integer, ($), (>), (+), (&&))
import                  Plutus.V1.Ledger.Value      as PlutusV1
import                  Plutus.V1.Ledger.Interval      (contains, to) 
import                  Plutus.V2.Ledger.Api        as PlutusV2
import                  Plutus.V2.Ledger.Contexts      (txSignedBy, valueSpent)
--Serialization
import                  Mappers                        (wrapValidator)
import                  Serialization                  (writeValidatorToFile, writeDataToFile)
import                  Prelude                         (IO)

--THE ON-CHAIN CODE
data BountyConditions = BC { theX :: Integer
                           , deadline :: POSIXTime
                           }
unstableMakeIsData ''BountyConditions


## below is where you set the value for the UTXO to be redeemed.
## in this cas it is 25. Below the datum is set to 5 so you need to create your own redeemer value of 20
## if the datum value was over 25 the redeemer would need to be a negative integer
## saveRedeemer = writeDataToFile "./testnetMB/redeemer+20.json" (-20::Integer) -- assuming the datum was 45
## also there isa a time limit and the && denotes both conditions must be true to redeem
## deadline = 1712213129000 -- this is in posix time 

{-# INLINABLE mathBounty #-}
mathBounty :: BountyConditions -> Integer -> ScriptContext -> Bool
mathBounty datum redeemer sContext = traceIfFalse "Wrong amswer!" ((theX datum) + redeemer == 25) &&   ## 25 is the value to redeem
                                     traceIfFalse "Deadline reached!" deadlineNotReached

    where
        deadlineNotReached :: Bool
        deadlineNotReached = contains (to $ deadline datum) $ txInfoValidRange info 

        info :: TxInfo
        info = scriptContextTxInfo sContext


mappedMathBounty :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedMathBounty = wrapValidator mathBounty

mathBountyValidator :: Validator
mathBountyValidator =  PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedMathBounty ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveMathBountyValidator :: IO ()
saveMathBountyValidator =  writeValidatorToFile "./testnetMB/mathBounty.plutus" mathBountyValidator

saveDatum :: IO ()
saveDatum = writeDataToFile "./testnetMB/bountyConditions.json" BC { theX = 5
                                                                 , deadline = 1712213129000
                                                                 }

## datum is 35 on this one so the redeemer will need to be -10
## you can take a vaule.json file and change thew Int value
## value.json {"int":-5}    --   change to {"int":-10}
## or make your own redeemer below

saveDatum2 :: IO ()
saveDatum2 = writeDataToFile "./testnetMB/bountyConditions.json" BC { theX = 35
                                                                 , deadline = 1712213129000
                                                                 }

saveTheY :: IO ()
saveTheY = writeDataToFile "./testnetMB/value-5.json" (-5::Integer) 

## added this myself to use as the redeemer
saveRedeemer :: IO ()
saveRedeemer = writeDataToFile "./testnetMB/redeemer+20.json" (20::Integer)

saveRedeemer2 :: IO ()
saveRedeemer2 = writeDataToFile "./testnetMB/redeemer-10.json" (-20::Integer)

saveAll :: IO ()
saveAll = do
           saveMathBountyValidator
           saveDatum
           saveDatum2
           saveTheY
           saveRedeemer
           saveRedeemer2



## lock.sh


utxoin="b00e051c45fdd9d20b28a0712718e9bf50f541b1ff660b8939d224901edc9ece#0"
address=$(cat mathBounty.addr) 
output="77000000"
PREVIEW="--testnet-magic 2"
# Provide a wallet to see the tx in blockchain explorers
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"


cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file bountyConditions.json \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file lock.unsigned

cardano-cli transaction sign \
    --tx-body-file lock.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file lock.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file lock.signed


## unlock.sh
## make sure you select a slot number in the future but not after the time slot from the eposix time in the 
## BountyContitions.json file


utxoin="1f8e50e891b0315753c21a03179574924f781680a4ee0509a3df5d96a9aa91f3#0"
output="49000000"
collateral="eeafd5c0f3d2c9c010a150a297a099ff973e73eca11a85bbcc9d083821758853#5"
signerPKH=$(cat ../../WalletMine/5payment3.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"
Address1=$(cat ../../WalletMine/4stake2.addr) 


cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file mathBounty.plutus \
  --tx-in-datum-file bountyConditions.json \
  --tx-in-redeemer-file redeemer+20.json \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $Address1+$output \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --invalid-hereafter 45061349 \
  --out-file unlock.unsigned 

cardano-cli transaction sign \
    --tx-body-file unlock.unsigned \
    --signing-key-file ../../WalletMine/5payment3.skey \
    $PREVIEW \
    --out-file unlock.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file unlock.signed



    ## BountyConditions.json
    ## {"constructor":0,"fields":[{"int":5},{"int":1712213129000}]}
    

    ## redeemer+20.json
    ## {"int":20}