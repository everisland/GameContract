// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/**
 * @title EverIsland Pet contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract EverIslandPet is ERC721, Ownable {
    using SafeMath for uint256;

    uint256 public petPrice = 10000000000000000; //0.01 ETH

    uint public constant maxPetPurchase = 10;

    uint public Total_Type = 20;

    uint private nonce;

    bool public saleIsActive = false;

    constructor() ERC721("EverIslandPet", "EverIslandPet") public{

    }


    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function withdrawFunds(
        address tokenAddress,
        uint256 amount,
        address wallet
    ) external onlyOwner {
        IERC20(tokenAddress).transfer(wallet, amount);
    }

    /**
     * Set some pets aside
     */
    function reservePet(uint num) public onlyOwner {        
        uint supply = totalSupply();
        uint i;
        for (i = 0; i < num; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function setPetPrice(uint256 price) public onlyOwner {
        petPrice = price;
    }

    function setBaseURIAndType(string memory baseURI,uint totalType) public onlyOwner {
        _setBaseURI(baseURI);
        Total_Type = totalType;
    }
    /*
    * Pause sale if active, make active if paused
    */
    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /**
    * Mints Pet
    */
    function mintPet(uint numberOfTokens) public payable{
        require(saleIsActive, "Sale must be active to mint Pets");
        require(numberOfTokens <= maxPetPurchase, "Can only mint 10 tokens at a time");
        require(petPrice.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");
        mintNumberOfTokens(numberOfTokens);
    }

    function mintNumberOfTokens(uint numberOfTokens) private{
        for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
            uint256 tokenIndex = randomId(nonce);
            _setTokenURI(mintIndex,tokenIndex.toString());
            nonce++;
        }
    }


  function randomId(uint256 seed) public view returns (uint8) {
        uint8 randomNumber = uint8(
            uint256(keccak256(abi.encodePacked(block.timestamp, seed, msg.sender))) % Total_Type
        );
        return randomNumber;
    }

  function burn(uint256 tokenId) public{
    require(_isApprovedOrOwner(msg.sender, tokenId));
    require(_exists(tokenId));
    require(ERC721.ownerOf(tokenId) == msg.sender, string(abi.encodePacked("ERC721: Sender does not own TokenId: ", tokenId)));
    _burn(tokenId);
  }


  function tokenURI(uint256 tokenId) public view override returns (string memory) {
      return  ERC721.tokenURI(tokenId);
  }

}