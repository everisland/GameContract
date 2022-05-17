// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

pragma experimental ABIEncoderV2;

library Errors {
    string constant invalidNFTId = "Unknown NFT ID";
}

contract EverIslandToolPet is ERC1155, Ownable,Pausable,ReentrancyGuard {
    // We use safemath to avoid under and over flows
    using SafeMath for uint256;
    using Strings for uint256;
    using SafeERC20 for IERC20;

    event EventMint(address indexed to, uint256 id, uint256 data);

    address public materialAddress = 0x7E513eBaD58590888517434FA7CC9eB0AC7f5DB7;

    address public cSigner = 0x1fa4Dd64d1a63812E9Db2a564e06a8a761830645;

    address public cReceiver = 0x1fa4Dd64d1a63812E9Db2a564e06a8a761830645;

    address public tokenAddress = 0x7E513eBaD58590888517434FA7CC9eB0AC7f5DB7;
    
    bytes32 constant public BUILD_CALL_HASH_TYPE = keccak256("mint(address receiver,uint256 type,uint256 amountOfFood,uint256 amountOfWood,uint256 amountOfStone,uint256 amountOfGold,uint256 nonce,uint256 deadline)");
    bytes32 constant public BUILD_CALL_HASH_TYPE2 = keccak256("mint(address receiver,uint256 amountOfFood,uint256 amountOfWood,uint256 amountOfStone,uint256 amountOfGold,uint256 nonce,uint256 deadline)");

    bytes32 public DOMAIN_SEPARATOR;

    uint256 public constant EVERISLAND_NFT_HOE_ID  = 0;
    uint256 public constant EVERISLAND_NFT_AXE_ID  = 1;
    uint256 public constant EVERISLAND_NFT_SHOVEL_ID = 2;
    uint256 public constant EVERISLAND_NFT_HAMMER_ID  = 3;
    uint256 public constant EVERISLAND_NFT_TRACTOR_ID  = 4;
    uint256 public constant EVERISLAND_NFT_SAW_ID  = 5;
    uint256 public constant EVERISLAND_NFT_EXCAVATOR_ID  = 6;
    uint256 public constant EVERISLAND_NFT_MOTOR_ID  = 7;
    uint256 public constant EVERISLAND_NFT_PET_FOOD_ID  = 8;
    uint256 public constant EVERISLAND_NFT_PET_WOOD_ID  = 9;
    uint256 public constant EVERISLAND_NFT_PET_STONE_ID  = 10;
    uint256 public constant EVERISLAND_NFT_PET_GOLD_ID  = 11;
    uint256 public constant EVERISLAND_NFT_PET_ALL_ID  = 12;

    uint256 public petmintprice = 1000000000000000000;

    mapping(address => uint256) public nonces;
    // NFT metadata
    // Base URI
    string private _baseURI = "ipfs://QmNQKJFzuNZB4ubYXca6XxdnQNNCUyc4zQiP9wFSoGKaxL/";

    // ERC1155

    uint256[] private nftsCounter = [uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0),uint256(0)];

    uint256[] private ids = [uint256(0),uint256(1),uint256(2),uint256(3)];

    event EventCheck1(address token, bytes32 digest,uint256 nonce);
    event EventCheck2(address token, bytes32 digest,uint256 nonce);
    event EventCheck3(address token, bytes32 digest,uint256 nonce);

    constructor() Ownable() ERC1155("") public{

    uint chainId;
    assembly {
        chainId := chainid()
    }
    DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
            keccak256(bytes("EverIslandToolPet")),
            keccak256(bytes('1')),
            chainId,
            address(this)
        )
    );
        
    }


    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner{
        _baseURI = baseURI_;
    }

    function changeSigner(address signer) public onlyOwner {
        cSigner = signer;
    }

    function changeReceiver(address receiver) public onlyOwner {
        cReceiver = receiver;
    }

    function changeMaterialContract(address _contract) public onlyOwner {
        materialAddress = _contract;
    }

    function setTokenAddress(address _contract) public onlyOwner {
        tokenAddress = _contract;
    }

    function setPetMintPrice(uint256 price) public onlyOwner {
        petmintprice = price;
    }

    function buildNewTool(
        uint256 _type,
        uint256 _amountOfFood,
        uint256 _amountOfWood,
        uint256 _amountOfStone,
        uint256 _amountOfGold,
        uint256 _deadline,
        uint8 v, bytes32 r, bytes32 s,
        uint256 _data

    ) public  {
        if (_type >= EVERISLAND_NFT_HOE_ID && _type <= EVERISLAND_NFT_PET_ALL_ID) {
            nftsCounter[_type] = nftsCounter[_type].add(1);
        } else {
            revert(Errors.invalidNFTId);
        }
        require(block.timestamp < _deadline, "signed transaction expired");
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", DOMAIN_SEPARATOR,
                keccak256(abi.encode(BUILD_CALL_HASH_TYPE, msg.sender, _type,_amountOfFood,_amountOfWood,_amountOfStone,_amountOfGold,nonces[msg.sender],_deadline))
        ));
        require(ecrecover(digest, v, r, s) == cSigner, "EverIslandTools: Invalid signer");

        if (_amountOfFood!=0||_amountOfWood!=0||_amountOfStone!=0||_amountOfGold!=0){
            uint256[] memory amounts = new uint256[](4);
            amounts[0] = _amountOfFood;
            amounts[1] = _amountOfWood;
            amounts[2] = _amountOfStone;
            amounts[3] = _amountOfGold;

            IERC1155(materialAddress).safeBatchTransferFrom(msg.sender,cReceiver,ids,amounts,"");
        }
        nonces[msg.sender]++;
        _mint(msg.sender, _type, 1, "");

        emit EventMint(msg.sender, _type, _data);
    }

    function pray(
        uint256 _amountOfFood,
        uint256 _amountOfWood,
        uint256 _amountOfStone,
        uint256 _amountOfGold,
        uint256 _deadline,
        uint8 v, bytes32 r, bytes32 s,
        uint256 _data
    ) public  {
        require(block.timestamp < _deadline, "signed transaction expired");
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", DOMAIN_SEPARATOR,
                keccak256(abi.encode(BUILD_CALL_HASH_TYPE2, msg.sender,_amountOfFood,_amountOfWood,_amountOfStone,_amountOfGold,nonces[msg.sender],_deadline))
        ));
        require(ecrecover(digest, v, r, s) == cSigner, "EverIslandToolPet: Invalid signer");

        uint256 typeIndex = randomId(nonces[msg.sender]);
        if (typeIndex>=EVERISLAND_NFT_TRACTOR_ID&&typeIndex<=EVERISLAND_NFT_MOTOR_ID){
            typeIndex = typeIndex - 4;
        }

        nftsCounter[typeIndex] = nftsCounter[typeIndex].add(1);

        nonces[msg.sender]++;

        if (_amountOfFood!=0||_amountOfWood!=0||_amountOfStone!=0||_amountOfGold!=0){
            uint256[] memory amounts = new uint256[](4);
            amounts[0] = _amountOfFood;
            amounts[1] = _amountOfWood;
            amounts[2] = _amountOfStone;
            amounts[3] = _amountOfGold;
            IERC1155(materialAddress).safeBatchTransferFrom(msg.sender,cReceiver,ids,amounts,"");
        }
        _mint(msg.sender, typeIndex, 1, "");

        emit EventMint(msg.sender, typeIndex, _data);

    }

    // mint pet with token
    function mintpet(
    ) public  whenNotPaused notContract{
        IERC20(tokenAddress).safeTransferFrom(msg.sender,address(this), petmintprice);
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp,block.number, nonces[msg.sender], msg.sender))) % 5;
        randomNumber  +=  EVERISLAND_NFT_PET_FOOD_ID;
        nonces[msg.sender]++;
         _mint(msg.sender, randomNumber, 1, "");
         emit EventMint(msg.sender, randomNumber, 0);
    }

    function randomId(uint256 seed) public view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp,block.number, seed, msg.sender))) % (EVERISLAND_NFT_PET_ALL_ID+1);
        return randomNumber;
    }

    function checkDigest(uint256 _type,
        uint256 _amountOfFood,
        uint256 _amountOfWood,
        uint256 _amountOfStone,
        uint256 _amountOfGold) public view returns(bytes32 ,bytes32 ){
        bytes32 digest =  keccak256(abi.encode(BUILD_CALL_HASH_TYPE, msg.sender, _type,_amountOfFood,_amountOfWood,_amountOfStone,_amountOfGold,nonces[msg.sender]));
        bytes32 digestlast = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", DOMAIN_SEPARATOR,digest));
        return (digest,digestlast);
    }

    

    function totalSupplyOfNft(uint256 _type) external view returns (uint256) {
        if (_type >= EVERISLAND_NFT_HOE_ID && _type <= EVERISLAND_NFT_PET_ALL_ID) {
            return nftsCounter[_type]; 
        }
        return 0;
    }
    
    function uri(uint256 _NFTId) public view override returns (string memory)
    {
        if (_NFTId >= EVERISLAND_NFT_HOE_ID && _NFTId <= EVERISLAND_NFT_PET_ALL_ID) {
            return string(abi.encodePacked(_baseURI, _NFTId.toString()));
        }
        return "";
    }

    function withdrawFunds(
        address _tokenAddress,
        uint256 _amount,
        address _wallet
    ) external onlyOwner {
        IERC20(_tokenAddress).transfer(_wallet, _amount);
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function withdrawMaterial() public onlyOwner {
        address[] memory accounts = new address[](4);
        accounts[0] = address(this);
        accounts[1] = address(this);
        accounts[2] = address(this);
        accounts[3] = address(this);

        uint256[] memory amounts = IERC1155(materialAddress).balanceOfBatch(accounts,ids);
        IERC1155(materialAddress).safeBatchTransferFrom(address(this),msg.sender,ids,amounts,"");
    }

    /**
     * @notice Triggers stopped state
     * @dev Only possible when contract not paused.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @notice Returns to normal state
     * @dev Only possible when contract is paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @notice Checks if the msg.sender is a contract or a proxy
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}