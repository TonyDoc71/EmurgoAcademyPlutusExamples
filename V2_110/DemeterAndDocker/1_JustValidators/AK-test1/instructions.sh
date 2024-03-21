## copied CBORhex from an aiken plutus.json file

and inserted it into the datum22.plutus script and recreated the address
cardano-cli address build --payment-script-file datum22aiken.plutus --testnet-magic 2 --out-file datum22aiken.addr
the address is different from the datum22.addr

used unit.json and value22.json from alwaysscceeds

## ** this will fail because the way aiken presents the data in the datum is different to how plutus presends it **