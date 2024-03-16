# HANDS ON 03 - Common Conditions for Validtoars

## HANDSON No. 03:  All or nothing!

1. Create a new module with a  new validator to Validate_All_or_Nothing  (name at your discretion)
2. Change the logic to the following:
   * User signature AND
   * Tx execution BEFORE timeline AND
   * Value provided must be *at least* 2 times the price.
3. Serialize the contract, and the following values:
   1. datum with your selected wallet pubkeyhash, timeline and price. (you select them, this are arbitrary conditions)
   2. Feel free to create several with different values.   
4. Lock some value on the contract with the previous datums. 
5. Unlock the value from the UTxOs created on previous step, on a single transaction.
   1. all the UTxO that can be validated for a specific set of conditions.

Observations:
    Notice that different datums might validate the same conditions.

## have created new script CommonCon2.hs    -- for hands on 3 --


used 100 as mion value
used 1ent107.phk
used 1 month from 16/3/24 as the time limit
have already locked 111ADA on conditionator.addr
having issed redeeming with all 3 conditions.
value seems to bne the issue




## ---------------------------------- previous hands on examples --------------------------------------------

## commonConditions.hs

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
data ConditionsDatum = Conditions { owner :: PubKeyHash                   ## need public key hash of signer/owner
                                  , timelimit :: POSIXTime                ## need to set time conditions
                                  , price :: Integer                      ## need to set price
                                  }
unstableMakeIsData ''ConditionsDatum

data ActionsRedeemer = Owner | Time | Price
unstableMakeIsData '' ActionsRedeemer


