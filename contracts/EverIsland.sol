// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./ERC721A.sol";

interface ILand {
    function mint(address to,uint256 island) external;
}

contract EverIsland is ERC721A, Ownable {
    using SafeMath for uint256;

    event TransferLand(address indexed from, address indexed to, uint256 indexed islandId,uint landId);

    enum Status {
        Pending,
        PreSale,
        PublicSale,
        Finished
    }

    Status public status;
    uint256 public PRICE = 1 ether;
    uint256 public PRSALEPRICE = 0.8 ether;
    uint public constant maxPurchase = 3;
    uint256 public  constant MAX_ISLAND = 1000;
    string private _uri;
    uint256 private _price = PRICE;

    uint256 public immutable maxTotalSupply;

    address public cSigner = 0xab521122331412E21592EB048F9F86e045507A91;

    address public cLand = 0xab521122331412E21592EB048F9F86e045507A91;

    bytes32 constant public MINT_CALL_HASH_TYPE = keccak256("mint(address receiver,uint256 maxamount)");

    mapping(address => uint256) private _mintedNum;


    constructor() ERC721A("EverIsland", "EverIsland", maxPurchase) public {
        maxTotalSupply = MAX_ISLAND;
    }

    function setStatus(Status _status) external onlyOwner {
        status = _status;
        if(status == Status.PublicSale){
            _price = PRICE;
        }else if (status == Status.PreSale){
            _price = PRSALEPRICE;
        }
    }

    function changeSigner(address signer) public onlyOwner {
        cSigner = signer;
    }

    function changeLand(address land) public onlyOwner {
        cLand = land;
    }

    function _baseURI() internal view  override(ERC721A) returns (string memory) {
        return _uri;
    }

    function setURI(string memory newuri) public virtual onlyOwner{
        _uri = newuri;
    }

    function reserveIsland(uint num) public onlyOwner {        
        mintNumberOfTokens(num);
    }

    function preSaleMint(
        uint256 amount,
        uint256 amountV, bytes32 r, bytes32 s
    ) public payable {
        require(status == Status.PreSale, "Must in PreSale status");
        uint256 maxAmount = uint248(amountV);
        uint8 v = uint8(amountV >> 248);
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
                keccak256(abi.encode(MINT_CALL_HASH_TYPE, msg.sender, maxAmount))
        ));
        require(ecrecover(digest, v, r, s) == cSigner, "CrazySea: Invalid signer");
        mint(amount);
    }

    /**
    * Mint at public sale
    */
    function publicSaleMint(uint amount) public payable {
       require(status == Status.PublicSale, "Must in PublicSale status");
        mint(amount);
    }

    function mint(uint amount) private {
        require(amount <= maxPurchase, "Can only mint 3 tokens at a time");
        require(totalSupply().add(amount) <= maxTotalSupply, "Purchase would exceed max supply of island");
        require(_price.mul(amount) <= msg.value, "Ether value sent is not correct");
        uint256 mintedNum = _mintedNum[msg.sender];
        require(maxPurchase >= mintedNum+amount, "minted nft numbers >= max amount");
        if (msg.value > _price * amount) {
            payable(msg.sender).transfer(msg.value - _price * amount);
        }
        mintNumberOfTokens(amount);
    }

    function mintNumberOfTokens(uint numberOfTokens) private{
        uint256 startTokenId = totalSupply();
        _safeMint(msg.sender, numberOfTokens);
        uint256 endTokenId = totalSupply();
        _mintedNum[msg.sender] += uint256(numberOfTokens);
        for (uint j = startTokenId; j < endTokenId; j++){
            ILand(cLand).mint(msg.sender, j);
        }
    }
}