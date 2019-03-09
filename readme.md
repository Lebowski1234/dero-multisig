# Multi-Signature Wallet

This multisig wallet was written for the Dero Stargate Smart Contract competition. This document contains a functional description and usage instructions.


## Disclaimer

This contract was written for the Dero Stargate testnet. This smart contract may require modifications to function correctly on the main network. Use at your own risk. 


## Functional Description

The multisig wallet allows a group of individuals to collectively control a single account. For example, a multisig wallet could be used to administer funds in an online community, with multiple stake holders who must all agree on how funds are spent. 

The multisig wallet stores a balance of Dero, and is owned by multiple owners with equal rights. Any owner can create a new send transaction, with a recipient (Dero address) and an amount to send (Dero). Before the transaction is sent by the wallet, multiple owners must approve the transaction by signing it. The number of signatures required is defined when the wallet is set up, and can be any number between 1 and the number of owners. 

When the required number of signatures has been received, the wallet executes the transaction automatically, sending the Dero to the recipient. It is up to the owners to make sure sufficient funds are available in the wallet before signing a transaction. If sending the transaction fails due to insufficient funds, the transaction must be signed again after sufficient funds are available in the wallet. 

Owner 1 deploys the wallet, but does not have any special priviledges once the wallet is deployed. Owner 1 must set up the wallet initially (see below). After the wallet is deployed, the rules of the wallet cannot be changed: number of owners, owner addresses, and number of signatures required to authorize a transaction. 


## Interacting with the Wallet

