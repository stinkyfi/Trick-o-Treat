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
import "@openzeppelin/contracts/utils/Counters.sol";

contract trickOTreat is ERC721Enumerable, ReentrancyGuard, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Hautning starts (Saturday, October 30, 2021 12:00:00 AM) GMT
    uint256 public startHaunt = 1635724799;
    // Haunting ends (Sunday, October 31, 2021 11:59:59 PM) GMT
    uint256 public endHaunt   = 1635552000;
     // Mint Price 1 FTM
    uint256 public price      = 1000000000000000000;

    // Trick Rarities
    string[] private tricks;
    string[] private rare_tricks;
    string[] private legendary_tricks;
    // Treat Rarities
    string[] private treats;
    string[] private rare_treats;
    string[] private legendary_treats;
    
    address public beneficiary;
    //Single mint Freebie
    mapping (address => bool) public freebie;
    //Five Free mints
    mapping (address => uint256) public winner;
    
    constructor(address _beneficiary) ERC721("Trick-O-Treat", "ToT") {
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
        require(_haunting, "This Contract is no longer Haunted");
        require(!freebie[msg.sender], "You have already used your free claim");
        _tokenIds.increment();
        _safeMint(_msgSender(), _tokenIds.current());
        freebie[msg.sender] = true;
    }
    
    function contestWinner() public nonReentrant {
        bool _haunting = witchingHour();
        require(_haunting, "This Contract is no longer Haunted");
        require(winner[msg.sender] == 0, "Your name is not on the list, rejected.");
        for(uint256 i = 0; i <= winner[msg.sender]; i++)
        {
            _tokenIds.increment();
            _safeMint(_msgSender(), _tokenIds.current());
        }
        delete winner[msg.sender];
    }
    
    function claim() public payable nonReentrant {
        bool _haunting = witchingHour();
        require(_haunting, "This Contract is no longer Haunted");
        require(price == msg.value, "Incorrect payment amount");
        _tokenIds.increment();
        _safeMint(_msgSender(), _tokenIds.current());
        payable(beneficiary).transfer(msg.value);
    }

    function claimHandfull(uint256 _mintAmount) public payable {
        bool _haunting = witchingHour();
        require(_haunting, "This Contract is no longer Haunted");
        uint256 _bundle = _mintAmount * price;
        require(_bundle == msg.value, "Incorrect payment amount");
        
        for(uint256 i = 0; i < _mintAmount; i++)
        {
            _tokenIds.increment();
            _safeMint(_msgSender(), _tokenIds.current());
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
    
    function bowlGrab(uint256 _tokenId) internal view returns (string memory) {
        uint256 rand = random(_tokenId, "Trick-O-Treat");

        if(rand % 6 == 0)
        {
            //Trick
            if(rand % 16 == 0) // Rare 
            {   
                if(rand % 26 == 0) //legendary Trick
                    return legendary_tricks[rand % legendary_tricks.length];
                return rare_tricks[rand % rare_tricks.length];
            }
            return tricks[rand % tricks.length];
        }
        else
        {
            //Treat
            if(rand % 16 == 0) //Rare Treat
            {
                if(rand % 10 == 0)
                    return legendary_treats[rand * legendary_treats.length];
                return rare_treats[rand % rare_treats.length];    
            }
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
    
    // All of the minting functions, will only operate during Halloween weekend 2021
    function witchingHour() public view returns (bool) {
        if(block.timestamp > startHaunt && block.timestamp < endHaunt)
            {return true;}
        else
            {return false;}
    }
    
    // Contest Winners and Partnerships
    function assignWinners(address[] memory _winners, uint256 winnings) public onlyOwner {
        for (uint i=0; i < _winners.length; i++) {
            winner[_winners[i]] = winnings;
        }
    }
    
}
