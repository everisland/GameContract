// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./ERC721A.sol";
import "./Base64.sol";

contract Everland is ERC721A, Ownable {
    using SafeMath for uint256;

    uint256 public  constant MAX_ISLAND = 1000;
    string private _uri;


    address public cOperator = 0xab521122331412E21592EB048F9F86e045507A91;

    string private _imageuri = "ipfs://QmNN3SXURhxg8N4NPUnHTz5XchP1vsz7L2zCEYu1ggfBWa";

    mapping(uint256 => uint256) private _landOfIsland;


    constructor() ERC721A("Land Of EverIsland", "Everland", 20) public {

    }

    function changeOperator(address operator) public onlyOwner {
        cOperator = operator;
    }

    function setImageUri(string memory uri) public onlyOwner {
        _imageuri = uri;
    }

    function _baseURI() internal view  override(ERC721A) returns (string memory) {
        return _uri;
    }

    function setURI(string memory newuri) public virtual onlyOwner{
        _uri = newuri;
    }


    function mint(address to,uint256 island) public {
        require(cOperator == _msgSender(), "Operator not match");
        uint256 startTokenId = totalSupply();
        _safeMint(to, 20);
        uint256 endTokenId = totalSupply();
        for (uint i = startTokenId; i < endTokenId; i++){
            _landOfIsland[i] = island;
        }
    }

    function island(uint256 tokenId)
    public
    view
    returns (uint id){
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _landOfIsland[tokenId];
    }

    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
        bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : uri(tokenId);
    }

    function uri(uint256 tokenId) private view returns (string memory)
    {
        uint256 islandId = _landOfIsland[tokenId];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name" : ',
                        '"Everland",',
                        '"description" : ',
                        '"Land of EverIsland",',
                        '"image": "',
                        _imageuri,
                        '",',
                        '"attributes":[{"trait_type":"Island","value":"',
                        islandId.toString(),
                        '"}]',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
    
}