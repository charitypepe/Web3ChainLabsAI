// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract W3LABSPreSale is Ownable {
    IERC20 public token;
    uint256 public rate = 35000000; // 1 ETH = 35,000,000 $W3LABS
    uint256 public startTime;
    uint256 public endTime;
    uint256 public maxPurchase = 5 ether; // Максимална покупка (5 ETH)

    mapping(address => uint256) public contributions;

    event TokensPurchased(address indexed buyer, uint256 amountETH, uint256 tokensReceived);

    constructor(IERC20 _token, uint256 _duration) {
        token = _token;
        startTime = block.timestamp;
        endTime = block.timestamp + _duration; // Продължителност на Pre-sale (3 месеца)
    }

    function buyTokens() public payable {
        require(block.timestamp >= startTime, "Pre-sale has not started");
        require(block.timestamp <= endTime, "Pre-sale has ended");
        require(contributions[msg.sender] + msg.value <= maxPurchase, "Exceeds max purchase limit");

        uint256 tokensToReceive = msg.value * rate;
        require(token.balanceOf(address(this)) >= tokensToReceive, "Not enough tokens in contract");

        contributions[msg.sender] += msg.value;
        token.transfer(msg.sender, tokensToReceive);

        emit TokensPurchased(msg.sender, msg.value, tokensToReceive);
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawUnsoldTokens() external onlyOwner {
        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function extendPreSale(uint256 additionalTime) external onlyOwner {
        endTime += additionalTime;
    }
}
