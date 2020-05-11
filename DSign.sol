pragma solidity 0.6.7;

contract DSign{
        
    struct Profile{
        address OwnerAddress; 
        string DocumentTitle; 
        uint TotalKeyGen; 
        string[] SignedPerson; 
    }
    
  struct InitkeyProfile{
      bytes32 key;
      string DocumentHash; 
   }     
   
    struct SigneeProfile{
      bytes32 signaturekey;
      string DocumentHash; 
   }     
   
    
   mapping (string => Profile) private Folder; 
   mapping (string => InitkeyProfile) private Initkey;
   mapping (address => SigneeProfile) private Signees; 
     
    
     
    //Suggest document hash with online hash tool such as "https://emn178.github.io/online-tools/sha256_checksum.html", using sha256 for good security
    function NewDocument(string memory DocumentTitle, string memory DocumentHash) public {  //this sshould be a payable function 
        
        Profile memory NewDoc; 
        NewDoc.OwnerAddress = msg.sender;
        NewDoc.DocumentTitle = DocumentTitle;
        NewDoc.TotalKeyGen = 0; 
        Folder[DocumentHash] = NewDoc; 
        
      }
    
     function getOwnerAddress(string memory DocumentHash) public view returns (address OwnerAddress) {
      return Folder[DocumentHash].OwnerAddress; 
    }
    
    function getTotalKeyGen(string memory DocumentHash) public view returns (uint TotalNumKey) { 
        require(msg.sender == Folder[DocumentHash].OwnerAddress, "Only document owner can access"); 
        return Folder[DocumentHash].TotalKeyGen; 
    }
    
    function getWhoSigned(uint number, string memory DocumentHash) public view returns (string memory who) {
        return Folder[DocumentHash].SignedPerson[number];    
    }
    
     function GenerateInitKey(string memory DocumentHash, string memory passcode) public returns (bytes32 newKey) {
       require(msg.sender == Folder[DocumentHash].OwnerAddress, "Document does not exist or you are not authorized to perform this function");
       InitkeyProfile memory newClaim; 
       newClaim.key = keccak256(abi.encodePacked(block.timestamp, DocumentHash, passcode));
       newClaim.DocumentHash = DocumentHash; 
       Folder[DocumentHash].TotalKeyGen +=1;
       Initkey[passcode] = newClaim; 
       return (newClaim.key);
    }
    
    function ClaimSignKey(string memory passcode, string memory signaturecode) public returns (bytes32 Signkey) {
        
        require(Initkey[passcode].key != 0 , "Passcode given are invalid");
        SigneeProfile memory newSignee; 
        newSignee.signaturekey = keccak256(abi.encodePacked(msg.sender, signaturecode));
        newSignee.DocumentHash = Initkey[passcode].DocumentHash; 
        Initkey[passcode].key = 0; 
        Initkey[passcode].DocumentHash = ""; 
        Signees[msg.sender] = newSignee; 
        return (newSignee.signaturekey);
    }
    
    function SignDocument(string memory signaturecode, string memory initial) public { 
        
        bytes32 hashkey = keccak256(abi.encodePacked(msg.sender, signaturecode)); 
        require(hashkey == Signees[msg.sender].signaturekey);
        string memory DocumentHash = Signees[msg.sender].DocumentHash; 
        Folder[DocumentHash].SignedPerson.push(initial);
    }
    
    
}
