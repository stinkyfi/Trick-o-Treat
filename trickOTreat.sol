/*******************************************
 * This contract is an Experiment, and should be used at your own risk.
 * 
 * Author: Stinky Fi 
 * Name:   Trick-O-Treat
 * Desc:   Knock on our door, and say the magic words, if you dare!
 *         Minters will receive a Trick or a Treat, determined by on-chain randomness.
 *         Unlike most contracts, there is no mint cap. When this contract is Haunted,
 *         You will be able to mint as many times as you want. Take advantage, this 
 *         haunting will not last long! Once Halloween is over, no one will be able to mint
 *         from this contract again!
 ******************************************/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract trickOTreat is ERC721Enumerable, ReentrancyGuard, Ownable {
    
    //Halloween Night 11:59:59 Contract Expires
    uint256 public startHaunt = 1635724799;
    uint256 public endHaunt = 1635552000;
    uint256 public lastMint     = 0;
    uint256 public tokenId;
    uint256 public price = 1000000000000000000; //1 FTM
    
    string   private image;
    // Trick Rarities
    string[] private tricks;
    string[] private rare_tricks;
    string[] private legendary_tricks;
    // Treat Rarities
    string[] private treats;
    string[] private rare_treats;
    string[] private legendary_treats;

    
    address public beneficiary;
    mapping (address => bool) public freebie;
    
    constructor(address _beneficiary) ERC721("Test", "OOOO") {
        console.log("Hello");
        beneficiary = _beneficiary;
    }

    function setTrickBag(string[] memory _common, string[] memory _rare, string[] memory _legendary) public onlyOwner {
        tricks = _common;
        rare_tricks = _rare;
        legendary_tricks = _legendary;
    }
    
    function setTreatBag(string[] memory _common, string[] memory _rare, string[] memory _legendary) public onlyOwner {
        treats = _common;
        rare_treats = _rare;
        legendary_treats = _legendary;
    }

    function freeKnock() public nonReentrant {
        bool _haunting = witchingHour();
        require(_haunting, "This Contract is now longer Haunted");
        require(!freebie[msg.sender], "You have already used your free claim");
        tokenId = lastMint + 1;
        _safeMint(_msgSender(), tokenId);
        freebie[msg.sender] = true;
        lastMint = tokenId;
    }
    
    function claim() public payable nonReentrant {
        bool _haunting = witchingHour();
        require(_haunting, "This Contract is now longer Haunted");
        require(price == msg.value, "Incorrect payment amount");
        tokenId = lastMint + 1;
        _safeMint(_msgSender(), tokenId);
        payable(beneficiary).transfer(msg.value);
        lastMint = tokenId;
    }

    function claimHandfull(uint256 _mintAmount) public payable {
        bool _haunting = witchingHour();
        require(_haunting, "This Contract is now longer Haunted");
        uint256 _bundle = _mintAmount * price;
        console.log(_bundle);
        require(_bundle == msg.value, "Incorrect payment amount");
        console.log("we in here");
        
        for(uint256 i = 0; i < _mintAmount; i++)
        {
            tokenId += 1;
            _safeMint(_msgSender(), tokenId);
        }
        
        payable(beneficiary).transfer(msg.value);
    }
    
    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        return bowlGrab(_tokenId);
    }
    
    function random(uint256 _tokenId, string memory _keyPrefix) internal pure returns (uint256) {
        bytes memory abiEncoded = abi.encodePacked(_keyPrefix, toString(_tokenId));
        return uint256(keccak256(abiEncoded));
    }
    
    function bowlGrab(uint256 _tokenId) public view returns (string memory) {
        uint256 rand = random(_tokenId, "trickOtreat");
        // rand = rand % 2;
        
        if(rand % 6 == 0)
        {
            //Trick
            if(rand % 21 == 0) // Rare Trick
                return rare_tricks[rand % rare_tricks.length];
            return tricks[rand % tricks.length];
        }
        else
        {
            //Treat
            if(rand % 11 == 0) //Rare Treat
                return rare_treats[rand % rare_treats.length]; 
            return treats[rand % treats.length];
        }

    }
    
    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
    
    function witchingHour() public view returns (bool) {
        if(block.timestamp > startHaunt && block.timestamp < endHaunt)
            {return true;}
        else
            {return false;}
    }
}