{-# INLINABLE conditionator #-}
conditionator :: ConditionsDatum -> ActionsRedeemer -> ScriptContext -> Bool
conditionator datum redeemer sContext = case redeemer of
                                         Owner   -> traceIfFalse    "Not signed properly!"  signedByOwner            ## can be approved by owner signing
                                         Time    -> traceIfFalse    "Your run out of time!" timeLimitNotReached      ## can be approved by time limit not being reached                                   
                                         Price   -> traceIfFalse    "Price is not covered"  priceIsCovered           ## can be approved by price being met
    where
        signedByOwner :: Bool
        signedByOwner = txSignedBy info $ owner datum

        timeLimitNotReached :: Bool
        timeLimitNotReached = contains (to $ timelimit datum) $ txInfoValidRange info 

        priceIsCovered :: Bool
        priceIsCovered =  assetClassValueOf (valueSpent info)  (AssetClass (adaSymbol,adaToken)) > price datum

        info :: TxInfo
        info = scriptContextTxInfo sContext


meetAllConditions :: Bool -> Bool -> Bool -> Bool
meetAllConditions ownerSigned withinTime priceMet = ownerSigned && withinTime && priceMet


mappedCommonConditions :: BuiltinData -> BuiltinData -> BuiltinData -> ()
mappedCommonConditions = wrapValidator conditionator

conditionsValidator :: Validator
conditionsValidator =  PlutusV2.mkValidatorScript $$(PlutusTx.compile [|| mappedCommonConditions ||])

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

{- Serialised Scripts and Values -}

saveConditionsValidator :: IO ()
saveConditionsValidator =  writeValidatorToFile "./testnet/conditionator.plutus" conditionsValidator

saveUnit :: IO ()
saveUnit = writeDataToFile "./testnet/unit.json" ()

saveDatum :: IO ()
saveDatum  = writeDataToFile "./testnet/datum.json" (Conditions "832bb3d5216092580bb596b6fd35ae845c63adececd7958466ec38a5" 1686837045000 50) ## pkh, slot# and price ADA
## 1 bytestring and 2 integers


## could also try
## saveDatum :: IO ()
## saveDatum  = writeDataToFile "./testnet/datum.json" (Conditions ../WalletMine/owner.pkh 1686837045000 50) ## pkh, slot# and price ADA

saveRedeemerOwner :: IO ()
saveRedeemerOwner = writeDataToFile "./testnet/redeemOwner.json" Owner

saveRedeemerTime :: IO ()
saveRedeemerTime = writeDataToFile "./testnet/redeemTime.json" Time

saveRedeemerPrice :: IO ()
saveRedeemerPrice = writeDataToFile "./testnet/redeemPrice.json" Price

saveAll :: IO ()
saveAll = do
            saveConditionsValidator
            saveUnit
            saveDatum
            saveRedeemerOwner
            saveRedeemerPrice
            saveRedeemerTime


## bash $ cabal repl
## $ :l CommonConditions
## $ saveAll            -- make sure you have the right folder destination in the scriptsaveAll



## datum.json
## {"constructor":0,"fields":[{"bytes":"a2a15a1901d0229101bcb31629629210ce8d2ccf058d05afea33e273"},{"int":1686837045000},{"int":50}]}

## redeemerOwner.json
## {"constructor":0,"fields":[]}

## redeemerPrice.json
## {"constructor":2,"fields":[]}

## redeemerTime.json
## {"constructor":1,"fields":[]}

## notice all the fileds are empty its the constructor index that changes
## be carefull you don't end up with a common redeemer like True or unit as it will be easy to unlock value
## experiment with long index numbers in the costructor


## derive address
## cardano-cli address build --payment-script-file conditionator.plutus --testnet-magic 2 --out-file conditionator.addr
## can be put in a shell script bash$ chmod +x getAddr.sh   bash$ ./getAddr.sh

## --------------- give.sh

utxoin1="b53199256af167160b155f678b9a42ce543eb109e413d6758c33fb7c761c25f9#0"
utxoin2="f02d07f68407583f7b36792ec231de4b3b37b7063c7029d76109b392f0429c55#4"
address=$(cat conditionator.addr) 
output="401000000"
PREVIEW="--testnet-magic 2"
nami=$(cat ../../WalletMine/Nami.addr)

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin1 \
  --tx-in $utxoin2 \
  --tx-out $address+$output \
  --tx-out-datum-hash-file datum.json \
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


## -------------------------- grab.sh

## need public key hash for signer and the collateral
## signing key for collateral, signer & owner of original UTXO

utxoin="25ff103ce24582340d31a42854f52537b32b2836421fd5b80562a2c242d12959#0"
address=$(cat ../../WalletMine/4stake2.addr)
scAddr=$(cat conditionator.addr)
output="150000000"
collateral="4f507a7d6d5ed9a71b78e62b71372498d3379ffaf31e140e5d7c6c811ea03895#1"
collateralPKH=$(cat ../../WalletMine/5payment3.pkh)
signerPKH=$(cat ../../WalletMine/1ent107.pkh)
ownerPKH=$(cat ../../WalletMine/4payment2.pkh)
nami="addr_test1qzwmwrahq43k0q5cktcv8dfh3ud9y3kr6udvp86heryd7w38rdzjclsf9svxrl67346q6a9uawvykesynl2d6cjt0plsuztp5u" 
PREVIEW="--testnet-magic 2"

cardano-cli query protocol-parameters --testnet-magic 2 --out-file protocol.params

cardano-cli transaction build \
  --babbage-era \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-in-script-file conditionator.plutus \
  --tx-in-datum-file datum.json \
  --tx-in-redeemer-file redeemOwner.json \
  --required-signer-hash $collateralPKH \
  --required-signer-hash $signerPKH \
  --tx-in-collateral $collateral \
  --tx-out $address+$output \
  --tx-out $scAddr+$output \
  --tx-out-datum-hash-file datum.json \
  --change-address $nami \
  --protocol-params-file protocol.params \
  --out-file grab.unsigned

cardano-cli transaction sign \
    --tx-body-file grab.unsigned \
    --signing-key-file ../../WalletMine/4payment2.skey \
    --signing-key-file ../../WalletMine/5payment3.skey \
    --signing-key-file ../../WalletMine/1ent107.skey \
    $PREVIEW \
    --out-file grab.signed

 cardano-cli transaction submit \
    $PREVIEW \
    --tx-file grab.signed




## -------------- github IntersectMBO / plutus-ledger-api / src / plutusledgerapi / v2 / contexts.hs  -- goods reference for Plutus API use

-- editorconfig-checker-disable-file
{-# LANGUAGE DerivingVia       #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE ViewPatterns      #-}

{-# OPTIONS_GHC -Wno-simplifiable-class-constraints #-}
{-# OPTIONS_GHC -fno-strictness #-}
{-# OPTIONS_GHC -fno-specialise #-}
{-# OPTIONS_GHC -fno-omit-interface-pragmas #-}

module PlutusLedgerApi.V2.Contexts
    (
    -- * Pending transactions and related types
      TxInfo(..)
    , ScriptContext(..)
    , ScriptPurpose(..)
    , TxId (..)
    , TxOut(..)
    , TxOutRef(..)
    , TxInInfo(..)
    , findOwnInput
    , findDatum
    , findDatumHash
    , findTxInByTxOutRef
    , findContinuingOutputs
    , getContinuingOutputs
    -- * Validator functions
    , pubKeyOutputsAt
    , valuePaidTo
    , spendsOutput
    , txSignedBy
    , valueSpent
    , valueProduced
    , ownCurrencySymbol
    ) where

import GHC.Generics (Generic)
import PlutusTx
import PlutusTx.AssocMap hiding (filter, mapMaybe)
import PlutusTx.Prelude hiding (toList)
import Prettyprinter (Pretty (..), nest, vsep, (<+>))

import PlutusLedgerApi.V1.Address (Address (..))
import PlutusLedgerApi.V1.Contexts (ScriptPurpose (..))
import PlutusLedgerApi.V1.Credential (Credential (..), StakingCredential)
import PlutusLedgerApi.V1.Crypto (PubKeyHash (..))
import PlutusLedgerApi.V1.DCert (DCert (..))
import PlutusLedgerApi.V1.Scripts
import PlutusLedgerApi.V1.Time (POSIXTimeRange)
import PlutusLedgerApi.V1.Value (CurrencySymbol, Value)
import PlutusLedgerApi.V2.Tx (TxId (..), TxOut (..), TxOutRef (..))

import Prelude qualified as Haskell

-- | An input of a pending transaction.
data TxInInfo = TxInInfo
    { txInInfoOutRef   :: TxOutRef
    , txInInfoResolved :: TxOut
    } deriving stock (Generic, Haskell.Show, Haskell.Eq)

instance Eq TxInInfo where
    TxInInfo ref res == TxInInfo ref' res' = ref == ref' && res == res'

instance Pretty TxInInfo where
    pretty TxInInfo{txInInfoOutRef, txInInfoResolved} =
        pretty txInInfoOutRef <+> "->" <+> pretty txInInfoResolved

-- | A pending transaction. This is the view as seen by validator scripts, so some details are stripped out.
data TxInfo = TxInfo
    { txInfoInputs          :: [TxInInfo] -- ^ Transaction inputs; cannot be an empty list
    , txInfoReferenceInputs :: [TxInInfo] -- ^ /Added in V2:/ Transaction reference inputs
    , txInfoOutputs         :: [TxOut] -- ^ Transaction outputs
    , txInfoFee             :: Value -- ^ The fee paid by this transaction.
    , txInfoMint            :: Value -- ^ The 'Value' minted by this transaction.
    , txInfoDCert           :: [DCert] -- ^ Digests of certificates included in this transaction
    , txInfoWdrl            :: Map StakingCredential Integer -- ^ Withdrawals
                                                      -- /V1->V2/: changed from assoc list to a 'PlutusTx.AssocMap'
    , txInfoValidRange      :: POSIXTimeRange -- ^ The valid range for the transaction.
    , txInfoSignatories     :: [PubKeyHash] -- ^ Signatures provided with the transaction, attested that they all signed the tx
    , txInfoRedeemers       :: Map ScriptPurpose Redeemer -- ^ /Added in V2:/ a table of redeemers attached to the transaction
    , txInfoData            :: Map DatumHash Datum -- ^ The lookup table of datums attached to the transaction
                                                  -- /V1->V2/: changed from assoc list to a 'PlutusTx.AssocMap'
    , txInfoId              :: TxId  -- ^ Hash of the pending transaction body (i.e. transaction excluding witnesses)
    } deriving stock (Generic, Haskell.Show, Haskell.Eq)

instance Eq TxInfo where
    {-# INLINABLE (==) #-}
    TxInfo i ri o f m c w r s rs d tid == TxInfo i' ri' o' f' m' c' w' r' s' rs' d' tid' =
        i == i' && ri == ri' && o == o' && f == f' && m == m' && c == c' && w == w' && r == r' && s == s' && rs == rs' && d == d' && tid == tid'

instance Pretty TxInfo where
    pretty TxInfo{txInfoInputs, txInfoReferenceInputs, txInfoOutputs, txInfoFee, txInfoMint, txInfoDCert, txInfoWdrl, txInfoValidRange, txInfoSignatories, txInfoRedeemers, txInfoData, txInfoId} =
        vsep
            [ "TxId:" <+> pretty txInfoId
            , "Inputs:" <+> pretty txInfoInputs
            , "Reference inputs:" <+> pretty txInfoReferenceInputs
            , "Outputs:" <+> pretty txInfoOutputs
            , "Fee:" <+> pretty txInfoFee
            , "Value minted:" <+> pretty txInfoMint
            , "DCerts:" <+> pretty txInfoDCert
            , "Wdrl:" <+> pretty txInfoWdrl
            , "Valid range:" <+> pretty txInfoValidRange
            , "Signatories:" <+> pretty txInfoSignatories
            , "Redeemers:" <+> pretty txInfoRedeemers
            , "Datums:" <+> pretty txInfoData
            ]

-- | The context that the currently-executing script can access.
data ScriptContext = ScriptContext
    { scriptContextTxInfo  :: TxInfo -- ^ information about the transaction the currently-executing script is included in
    , scriptContextPurpose :: ScriptPurpose -- ^ the purpose of the currently-executing script
    }
    deriving stock (Generic, Haskell.Eq, Haskell.Show)

instance Eq ScriptContext where
    {-# INLINABLE (==) #-}
    ScriptContext info purpose == ScriptContext info' purpose' = info == info' && purpose == purpose'

instance Pretty ScriptContext where
    pretty ScriptContext{scriptContextTxInfo, scriptContextPurpose} =
        vsep
            [ "Purpose:" <+> pretty scriptContextPurpose
            , nest 2 $ vsep ["TxInfo:", pretty scriptContextTxInfo]
            ]

{-# INLINABLE findOwnInput #-}
-- | Find the input currently being validated.
findOwnInput :: ScriptContext -> Maybe TxInInfo
findOwnInput ScriptContext{scriptContextTxInfo=TxInfo{txInfoInputs}, scriptContextPurpose=Spending txOutRef} =
    find (\TxInInfo{txInInfoOutRef} -> txInInfoOutRef == txOutRef) txInfoInputs
findOwnInput _ = Nothing

{-# INLINABLE findDatum #-}
-- | Find the data corresponding to a data hash, if there is one
findDatum :: DatumHash -> TxInfo -> Maybe Datum
findDatum dsh TxInfo{txInfoData} = lookup dsh txInfoData

{-# INLINABLE findDatumHash #-}
-- | Find the hash of a datum, if it is part of the pending transaction's
-- hashes
findDatumHash :: Datum -> TxInfo -> Maybe DatumHash
findDatumHash ds TxInfo{txInfoData} = fst <$> find f (toList txInfoData)
    where
        f (_, ds') = ds' == ds

{-# INLINABLE findTxInByTxOutRef #-}
{-| Given a UTXO reference and a transaction (`TxInfo`), resolve it to one of the transaction's inputs (`TxInInfo`).

Note: this only searches the true transaction inputs and not the referenced transaction inputs.
-}
findTxInByTxOutRef :: TxOutRef -> TxInfo -> Maybe TxInInfo
findTxInByTxOutRef outRef TxInfo{txInfoInputs} =
    find (\TxInInfo{txInInfoOutRef} -> txInInfoOutRef == outRef) txInfoInputs

{-# INLINABLE findContinuingOutputs #-}
-- | Find the indices of all the outputs that pay to the same script address we are currently spending from, if any.
findContinuingOutputs :: ScriptContext -> [Integer]
findContinuingOutputs ctx | Just TxInInfo{txInInfoResolved=TxOut{txOutAddress}} <- findOwnInput ctx = findIndices (f txOutAddress) (txInfoOutputs $ scriptContextTxInfo ctx)
    where
        f addr TxOut{txOutAddress=otherAddress} = addr == otherAddress
findContinuingOutputs _ = traceError "Le" -- "Can't find any continuing outputs"

{-# INLINABLE getContinuingOutputs #-}
-- | Get all the outputs that pay to the same script address we are currently spending from, if any.
getContinuingOutputs :: ScriptContext -> [TxOut]
getContinuingOutputs ctx | Just TxInInfo{txInInfoResolved=TxOut{txOutAddress}} <- findOwnInput ctx = filter (f txOutAddress) (txInfoOutputs $ scriptContextTxInfo ctx)
    where
        f addr TxOut{txOutAddress=otherAddress} = addr == otherAddress
getContinuingOutputs _ = traceError "Lf" -- "Can't get any continuing outputs"

{-# INLINABLE txSignedBy #-}
-- | Check if a transaction was signed by the given public key.
txSignedBy :: TxInfo -> PubKeyHash -> Bool
txSignedBy TxInfo{txInfoSignatories} k = case find ((==) k) txInfoSignatories of
    Just _  -> True
    Nothing -> False

{-# INLINABLE pubKeyOutputsAt #-}
-- | Get the values paid to a public key address by a pending transaction.
pubKeyOutputsAt :: PubKeyHash -> TxInfo -> [Value]
pubKeyOutputsAt pk p =
    let flt TxOut{txOutAddress = Address (PubKeyCredential pk') _, txOutValue} | pk == pk' = Just txOutValue
        flt _                             = Nothing
    in mapMaybe flt (txInfoOutputs p)

{-# INLINABLE valuePaidTo #-}
-- | Get the total value paid to a public key address by a pending transaction.
valuePaidTo :: TxInfo -> PubKeyHash -> Value
valuePaidTo ptx pkh = mconcat (pubKeyOutputsAt pkh ptx)

{-# INLINABLE valueSpent #-}
-- | Get the total value of inputs spent by this transaction.
valueSpent :: TxInfo -> Value
valueSpent = foldMap (txOutValue . txInInfoResolved) . txInfoInputs

{-# INLINABLE valueProduced #-}
-- | Get the total value of outputs produced by this transaction.
valueProduced :: TxInfo -> Value
valueProduced = foldMap txOutValue . txInfoOutputs

{-# INLINABLE ownCurrencySymbol #-}
-- | The 'CurrencySymbol' of the current validator script.
ownCurrencySymbol :: ScriptContext -> CurrencySymbol
ownCurrencySymbol ScriptContext{scriptContextPurpose=Minting cs} = cs
ownCurrencySymbol _                                              = traceError "Lh" -- "Can't get currency symbol of the current validator script"

{-# INLINABLE spendsOutput #-}
{- | Check if the pending transaction spends a specific transaction output
(identified by the hash of a transaction and an index into that
transactions' outputs)
-}
spendsOutput :: TxInfo -> TxId -> Integer -> Bool
spendsOutput p h i =
    let spendsOutRef inp =
            let outRef = txInInfoOutRef inp
            in h == txOutRefId outRef
                && i == txOutRefIdx outRef

    in any spendsOutRef (txInfoInputs p)

makeLift ''TxInInfo
makeIsDataIndexed ''TxInInfo [('TxInInfo,0)]

makeLift ''TxInfo
makeIsDataIndexed ''TxInfo [('TxInfo,0)]

makeLift ''ScriptContext
makeIsDataIndexed ''ScriptContext [('ScriptContext,0)]