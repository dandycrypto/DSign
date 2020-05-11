pragma solidity 0.6.7;

contract DSign{
    
    //find out how contract can be link to document hash; 
    
    uint256 TargetDocumentHash; 
    //address DocOwner; 
    
    struct Profile{
        address OwnerAddress; 
        string DocumentTitle; 
        uint TotalKeyGen; 
    }
    
  struct InitkeyProfile{
      bytes32 key;
   }     
   
    struct SigneeProfile{
      bytes32 signaturekey;
   }     
   
    
   mapping (string => Profile) private Folder; 
   mapping (string => InitkeyProfile) private Initkey;
   mapping (address => SigneeProfile) private Signees; 
     
    
     
    //Suggest document hash with online hash tool such as "https://emn178.github.io/online-tools/sha256_checksum.html", using sha256 for good security
    function NewTargetDocument(string memory DocumentTitle, string memory DocumentHash) public {  //this sshould be a payable function 
        
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
    
     function GenerateInitKey(string memory DocumentHash, string memory passcode) public returns (bytes32 newKey) {
       require(msg.sender == Folder[DocumentHash].OwnerAddress, "Document does not exist or you are not authorized to perform this function");
       
       InitkeyProfile memory newClaim; 
       newClaim.key = keccak256(abi.encodePacked(block.timestamp, DocumentHash, passcode));
       Folder[DocumentHash].TotalKeyGen +=1;
       Initkey[passcode] = newClaim; 
       return (newClaim.key);
    }
    
    

    function ClaimSignKey(string memory passcode, string memory signaturecode) public returns (bytes32 Signkey) {
        
        require(Initkey[passcode].key != 0 , "Passcode given are invalid");
        SigneeProfile memory newSignee; 
        newSignee.signaturekey = keccak256(abi.encodePacked(Initkey[passcode].key, signaturecode));
        Initkey[passcode].key = 0; 
        Signees[msg.sender] = newSignee; 
        return (newSignee.signaturekey);
    }    
}
