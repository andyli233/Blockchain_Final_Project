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

