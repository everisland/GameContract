// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Base64.sol";

pragma experimental ABIEncoderV2;

library Errors {
    string constant invalidMaterialId = "Unknown Material NFT ID";
}

contract EverIslandMaterial is ERC1155, Ownable,ReentrancyGuard {
    // We use safemath to avoid under and over flows
    using SafeMath for uint256;

    uint256 public constant EVERISLAND_NFT_FOOD_ID  = 0;
    uint256 public constant EVERISLAND_NFT_WOOD_ID  = 1;
    uint256 public constant EVERISLAND_NFT_STONE_ID = 2;
    uint256 public constant EVERISLAND_NFT_GOLD_ID  = 3;

    // NFT metadata
    mapping(uint256 => string) private tokenURIs;
    mapping(uint256 => string) private everIslandNFTDescriptions;

    //Initialisation
    bool private contractInitialized;

    // ERC1155
    uint256 private issuedFoodCounter = 0;
    uint256 private issuedWoodCounter = 0;
    uint256 private issuedStoneCounter = 0;
    uint256 private issuedGoldCounter = 0;

    constructor() Ownable() ERC1155("EverIsland-Materials") public{

        tokenURIs[
            EVERISLAND_NFT_FOOD_ID
        ] = "ipfs://QmNN3SXURhxg8N4NPUnHTz5XchP1vsz7L2zCEYu1ggfBWa";
        tokenURIs[
            EVERISLAND_NFT_WOOD_ID
        ] = "ipfs://QmXvSepCqtAusyG8rVfSajFh6xZwCnETxcf4JEpzjLtGCB";
        tokenURIs[
            EVERISLAND_NFT_STONE_ID
        ] = "ipfs://QmQDQFTGuHV1rqhBkbQSZ6ao1V4mGtKSCXRKATFEwrKqKR";
        tokenURIs[
            EVERISLAND_NFT_GOLD_ID
        ] = "ipfs://QmXtpxgoUvRHaRqRk486bpj5zy8wuZh5esKm9NWogfL2so";
        everIslandNFTDescriptions[EVERISLAND_NFT_FOOD_ID] = "EverIsland Food";
        everIslandNFTDescriptions[EVERISLAND_NFT_WOOD_ID] = "EverIsland Wood";
        everIslandNFTDescriptions[EVERISLAND_NFT_STONE_ID] = "EverIsland Stone";
        everIslandNFTDescriptions[EVERISLAND_NFT_GOLD_ID] = "EverIsland Gold";
        //contractInitialized = false;
    }

    function initialEverIsland() external onlyOwner {
        require(contractInitialized == false, "contract initialized already");
        issueNewMaterials(msg.sender, EVERISLAND_NFT_FOOD_ID, 100000000);
        issueNewMaterials(msg.sender, EVERISLAND_NFT_WOOD_ID, 100000000);
        issueNewMaterials(msg.sender, EVERISLAND_NFT_STONE_ID, 100000000);
        issueNewMaterials(msg.sender, EVERISLAND_NFT_GOLD_ID, 100000000);
        contractInitialized = true;
    }


    function issueNewMaterials(
        address _to,
        uint256 _type,
        uint256 _amount
    ) public onlyOwner {
        if (_type == EVERISLAND_NFT_FOOD_ID) {
            issuedFoodCounter = issuedFoodCounter.add(
                _amount
            );
        } else if (_type == EVERISLAND_NFT_WOOD_ID) {
            issuedWoodCounter = issuedWoodCounter.add(
                _amount
            );
        } else if (_type == EVERISLAND_NFT_STONE_ID) {
            issuedStoneCounter = issuedStoneCounter.add(
                _amount
            );
        } else if (_type == EVERISLAND_NFT_GOLD_ID) {
            issuedGoldCounter = issuedGoldCounter.add(
                _amount
            );
        } else {
            revert(Errors.invalidMaterialId);
        }
        _mint(_to, _type, _amount, "");
    }

    function totalSupplyOfFood() external view returns (uint256) {
        return issuedFoodCounter;
    }

    function totalSupplyOfWood() external view returns (uint256) {
        return issuedWoodCounter;
    }

    function totalSupplyOfStone() external view returns (uint256) {
        return issuedStoneCounter;
    }

    function totalSupplyOfGold() external view returns (uint256) {
        return issuedGoldCounter;
    }
    
    function uri(uint256 _materialNFTId) public view override returns (string memory)
    {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "',
                        everIslandNFTDescriptions[_materialNFTId],
                        '", ',
                        '"description" : ',
                        '"A material of EverIsland.",',
                        '"image": "',
                        tokenURIs[_materialNFTId],
                        '"'
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function changeURIs(
        string[] calldata _tokenURIs,
        uint256[] calldata _materialNFTId
    ) external onlyOwner {
        for (uint256 i = 0; i < _tokenURIs.length; i++) {
            tokenURIs[_materialNFTId[i]] = _tokenURIs[i];
        }
    }

    function withdrawFunds(
        address tokenAddress,
        uint256 amount,
        address wallet
    ) external onlyOwner {
        IERC20(tokenAddress).transfer(wallet, amount);
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }
}