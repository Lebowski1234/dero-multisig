//
//Multisig wallet! Written by thedudelebowski for the Dero smart contract competition!
//Version 1.0 - Competition entry 
//Check out https://github.com/lebowski1234/dero-multisig for setup and usage instructions. 



/*--------------------------------------Initialization Functions--------------------------------------*/


// This function is used to initialize parameters during install time
Function Initialize() Uint64
10 contractIntro()
20 STORE("scblockheightSend", BLOCK_HEIGHT()) 
30 STORE("sctopoheightSend", BLOCK_TOPOHEIGHT())
40 STORE("scblockheightSign", BLOCK_HEIGHT()) 
50 STORE("sctopoheightSign", BLOCK_TOPOHEIGHT())
60 STORE("txCount", 0) 
70 userSetup(SIGNER())
80 RETURN 0
End Function


//Function userSetup: Contains all variables which must be set by the person deploying the contract.
Function userSetup(signer String) Uint64
10 STORE("numberOfOwners", 5) //Must match number of non-blank "owner" fields below. 
20 STORE("authorizationConsensus", 4) //Number of owners that must sign before a transaction is authorized. Can be 1 to No. of owners. 
30 STORE("owner1", signer) 
//Add additional owners below if more than 6 owners required. 
40 STORE("owner2", "dEToiUSsRuXhpuchPysaTe739mXdWGpYvBNZZwqjJgBoaNKY3UoM2AcJ3zwfed8fEBAfTjX2P8iwxW2XP9kb8KaE1rZJzNLU2b")
50 STORE("owner3", "dEToj2C887HTgd81eYCxtwhvZLnkMEuWUFfGcA5onfTGZEo83PH2pEz6R21k7YGdUvZJR33YsPMCSAEW1yFsQDhU2WohB7AjWA")
60 STORE("owner4", "dETonrQSU6p6hFxH51MtmaQHpNv8dAVUpcsXsVMrGQhPNJXWYGgENaqLf1EXbourLJj38iZPXQGT55mV3nWLdqVy6miCMvpTYA") 
70 STORE("owner5", "dEToc2bFpqcfK6UPUJBwe7DPbhCZELzuaUGbBHjvrUCb5SPhfXM1FpvbV3oTEMYUbT3AgSicDoFdbCrJW3rKDGWz5x4SWyvV1Q") 
80 STORE("owner6", "") 
90 PRINTF "Setup complete!"
100 RETURN 0
End Function


//Function contractIntro: Display greeting and useful information, github link etc. 
Function contractIntro() Uint64
10 PRINTF "Contract initialized!"
20 PRINTF "Multisig wallet written by thedudelebowski for the Dero Stargate smart contract competition!"
30 PRINTF "For usage instructions, refer to https://github.com/lebowski1234/dero-multisig"
40 PRINTF "Please note: this smart contract was written for the Stargate testnet. Use at your own risk!"
50 RETURN 0
End Function


/*--------------------------------------Main Functions--------------------------------------*/

//The main functions that are called over RPC are as follows:


//Function Deposit: This function is called to deposit funds into the wallet. Can also be called by other functions if Dero sent during calls to them. 
Function Deposit(value Uint64) Uint64
10 DIM valueDero as String
20 LET valueDero = toDero(value)
30 PRINTF "Deposit received: %s" valueDero  
40 RETURN 0
End Function


//Function Send: Create a new transaction. To is a Dero address, Amount is the amount to send from the wallet balance. To deposit Dero into the wallet at the same time (e.g. to save gas), set value to Dero amount (1000000000000 = 1 Dero). 
Function Send(To String, Amount Uint64, value Uint64) Uint64
10 PRINTF "New transaction received!" 
20 DIM ownerNo, txCount as Uint64
30 IF value == 0 THEN GOTO 50
40 Deposit(value)  
50 LET ownerNo = sendChecks(To, Amount, SIGNER())
60 IF ownerNo != 0 THEN GOTO 80
70 RETURN 1 //Initial checks failed, exiting
80 storeTx(To, Amount, ownerNo)
90 storeSigners()
100 LET txCount = LOAD("txCount")
110 STORE("tx" + txCount + "_signer" + ownerNo, 1) //Transaction originator signs transaction automatically
120 LET txCount = txCount + 1
130 STORE("txCount", txCount)
140 RETURN 0
End Function


//Function Sign: The main sign function. Signs transaction ID, and sends Dero if required number of signatures has been reached. value is an optional amount in Dero to send to the wallet at the same time (e.g. to save gas). 
Function Sign(ID Uint64, value Uint64) Uint64
10 PRINTF "Signing request received!" 
20 DIM ownerNo as Uint64
30 IF value == 0 THEN GOTO 50
40 Deposit(value)  
50 LET ownerNo = signChecks(SIGNER())
60 IF ownerNo != 0 THEN GOTO 80
70 RETURN 1 //Initial checks failed, exiting
80 sign(ID, ownerNo)
90 IF authorized(ID) == 0 THEN GOTO 110 //In this case, 0 = true, as authorized must return 0 to store values within function.
100 RETURN 0 //Not yet authorized, exiting
110 sendDero(ID)//Send Dero 
120 RETURN 0
End Function



