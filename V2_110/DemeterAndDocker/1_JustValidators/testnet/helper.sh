#### Derive address from script
cardano-cli address build --payment-script-file AlwaysSucceedScript.plutus --testnet-magic 2 --out-file AlwaysSucceedScript.addr
cardano-cli address build --payment-script-file datum22.plutus --testnet-magic 2 --out-file datum22.addr

#### PubKeyHash creation:
cardano-cli address key-hash --payment-verification-key-file benef1.vkey --out-file benef1.pkh
cardano-cli address key-hash --payment-verification-key-file datum22.vkey --out-file datum22.pkh

#### Query UTXo
datum22.addr
cardano-cli query utxo --addr_test1wrweuwqm44swpvryhah4y8duf56a5lj4g4v2cx04yau7rqcfgxs6e --testnet-magic 2

