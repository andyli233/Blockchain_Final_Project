# Blockchain_Final_Project

Create a new Hardhat project. Upload the provided Solidity contracts to the contracts sub-directory and the signature.js file to a different sub-directory (we called it off-chain)

Run the hardhat node in a shell and open a new shell. Run the hardhat console in this shell.

# We will deploy the Identity Token Contract. For simplicity, we use the ERC20Token Contract from Lab 2 to simulate the Identity Token transactions.
```
const { ethers } = require("hardhat"); //import the Hardhat 'ethers' plugin
```
```
const IDToken  = await ethers.getContractFactory("MyAdvancedToken"); // Get the contract factory for the 'MyAdvancedToken' contract
const token = await IDToken.deploy(0, "Voting token", "VT");//deploy contract
```
```
const [Government, Alice, Bob, Charlie] = await ethers.getSigners(); //Get 4 accounts from Hardhat. Government here is the owner.
```
```
const aliceAddr = Alice.address; //Alice’s address is saved as aliceAddr
```
We will assume that Alice has verified her identity in person and will grant her an identity token.
```
c = await token.mintToken(aliceAddr,'1000000000000000000'); // mint 1 token to Alice Address (ie 10^18)
```
None of the other voters have Identity Tokens, so they cannot vote.

We add a function that verifies Alice on the contract after she has verified her identity in person and received a credential.
If you want to use this function, repeat the above steps except giving an identity token using the IdentityToken_Verification.sol.

When Alice verifies her identity in person, she receives a credential, and the government adds this credential to the contract.
```
c = await token.addValidCredential("123456");
```
Alice can use her credential to get the identity token.
```
c = await token.connect(Alice).getIdentityToken("123456");
```


# Next, we will deploy and run the Ballot Box contract. We will check if a voter is registered/eligible, allow them to fill out a ballot, and cast their signed vote. The vote signing will happen off-chain.

Within the console, deploy the BallotBox contract with Candidate 1 and 2 and the address of the voting token

```
const Ballot  = await ethers.getContractFactory("BallotBox");
```
```
const ballot = await Ballot.deploy("Candidate 1","Candidate 2",token);
```

We call getBallot() for Alice. Here Alice successfully gets her ballot, since she has 1 identity token.
```
bl = ballot.connect(Alice).getBallot();
```

We call getBallot() for Bob. Since Bob does not have an identity token, he does not get a ballot (gets an error message)
```
bl = ballot.connect(Bob).getBallot();
```

Next, Alice fills out her ballot with her vote for Candidate 1.
```
bl = ballot.connect(Alice).fillBallot("Candidate 1");
```

Now we retrieve the Alice's ballot in the form of a message hash. By running this command, a hash value will be printed to the console in hexadecimal form. Record this hash value.
```
await ballot.msgHash(aliceAddr);
```

Leave the console running in this shell and open a new shell. This is where we will sign our message off-chain. In this new shell, navigate to our project and run off-chain/signature.js with two arguments: Alice's address (in hexadecimal), and the message hash we obtained from the previous step. Here is an example from our results:
```
node off-chain/signature.js "0x70997970C51812dc3A010C7d01b50e0d17dc79C8" "0x8250fb4550a78fd04e823715bfa584b2119e090269c534050593288292359509"
```
You should see something like this printed to the console. Record this signature for the next steps.
```
Here is your signature:  0x1d8313d94ffc9e5fd4c911695c207f39871a187a504ebdd45146d495f1ad1fe22e18f0e20b2474f43c32
f005b6208235d2465fdc80dc79dda317fa013ede8f9f1c
```

Go back to the shell where the hardhat console is running. Convert the signature to a byte array:
```
const signedHash = "0x1d8313d94ffc9e5fd4c911695c207f39871a187a504ebdd45146d495f1ad1fe22e18f0e20b2474f43c32f005b6208235d2465fdc80dc79dda317fa013ede8f9f1c"
const signedBytes = ethers.getBytes(signedHash);
```
Alice can now cast her vote with her signed ballot. Run the castVote function and pass signedBytes as the parameter.
```
bl = ballot.connect(Alice).castVote(signedBytes);
```
Check the current vote count for Candidate 1. There should be 1 vote now. The number of votes is the third field of the Candidate struct.
```
await ballot.candidate_list(1);
```
Expected result:
```
Result(3) [ 'Candidate 1', 1n, 1n ] //third field 1n means 1 vote
```