/*--------------------------------------Sub Functions--------------------------------------*/

//The following functions are called by the main functions, to break up the code into easy to read sections. 


//Function sendChecks: sequence of checks to perform before transaction is accepted.
Function sendChecks(to String, amount Uint64, signer String) Uint64
10 DIM ownerNo as Uint64
20 IF sendValid(to, amount) == 1 THEN GOTO 30
25 RETURN 0
30 LET ownerNo = verifySigner(signer)
40 IF ownerNo != 0 THEN GOTO 60
50 RETURN 0
60 IF blockCheck("Send") == 0 THEN GOTO 80 //In this case, 0 = true, as blockCheck must return 0 to store values within function.
70 RETURN 0
80 RETURN ownerNo //All checks passed, return owner No. to calling function. 
End Function


//Function signChecks: sequence of checks to perform before signing request is accepted.
Function signChecks(signer String) Uint64
10 DIM ownerNo as Uint64
20 LET ownerNo = verifySigner(signer)
30 IF ownerNo != 0 THEN GOTO 50
40 RETURN 0
50 IF blockCheck("Sign") == 0 THEN GOTO 70 //In this case, 0 = true, as blockCheck must return 0 to store values within function. 
60 RETURN 0
70 RETURN ownerNo //All checks passed, return owner No. to calling function. 
End Function


//Function blockCheck: Used to prevent multiple function calls during one block, which cause unexpected behaviour on testnet. May not be required on mainnet implementation?
Function blockCheck(s String) Uint64
10 IF BLOCK_HEIGHT() > LOAD("scblockheight" + s) THEN GOTO 40
20 PRINTF "Multiple simultaneous function calls detected, exiting function!"
30 RETURN 1
40 IF BLOCK_TOPOHEIGHT() > LOAD("sctopoheight" + s) THEN GOTO 70
50 PRINTF "Multiple simultaneous function calls detected, exiting function!"
60 RETURN 1
70 STORE("scblockheight" + s, BLOCK_HEIGHT()) //store block and topo heights immediately after initial checks, to catch subsequent attempts to load function
80 STORE("sctopoheight" + s, BLOCK_TOPOHEIGHT())
90 RETURN 0
End Function


//Function sendValid: Checks whether Send transaction parameters are valid.
Function sendValid(s String, i Uint64) Uint64
10 IF IS_ADDRESS_VALID(s) == 1 THEN GOTO 40
20 PRINTF "Recipient not a valid Dero address"
30 RETURN 0 //Basic format check has failed, exit
40 IF i >0 THEN GOTO 70
50 PRINTF "Amount to send is zero, not a valid transaction"
60 RETURN 0 //Basic format check has failed, exit
70 RETURN 1
End Function


//Function verifySigner: Check that signer is an owner. 
Function verifySigner(s String) Uint64
10 DIM inc, numberOfOwners as Uint64
30 LET numberOfOwners = LOAD("numberOfOwners")
40 LET inc = 1
50 IF ADDRESS_RAW(s) == ADDRESS_RAW(LOAD("owner" + inc)) THEN GOTO 110
60 IF inc == numberOfOwners THEN GOTO 90 //we have reached numberOfOwners, and not matched the signer's address to an owner.
70 LET inc = inc + 1
80 GOTO 50
90 PRINTF "Signer address not found in list of owners"
100 RETURN 0 //Signer ownership check has failed, result is 0. Calling functon must exit on 0. 
110 RETURN inc //Signer is in list of owners, return owner index.
End Function


//Function storeTx: store a new transaction in the DB
Function storeTx(to String, amount Uint64, owner Uint64) Uint64
10 DIM txCount, ownerNo as Uint64
20 LET txCount = LOAD("txCount")
30 STORE("txIndex_"+txCount, txCount) 
40 STORE("recipient_"+txCount, to)
50 STORE("amount_"+txCount, amount)
60 STORE("sent_"+txCount, 0) //Not sent yet
70 PRINTF "Stored txIndex_%d = %d, recipient_%d = %s, amount_%d = %d, sent_%d = 0" txCount txCount txCount to txCount amount txCount 
80 RETURN 0
End Function 


//Function storeSigners: setup (store) signer fields for a new transaction, based on current txCount.
Function storeSigners() Uint64
10 DIM txCount, ownerNo, numberOfOwners as Uint64
20 LET txCount = LOAD("txCount")
30 LET numberOfOwners = LOAD("numberOfOwners")
40 LET ownerNo = 1
50 STORE("tx" + txCount + "_signer" + ownerNo , 0)
51 PRINTF "Storing tx%d_signer%d" txCount ownerNo
60 IF ownerNo == numberOfOwners THEN GOTO 90
70 LET ownerNo = ownerNo + 1
80 GOTO 50
90 RETURN 0
End Function


