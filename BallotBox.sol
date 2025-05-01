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
        bool s = IDcontract.burn(1000000000000000000);
      } 

      else {
        has_ballot[msg.sender] = false;
      }

      return has_ballot[msg.sender];
    }
    
    function castVote(string memory cand_name) public
    {
      require(has_ballot[msg.sender], "Not eligible to vote");

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
      
      require(false, "Not valid candidate");
    }
}
