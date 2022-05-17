// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


contract BatchSender is Ownable {
    using SafeMath for uint256;

    event EventTokenBatchSent(address token, uint256 total);
    event EventNFTBatchSent(address token,uint256 id, uint256 total);
    function ethSendSameValue(address payable[] calldata _to, uint _value) internal {

        uint sendAmount = _to.length.mul(_value);
        uint remainingValue = msg.value;

        require(remainingValue >= sendAmount);
        require(_to.length <= 255);

        for (uint8 i = 0; i < _to.length; i++) {
            remainingValue = remainingValue.sub(_value);
            require(_to[i].send(_value));
        }

        emit EventTokenBatchSent(0x000000000000000000000000000000000000bEEF, msg.value);
    }

    function ethSendDifferentValue(address payable[] calldata _to, uint[] calldata _value) internal {

        uint sendAmount = _value[0];
        uint remainingValue = msg.value;

        require(remainingValue >= sendAmount);
        

        require(_to.length == _value.length);
        require(_to.length <= 255);

        for (uint8 i = 0; i < _to.length; i++) {
            remainingValue = remainingValue.sub(_value[i]);
            require(_to[i].send(_value[i]));
        }
        emit EventTokenBatchSent(0x000000000000000000000000000000000000bEEF, msg.value);

    }

    function sendEth(address payable[] calldata _to, uint _value) payable public {
        ethSendSameValue(_to, _value);
    }

    function sendETHWithDifferentValue(address payable[] calldata _to, uint[] calldata _value) payable public {
        ethSendDifferentValue(_to, _value);
    }

    function coinSendSameValue(address _tokenAddress, address[] calldata _to, uint _value) internal {
        
        require(_to.length <= 255);

        address from = msg.sender;
        uint256 sendAmount = _to.length.mul(_value);

        IERC20 token = IERC20(_tokenAddress);
        for (uint8 i = 0; i < _to.length; i++) {
            token.transferFrom(from, _to[i], _value);
        }

        emit EventTokenBatchSent(_tokenAddress, sendAmount);

    }

    function coinSendDifferentValue(address _tokenAddress, address[] calldata _to, uint[] calldata _value) internal {

        require(_to.length == _value.length);
        require(_to.length <= 255);

        uint256 sendAmount = _value[0];
        IERC20 token = IERC20(_tokenAddress);

        for (uint8 i = 0; i < _to.length; i++) {
            token.transferFrom(msg.sender, _to[i], _value[i]);
        }
        emit EventTokenBatchSent(_tokenAddress, sendAmount);

    }

    function sendCoinWithSameValue(address _tokenAddress, address[] calldata _to, uint _value) public {
        coinSendSameValue(_tokenAddress, _to, _value);
    }

    function sendCoinWithDifferentValue(address _tokenAddress, address[] calldata _to, uint[] calldata _value) public {
        coinSendDifferentValue(_tokenAddress, _to, _value);
    }

    function nftSendSameValue(address _tokenAddress, address[] calldata _to, uint _id, uint _value) internal {
        
        require(_to.length <= 255);

        address from = msg.sender;
        uint256 sendAmount = _to.length.mul(_value);

        IERC1155 token = IERC1155(_tokenAddress);
        for (uint8 i = 0; i < _to.length; i++) {
            token.safeTransferFrom(from, _to[i],_id, _value,"");
        }

        emit EventNFTBatchSent(_tokenAddress,_id, sendAmount);

    }

    function nftSendDifferentValue(address _tokenAddress, address[] calldata _to, uint _id,uint[] calldata _value) internal {

        require(_to.length == _value.length);
        require(_to.length <= 255);

        uint256 sendAmount = _value[0];
        IERC1155 token = IERC1155(_tokenAddress);

        for (uint8 i = 0; i < _to.length; i++) {
            token.safeTransferFrom(msg.sender, _to[i],_id, _value[i],"");
        }
        emit EventNFTBatchSent(_tokenAddress,_id, sendAmount);

    }

    function nftSendDifferentIdValue(address _tokenAddress, address[] calldata _to, uint[] calldata _id,uint[] calldata _value) internal {

        require(_to.length == _value.length);
        require(_to.length == _id.length);
        require(_to.length <= 255);

        uint256 sendAmount = _value[0];
        uint256 sendId = _id[0];
        IERC1155 token = IERC1155(_tokenAddress);

        for (uint8 i = 0; i < _to.length; i++) {
            token.safeTransferFrom(msg.sender, _to[i],_id[i], _value[i],"");
        }
        emit EventNFTBatchSent(_tokenAddress,sendId, sendAmount);
    }


    function sendNftWithSameValue(address _tokenAddress, address[] calldata _to, uint _id,uint _value) public {
        nftSendSameValue(_tokenAddress, _to,_id, _value);
    }

    function sendnFTWithDifferentValue(address _tokenAddress, address[] calldata _to, uint _id,uint[] calldata _value) public {
        nftSendDifferentValue(_tokenAddress, _to,_id, _value);
    }

    function sendnFTWithDifferentIdValue(address _tokenAddress, address[] calldata _to, uint[] calldata _id,uint[] calldata _value) public {
        nftSendDifferentIdValue(_tokenAddress, _to,_id, _value);
    }
}