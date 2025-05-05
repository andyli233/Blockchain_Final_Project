# Blockchain_Final_Project

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

We call getBallot() for Bob. Since Bob does not have an identity token, he does not get a ballot.
```
bl = ballot.connect(Alice).getBallot();
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
bl = ballot.connect(Alice).castVote(SB);
```


