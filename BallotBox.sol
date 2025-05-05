import "hardhat/console.sol";

interface Int_MyAdvanced {
  function balanceOf(address user) external view returns (uint);
  function burn(uint256 _value) external view returns (bool success);
}


contract BallotBox {

    address public owner;

    // Add this modifier to restrict function execution
    // to only the current owner.

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    uint numCandidates;
    address public id_address;

    struct Candidate {
      string name;
      uint number;
      uint numVotes;
    }
    
    //These data would only be visible by the Government (except for msgHash)
    mapping (uint => Candidate) public candidate_list;
    mapping (address => bool) public has_ballot;
    mapping (address => string) public votes;
    mapping (address => bytes32) public msgHash;
    mapping (address => uint) public nonces;

    constructor(string memory c1, string memory c2, address ID) public {
      //initialize each candidate to have 0 votes
      candidate_list[1] = Candidate(c1, 1, 0);
      candidate_list[2] = Candidate(c2, 2, 0);

      //address of the identity token contract
      id_address = ID;

      //the government deployed the contract, so it is the owner
      owner = msg.sender;
    }

    /*
    This pseudo-code function reads the current vote count for a candidate.
    Only the Government can use this function. In our demo, we view the candidate_list directly, 
    but in a real blockchain solution, we would make the contract variables on visible to the Government.
    */
    function getCandidateVotes(uint cand_num) onlyOwner public view returns (uint) {
      return candidate_list[cand_num].numVotes;
    }

    /*
    This function is where users show their identity token if they have it.
    The fillBallot and sendBallot functions cannot be executed without getting a Ballot first.
    */
    function getBallot() public 
      returns (bool) {
      Int_MyAdvanced IDcontract = Int_MyAdvanced(id_address);
      
      //check if they have an identity token
      if (IDcontract.balanceOf(msg.sender) == 1000000000000000000) {
        //check that the identity token matches the user (not implemented)
        has_ballot[msg.sender] = true;
        nonces[msg.sender] = 1; //initialize nonce
        //we would ideally discard the identity token after one use
      } 

      else {
        has_ballot[msg.sender] = false;
        require(false, "You do not have an identity token and therefore cannot get a ballot");
      }

      return has_ballot[msg.sender];
    }
    
    function fillBallot(string memory cand_name) public returns (bytes32)
    {
      require(has_ballot[msg.sender], "You don't have a ballot!");
      votes[msg.sender] = cand_name; //store candidate choice to be used later

      //The voter must hash their message with the nonce before signing
      msgHash[msg.sender] = keccak256(abi.encodePacked(cand_name, nonces[msg.sender]));
      nonces[msg.sender]++; //we increment the nonce to prevent replay attacks
    }

    /*
    SIGNATURE STEP: THE VOTER WILL SIGN THEIR BALLOT
        WITH THEIR PRIVATE KEY OFF-CHAIN 
    */

    /*
    After signing, the user will send their ballot to the blockchain.
    We must verify the signature before counting the vote.

    The following signature verification helper functions 
    are from https://solidity-by-example.org/signature/
    */
    function verify(
        address _signer,
        string memory _cand_name,
        uint256 _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 message_hash = keccak256(abi.encodePacked(_cand_name, _nonce));
        console.log(recoverSigner(message_hash, signature));
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(message_hash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        // Mimics eth_sign behavior from Ethers.js
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }


    /* 
    Finally, the voter sends their ballot to the Government.
    We verify that the signed message came from the right address.
    If the signature is valid, we add the vote to the intended candidate's voteCount
    */
    function sendBallot(bytes memory signature) public
    {
      require(has_ballot[msg.sender], "Not eligible to vote; no ballot");
      require(verify(msg.sender,votes[msg.sender], nonces[msg.sender]-1, signature), "Signature rejected");
      nonces[msg.sender]++;
      if (keccak256(abi.encodePacked(votes[msg.sender])) == 
      (keccak256(abi.encodePacked(candidate_list[1].name)))) {
        candidate_list[1].numVotes++;
        has_ballot[msg.sender] = false; //can't vote again
        return;
      }

      else if (keccak256(abi.encodePacked(votes[msg.sender])) == 
      (keccak256(abi.encodePacked(candidate_list[2].name)))) {
        has_ballot[msg.sender] = false; //can't vote again
        candidate_list[2].numVotes++;
        return;
      }
      require(false, "Not valid candidate");
    }
}