The wallet is designed to be used with the user interface, which has been written for this wallet here: [https://github.com/lebowski1234/multisig-ui](https://github.com/lebowski1234/multisig-ui)

The user interface is used for interracting with the wallet once it has been deployed. To deploy the wallet, use the command line instructions below under Wallet Deployment. 

Instructions are also provided below for the main wallet functions using the command line in Linux. 

 

## Wallet Setup 

Before deployment, the following parameters must be configured by the person deploying the wallet. This person automatically becomes Owner 1.

* Number of owners
* Owner addresses
* Authorization consensus (how many owners must sign a transaction before it is sent)

All user defined parameters are grouped under the userSetup function:

 
```
Function userSetup(signer String) Uint64
10 STORE("numberOfOwners", 5) //Must match number of non-blank "owner" fields below. 
20 STORE("authorizationConsensus", 4) //Number of owners that must sign before a transaction is authorized. Can be 1 to No. of owners. 
30 STORE("owner1", signer) 
//Add owners below if more than 6 owners required. 
40 STORE("owner2", "dEToiUSsRuXhpuchPysaTe739mXdWGpYvBNZZwqjJgBoaNKY3UoM2AcJ3zwfed8fEBAfTjX2P8iwxW2XP9kb8KaE1rZJzNLU2b")
50 STORE("owner3", "dEToj2C887HTgd81eYCxtwhvZLnkMEuWUFfGcA5onfTGZEo83PH2pEz6R21k7YGdUvZJR33YsPMCSAEW1yFsQDhU2WohB7AjWA")
60 STORE("owner4", "dETonrQSU6p6hFxH51MtmaQHpNv8dAVUpcsXsVMrGQhPNJXWYGgENaqLf1EXbourLJj38iZPXQGT55mV3nWLdqVy6miCMvpTYA")
70 STORE("owner5", "dEToc2bFpqcfK6UPUJBwe7DPbhCZELzuaUGbBHjvrUCb5SPhfXM1FpvbV3oTEMYUbT3AgSicDoFdbCrJW3rKDGWz5x4SWyvV1Q")
80 STORE("owner6", "") 
90 PRINTF "Setup complete!"
100 RETURN 0
End Function
```

These variables must be changed to suit the requirements of the owners. There are no self-checking functions within the smart contract to verify that the data has been entered correctly. The instructions must be followed carefully, to avoid unintended consequences. 


### Number of Owners

The number of owners is declared in Line 10. This can be changed to any number above 1. In this example, there are 5 owners:


```
10 STORE("numberOfOwners", 5)
```


### Owner Addresses

The person deploying the contract automatically becomes owner 1. The addresses of all other owners must be declared prior to contract deployment. These are declared as text values from Line 40 onwards. For example, for 5 owners:

```
40 STORE("owner2", "dEToiUSsRuXhpuchPysaTe739mXdWGpYvBNZZwqjJgBoaNKY3UoM2AcJ3zwfed8fEBAfTjX2P8iwxW2XP9kb8KaE1rZJzNLU2b")
50 STORE("owner3", "dEToj2C887HTgd81eYCxtwhvZLnkMEuWUFfGcA5onfTGZEo83PH2pEz6R21k7YGdUvZJR33YsPMCSAEW1yFsQDhU2WohB7AjWA")
60 STORE("owner4", "dETonrQSU6p6hFxH51MtmaQHpNv8dAVUpcsXsVMrGQhPNJXWYGgENaqLf1EXbourLJj38iZPXQGT55mV3nWLdqVy6miCMvpTYA")
70 STORE("owner5", "dEToc2bFpqcfK6UPUJBwe7DPbhCZELzuaUGbBHjvrUCb5SPhfXM1FpvbV3oTEMYUbT3AgSicDoFdbCrJW3rKDGWz5x4SWyvV1Q")
80 STORE("owner6", "") 
```

If the required number of owners is less than 6, just leave unused owners blank. For example, 3 owners:

```
40 STORE("owner2", "dEToiUSsRuXhpuchPysaTe739mXdWGpYvBNZZwqjJgBoaNKY3UoM2AcJ3zwfed8fEBAfTjX2P8iwxW2XP9kb8KaE1rZJzNLU2b")
50 STORE("owner3", "dEToj2C887HTgd81eYCxtwhvZLnkMEuWUFfGcA5onfTGZEo83PH2pEz6R21k7YGdUvZJR33YsPMCSAEW1yFsQDhU2WohB7AjWA")
60 STORE("owner4", "")
70 STORE("owner5", "")
80 STORE("owner6", "") 
```

For more than 6 owners, just add new lines after 80. Remember to set the numberOfOwners variable to match! Owners must be declared in sequential order. No blank addresses are allowed between declared owners!


### Authorization Consensus

The authorizationConsensus variable defines how many owners are required to sign a transaction before it can be sent. For example, if this variable is set to 4 and there are 5 owners, 4 out of 5 owners must sign the transaction:

```
20 STORE("authorizationConsensus", 4)
```

The variable can be set to any number between 1 and the total number of owners.



## Wallet Deployment

Once setup has been complete, the contract is deployed:

```
curl --request POST --data-binary @multisig.bas http://127.0.0.1:30309/install_sc
```

The Dero Stargate daemon and wallet must both be running first. The wallet must be unlocked and have minimum 50 Dero unlocked balance available.

Get the Dero Stargate binaries here:

[https://git.dero.io/DeroProject/Dero_Stargate_testnet_binaries](https://git.dero.io/DeroProject/Dero_Stargate_testnet_binaries)


To run the daemon:

```
./derod-linux-amd64 --testnet
```

To run the wallet:

```
./dero-wallet-cli-linux-amd64 --rpc-server --wallet-file testnetwallet.db --testnet
```
 


## Using the Wallet

Download the user interface and follow the instructions: [https://github.com/lebowski1234/multisig-ui](https://github.com/lebowski1234/multisig-ui). Command line instructions are provided below as an alternative option. 


## Command Line Usage

### Deposit

To deposit Dero to the wallet, call the Deposit function, specifying the deposit amount (1 Dero = 1000000000000):

```
curl -X POST http://127.0.0.1:30309/json_rpc -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":"0","method":"transfer_split","params":{"mixin":5,"get_tx_key": true , "sc_tx":{"entrypoint":"Deposit","scid":"0fe4053bb6a43eb23331b19a86445f3dcfd7ec4714d318891833674d3a53a2fb" , "value":1000000000000 } }}'

```


### New Transaction

To create a new transaction, call the Send function, specifying the amount to send, and the recipient address. For example to send 1 Dero to dETooXmKXyNee7cfzko9THU9Mc4W8gogLdEVs9fp983HM3T87jxtXhcC4DjLHdoBrfcrwXCZofbCSTmAQTG37gbX7scDokdc86:

```
curl -X POST http://127.0.0.1:30309/json_rpc -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":"0","method":"transfer_split","params":{"mixin":5,"get_tx_key": true , "sc_tx":{"entrypoint":"Send","scid":"0fe4053bb6a43eb23331b19a86445f3dcfd7ec4714d318891833674d3a53a2fb", "value":0, "params":{ "To":"dETooXmKXyNee7cfzko9THU9Mc4W8gogLdEVs9fp983HM3T87jxtXhcC4DjLHdoBrfcrwXCZofbCSTmAQTG37gbX7scDokdc86", "Amount":"1000000000000" } } }}'
```

The wallet then generates and stores a new transaction, and assigns an index number, starting from 0 for the first transaction, and increasing by 1 for subsequent transactions. 


### Sign

For a transaction to be authorized and sent by the multisig wallet, it must be signed by the required number of owners specified in the authorization consensus variable. To do this, the owner must know the index number of the transaction, and call the Sign function. For example, to sign transaction with index number 42:


```
curl -X POST http://127.0.0.1:30309/json_rpc -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":"0","method":"transfer_split","params":{"mixin":5,"get_tx_key": true , "sc_tx":{"entrypoint":"Sign","scid":"0fe4053bb6a43eb23331b19a86445f3dcfd7ec4714d318891833674d3a53a2fb", "value":0, "params":{ "ID":"42" } } }}'
```

The index number is best obtained through the user interface.


### Displaying Wallet Balance

The easiest way of checking the balance is via the user interface. Alternatively, the balance can be accessed using curl:

```
curl -X POST http://127.0.0.1:30306/gettransactions -H 'Content-Type: application/json' -d '{"txs_hashes":["0fe4053bb6a43eb23331b19a86445f3dcfd7ec4714d318891833674d3a53a2fb"], "sc_keys": ["null"]}'
```

A large amount of data will be displayed in JSON format. Search for 'sc_balance', the value will be shown after this field (divide this value by 1000000000000 to get the Dero amount). 

The wallet smart contract code does not keep track of the balance, and does not check the balance before attempting to send an authorized transaction. This is intentional. At the time of writing, there is no built in function in Dero Basic to check the smart contract balance from within the smart contract. It is possible for the smart contract author to write functions in the smart contract code to keep track of funds as they flow in and out of the smart contract, however this can be manipulated in at least one situation. If a user sends Dero to the Initialize function, there is no way of recording this value, as the Initialize function only runs once. This could give rise to a situation where funds are locked in the wallet and can't be accessed, or the balance is incorrectly reported. Neither situation is ideal in a cryptocurrency wallet. 


### Viewing Transaction Data

This is done from the user interface. Although possible with curl, it is very cumbersome. 


## Contact Details

I plan to update the smart contract and user interface for the Dero main network, when smart contracts become live. To report a bug, please open an issue in github. 

My contact details are: thedudelebowski1234@gmail.com

Finally, if you found this useful, any Dero donations are most welcome! dERoSME4c5GNUvPo27NsRFeJPR1FKiYt87g8Gknbm6JU9eL3xRPDs6JijHuVNxVzyFZXg1wxjbh52Hu9gUfWd3Lx5QRNTXvJWZ


