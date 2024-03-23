## this a a minting policy for creating & burning coins 
## it is setup to work this owner signature or time limit or value reached
## can be changed to make ALL required to validate
## you can use a different public key hash to validate than the one supplying the UTXO ypu will just need 2 sugnatures



 
## EAcoins.hs


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
saveEAcoinsPolicy = writePolicyToFile "testnet2/eaCoins.plutus" eaCoinsPolicy

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet2/unit.json" ()

saveRedeemerOwner :: IO ()
saveRedeemerOwner = writeDataToFile "./testnet2/redeemOwner.json" Owner

saveRedeemerTime :: IO ()
saveRedeemerTime = writeDataToFile "./testnet2/redeemTime.json" Time

saveRedeemerPrice :: IO ()
saveRedeemerPrice = writeDataToFile "./testnet2/redeemPrice.json" Price

saveOR :: IO ()
saveOR  = writeDataToFile "./testnet2/ourRedeemer.json" (OR Owner "a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273" 1686837045000 50)
## (OR Owner "a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273" 1686837045000 50) number after Owner is public key has of the signer

saveAll :: IO ()
saveAll = do
            saveEAcoinsPolicy
            saveUnit
            saveRedeemerOwner
            saveRedeemerPrice
            saveRedeemerTime
            saveOR





## used 5stake3.addr for collateral signing and the UTXO so only 1 sugnature required

## create the address & policy id .pid 

# Create Protocol Parameters
cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

# Derive PolicyID from Minting Policy Validator


### can be put into a shell script and run 
cardano-cli address build --payment-script-file dEQr.plutus --testnet-magic 2 --out-file dEQr.addr



## mint.sh

## did not save the script on the transaction ????


utxoin1="8951465cfda3103f7662306936c38bbf62b236352fafa6063eb43dcd3ae3a22c#5"
utxoin2=""
policyid=$(cat eaCoins.pid)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
output="5000000"
tokenamount="8500"
tokenname=$(echo -n "tonyBatch107" | xxd -ps | tr -d '\n')
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
signerPKH="a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273"
ownerPKH=""
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $nami+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $nami \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file eaCoins.plutus \
  --mint-redeemer-file ourRedeemer.json \
  --protocol-params-file protocol.params \
  --out-file mintTx.body

cardano-cli transaction sign \
    --tx-body-file mintTx.body \
    --signing-key-file ../../WalletMine/5payment3.skey \
    --out-file mintTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file mintTx.signed


## grab.sh


## tokenname=$(echo -n "tonyBatch107" | xxd -ps | tr -d '\n') ## can put byte 16 code for the token here instead

## bash repo$ cardano-cli query utxo --address addr_test1qz32zkseq8gz9ygphje3v2tzjggvarfveuzc6pd0age7yumayw8ggdd4v37lthf9pq4tn9pzq2v6njtn8s748wrkw9tqszuju7 --testnet-magic 2

## bash repo$ 7cbd8e53bdbca00a812f6298d979d29b1e06e38b3ae45a4bbe2d06da7735ff4a     0        1198180 lovelace
## bash repo$  + 8500 222082a9ccba27cbf33a3db5e608efa92dd1612db6ccbac9aaa18006.746f6e794261746368313037 + TxOutDatumNone

## 746f6e794261746368313037 is the byte 16 for the token name that you can use t o substitute
## tokenName="746f6e794261746368313037"












## unmodified mint.sh

utxoin1="92825afa20bd539e632e4f0d4185478a7743091fcdb2658889da431abb98dd1a#5"
utxoin2=""
policyid=$(cat EAcoins.pid)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u"
output="5000000"
tokenamount="8500"
tokenname=$(echo -n "TonyBatch107" | xxd -ps | tr -d '\n')
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
signerPKH="a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273"
ownerPKH=""
notneeded="--invalid-hereafter 10962786"
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --required-signer-hash $ownerPKH \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $Adr01+"50000000" \
  --tx-out $Adr01+"60000000" \
  --tx-out $Adr01+$output \
  --tx-out $Adr01+"220000000" \
  --tx-out $nami+$output+"$tokenamount $policyid.$tokenname" \
  --change-address $nami \
  --mint "$tokenamount $policyid.$tokenname" \
  --mint-script-file EAcoins.plutus \
  --mint-redeemer-file ourRedeemer.json \
  --protocol-params-file protocol.params \
  --out-file mintTx.body

cardano-cli transaction sign \
    --tx-body-file mintTx.body \
    --signing-key-file ../../Wallets/5payment3.skey \
    $PREVIEW \
    --out-file mintTx.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file mintTx.signed