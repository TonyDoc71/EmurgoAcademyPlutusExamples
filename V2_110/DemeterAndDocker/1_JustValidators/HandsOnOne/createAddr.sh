cardano-cli address build --payment-script-file alwaysSucceeds.plutus --testnet-magic 2 --out-file alwaysSucceeds.addr
cardano-cli address build --payment-script-file alwaysFails.plutus --testnet-magic 2 --out-file alwaysFails.addr
cardano-cli address build --payment-script-file redeemer11.plutus --testnet-magic 2 --out-file redeemer11.addr
cardano-cli address build --payment-script-file datum22.plutus --testnet-magic 2 --out-file datum22.addr
cardano-cli address build --payment-script-file datum23.plutus --testnet-magic 2 --out-file datum23.addr
cardano-cli address build --payment-script-file datum23.plutus --testnet-magic 2 --out-file datumEqredeemer.addr

## this is using the logic from the plutus scripts to derive the addresses
## in cardano the adresses already exist you just need to discover them through your logic in the plutus script
## if you want a unique address you need to have unique logic in your script
## as these are from the course everyone is using the same logic logic so get the same address