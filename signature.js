const hre = require("hardhat");
const { ethers } = require("hardhat");

async function signHash()
{
    const address = process.argv[2]
    const msgHash = process.argv[3];
    const signer = await hre.ethers.getSigner(address); 
    const signature = await signer.signMessage(ethers.getBytes(msgHash));
    console.log("Here is your signature: ", signature);
}

signHash();