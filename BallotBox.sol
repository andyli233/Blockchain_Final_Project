import "hardhat/console.sol";

interface Int_MyAdvanced {
  function balanceOf(address user) external view returns (uint);
  function burn(uint256 _value) external view returns (bool success);
}

contract BallotBox {

    uint numCandidates;
    address public id_address;

    struct Candidate {
      string name;
      uint number;
      uint numVotes;
    }

    mapping (uint => Candidate) public candidate_list;
    mapping (address => bool) public has_ballot;
    mapping (address => string) public votes;
    mapping (address => bytes32) public msgHash;
    mapping (address => uint) public nonces;

    constructor(string memory c1, string memory c2, address ID) public {
      candidate_list[1] = Candidate(c1, 1, 0);
      candidate_list[2] = Candidate(c2, 2, 0);
      id_address = ID;
    }

    
    function getBallot() public 
      returns (bool) {
      Int_MyAdvanced IDcontract = Int_MyAdvanced(id_address);
      if (IDcontract.balanceOf(msg.sender) == 1000000000000000000) {
        //check whether the hash value of the Identity Token matches with the address
        //if it does match
        has_ballot[msg.sender] = true;
        nonces[msg.sender] = 1;
      } 

      else {
        has_ballot[msg.sender] = false;
        require(false, "You do not have an identity token and therefore cannot get a ballot");
      }

      return has_ballot[msg.sender];
    }
    
    function fillBallot(string memory cand_name) public returns (bytes32)
    {
      console.log("Nonce: %d", nonces[msg.sender]);
      votes[msg.sender] = cand_name;
      msgHash[msg.sender] = keccak256(abi.encodePacked(cand_name, nonces[msg.sender]));
      //the voter will then sign their vote off-chain
    }


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

        // implicitly return (r, s, v)
    }

    function castVote(bytes memory signature) public
    {
      require(has_ballot[msg.sender], "Not eligible to vote");
      string memory cand_name = votes[msg.sender];
      console.log(cand_name);
      require(verify(msg.sender,votes[msg.sender], nonces[msg.sender], signature), "Signature rejected");
      console.log("Requires success");
      if (keccak256(abi.encodePacked(cand_name)) == 
      (keccak256(abi.encodePacked(candidate_list[1].name)))) {
        candidate_list[1].numVotes++;
        return;
      }

      else if (keccak256(abi.encodePacked(cand_name)) == 
      (keccak256(abi.encodePacked(candidate_list[2].name)))) {
        candidate_list[2].numVotes++;
        return;
      }
      console.log("Added vote");
      require(false, "Not valid candidate");
    }
}