//Function sendDero: Retrieve transaction from ID No, send Dero, mark transaction as sent. 
Function sendDero(ID Uint64) Uint64
10 DIM isSent, amount as Uint64
11 DIM to, amountDero as String
20 LET isSent = LOAD("sent_" + ID)
30 IF isSent == 0 THEN GOTO 60
40 PRINTF "Transaction has already been sent!" 
50 RETURN 0
60 LET amount = LOAD("amount_" + ID)
70 LET to = LOAD("recipient_" + ID)
80 LET amountDero = toDero(amount)  
85 PRINTF "Sending %s Dero to %s!" amountDero to 
90 SEND_DERO_TO_ADDRESS(to, amount)
100 STORE("sent_" + ID, 1) //mark tx as sent
110 RETURN 0
End Function


//Function authorized: Counts number of signatures for a transaction, and compares with consensus. Returns 1 if consensus reached.
Function authorized(ID Uint64) Uint64
10 DIM authCount, isSigned, ownerNo, numberOfOwners, authorizationConsensus as Uint64
20 LET numberOfOwners = LOAD("numberOfOwners")
30 LET authorizationConsensus = LOAD("authorizationConsensus")
40 LET ownerNo = 1
50 LET isSigned = LOAD("tx" + ID + "_signer" + ownerNo)
60 LET authCount = authCount + isSigned
70 IF ownerNo == numberOfOwners THEN GOTO 100
80 LET ownerNo = ownerNo + 1
90 GOTO 50
100 IF authCount >= authorizationConsensus THEN GOTO 130
110 PRINTF "Additional signatures required before transaction is authorized."
120 RETURN 1
130 PRINTF "Transaction authorized!"
140 RETURN 0
End Function


//Function sign: check TX ID exists, then sign TX if owner has not already signed
Function sign(ID Uint64, owner Uint64) Uint64
10 DIM isSigned as Uint64
20 IF EXISTS("tx" + ID + "_signer" + owner) THEN GOTO 50
30 PRINTF "Transaction ID %d not found!" ID
40 RETURN 1
50 LET isSigned = LOAD("tx" + ID + "_signer" + owner)
60 IF isSigned == 0 THEN GOTO 90 //Transaction is not yet signed for this owner.
70 PRINTF "Transaction already signed for owner %d" owner
80 RETURN 1
90 STORE("tx" + ID + "_signer" + owner, 1)//Sign transaction for this owner.
100 PRINTF "Transaction signed!"
110 RETURN 0
End Function




/*--------------------------------------Just For Fun--------------------------------------*/


//Function toDero: Written just for fun in the competition! Converts a Uint64 Dero value to an easier to read Dero value with 12 decimal places, for display in the daemon. 
Function toDero(x Uint64) String
10 DIM y, z, n as Uint64
11 DIM zs, ns, result, error as String
12 LET error = "Error in toDero function!"
13 IF x == 0 THEN GOTO 15
14 GOTO 20
15 LET result = "0.000000000000" 
16 RETURN result
20 LET y = x / 1000000000000 
30 LET z = x % 1000000000000 
40 IF z == 0 THEN GOTO 45
41 LET zs = toString(z)
42 GOTO 50
45 LET zs = "0"
50 IF y == 0 THEN GOTO 80
60 LET n = y
70 GOTO 100
80 LET n = 0
100 IF x <1000000000000 THEN GOTO 104
101 GOTO 105
104 LET z = x
105 IF z < 10 THEN GOTO 200 
110 IF z < 100 THEN GOTO 210 
120 IF z < 1000 THEN GOTO 220 
130 IF z < 10000 THEN GOTO 230 
140 IF z < 100000 THEN GOTO 240 
150 IF z < 1000000 THEN GOTO 250 
160 IF z < 10000000 THEN GOTO 260 
170 IF z < 100000000 THEN GOTO 270 
180 IF z < 1000000000 THEN GOTO 280 
190 IF z < 10000000000 THEN GOTO 290 
191 IF z < 100000000000 THEN GOTO 292
192 IF z < 1000000000000 THEN GOTO 294
193 RETURN error //Not sure how we got here!
200 LET result = "" + n + ".00000000000" + zs
201 RETURN result
210 LET result = "" + n + ".0000000000" + zs
211 RETURN result
220 LET result = "" + n + ".000000000" + zs
221 RETURN result
230 LET result = "" + n + ".00000000" + zs
231 RETURN result
240 LET result = "" + n + ".0000000" + zs
241 RETURN result
250 LET result = "" + n + ".000000" + zs
251 RETURN result
260 LET result = "" + n + ".00000" + zs
261 RETURN result
270 LET result = "" + n + ".0000" + zs
271 RETURN result
280 LET result = "" + n + ".000" + zs
281 RETURN result
290 LET result = "" + n + ".00" + zs
291 RETURN result
292 LET result = "" + n + ".0" + zs
293 RETURN result
294 LET result = "" + n + "." + zs
300 RETURN result
End Function


//Function toString: Converts a Uint64 to a String. 
Function toString(x Uint64) String
10 DIM s as String
20 LET s = "" + x
30 RETURN s
End Function


