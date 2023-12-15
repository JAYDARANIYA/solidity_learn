// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ICOToken is ERC20 {
    constructor() ERC20("ICOToken", "ICO") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}

contract ICOContract is ReentrancyGuard {
    ICOToken public token;
    address public owner;
    uint256 public rate;
    uint256 public start;
    uint256 public end;
    uint256 public minInvestment;
    uint256 public maxInvestment;
    uint256 public hardCap;
    uint256 public fundsRaised;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        uint256 _rate,
        address _tokenAddress,
        uint256 _start,
        uint256 _end,
        uint256 _minInvestment,
        uint256 _maxInvestment,
        uint256 _hardCap
    ) {
        require(_rate > 0, "Rate should be greater than 0");
        require(_tokenAddress != address(0), "Token address cannot be zero");
        require(_start < _end, "Start date must be before end date");
        require(
            _minInvestment < _maxInvestment,
            "Min investment must be less than max investment"
        );
        require(_hardCap > 0, "Hard cap should be greater than 0");

        owner = msg.sender;
        rate = _rate;
        token = ICOToken(_tokenAddress);
        start = _start;
        end = _end;
        minInvestment = _minInvestment;
        maxInvestment = _maxInvestment;
        hardCap = _hardCap;
    }

    function buyTokens() public payable nonReentrant {
        require(
            block.timestamp >= start && block.timestamp <= end,
            "ICO not active"
        );
        require(
            msg.value >= minInvestment && msg.value <= maxInvestment,
            "Investment not in allowed range"
        );
        uint256 investment = msg.value;
        fundsRaised += investment;
        require(fundsRaised <= hardCap, "Hard cap reached");

        uint256 tokenAmount = investment * rate;
        token.transfer(msg.sender, tokenAmount);
    }

    function withdrawFunds() public onlyOwner {
        require(block.timestamp > end, "ICO not finished yet");
        payable(owner).transfer(address(this).balance);
    }

    function emergencyWithdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
