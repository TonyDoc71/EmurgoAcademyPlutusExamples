// not finished - need to complete auxilary functions under the validators
// put a capital in the file name to get the compiler to ignore
// copy past auxilary functions aiken does not have a standard library yet



use aiken/interval.{Finite}
use aiken/transaction.{ScriptContext}
use aiken/transaction/credential.{VerificationKey}
use aiken/hash.{Blake2b_224, Hash}


validator {
    fn datumEqRedeemer (datum: Int, redeemer: Int, _scr: ScriptContext) -> Bool {
        datum == redeemer
    }
}

validator {
    fn commonConditions(datum: Datum, _redeemer: Int, scr: ScriptContext) -> Bool {
        signedByOwner && timeLimitNotReached && priceIsCovered
    }
}


// auxilary functions
// signed by owner && time && price



// creating custom data types 
type Datum {
    owner: VerificationKeyHash,
    timelimit: POSIXTime,
    price: Int
}

type VerificationKeyHash =
        Hash<Blake2b_224, VerificationKey>

type POSIXTime = Int

// type Action = Int

