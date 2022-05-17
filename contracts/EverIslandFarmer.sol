// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title EverIsland Farmer contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract EverIslandFarmer is ERC721, Ownable {
    using SafeMath for uint256;

    uint256 public farmerPrice = 10000000000000000; //0.01 ETH

    uint public constant maxFarmerPurchase = 10;

    uint public MAX_Farmers = 20;

    uint public Total_Type = 20;

    uint private nonce;

    bool public saleIsActive = false;

    constructor() ERC721("EverIslandFarmer", "EverIslandFarmer") public{

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
     * Set some farmer aside
     */
    function reserveFarmer(uint num) public onlyOwner {        
        uint supply = totalSupply();
        uint i;
        for (i = 0; i < num; i++) {
            _safeMint(msg.sender, supply + i);
            uint256 tokenIndex = randomId(nonce);
            _setTokenURI(supply + i,tokenIndex.toString());
            nonce++;
        }
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function setMaxFarmers(uint maxFarmer) public onlyOwner {
        MAX_Farmers = maxFarmer;
    }

    function setFarmerPrice(uint256 price) public onlyOwner {
        farmerPrice = price;
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
    * Mints Farmer
    */
    function mintFarmer(uint numberOfTokens) public payable{
        require(saleIsActive, "Sale must be active to mint Farmers");
        require(numberOfTokens <= maxFarmerPurchase, "Can only mint 10 tokens at a time");
        require(balanceOf(msg.sender)+numberOfTokens <= MAX_Farmers, "Purchase would exceed max balance of Farmer");
        require(farmerPrice.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");
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


  function randomId(uint256 seed) public view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp,block.number, seed, msg.sender))) % Total_Type;
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