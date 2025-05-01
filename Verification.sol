pragma solidity >=0.4.22 <0.6.0;

contract CredentialVerification {
    address public owner;

    // Mapping to store valid credentials
    mapping(bytes32 => bool) public validCredentials;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    // Government admin registers a valid credential
    function addValidCredential(bytes32 credentialHash) public onlyOwner {
        validCredentials[credentialHash] = true;
    }

    // User calls this to have identiy registered
    function getIdentiyToken(bytes32 credentialHash) public {
        require(validCredentials[credentialHash], "Invalid credential");

        // Mark credential as used
        validCredentials[credentialHash] = false;

        // Other Transaction logic
        // having identity token here
    }

}
