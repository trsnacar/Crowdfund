// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
// npm install @openzeppelin/contracts
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";


// Replace "MyToken" with the name of your ERC20 token
contract MyToken is SafeERC20 {
    using SafeMath for uint256;

    constructor() public {
        // Initialize your token contract here
    }

    // Add other functions and variables as needed for your token contract
}

// Crowdfund contract
contract Crowdfund {
    // Address of the token contract
    MyToken private token;

    // Campaign information
    address private campaignCreator;
    uint256 private campaignGoal;
    uint256 private campaignEndTime;

    // Pledges made to the campaign
    mapping(address => uint256) private pledges;
    uint256 private totalPledges;

    constructor(MyToken _token, address _campaignCreator, uint256 _campaignGoal, uint256 _campaignEndTime) public {
        require(_token.balanceOf(_campaignCreator) > 0, "Campaign creator must have at least 1 token to create a campaign");
        require(_campaignGoal > 0, "Campaign goal must be greater than 0");
        require(_campaignEndTime > now, "Campaign end time must be in the future");

        token = _token;
        campaignCreator = _campaignCreator;
        campaignGoal = _campaignGoal;
        campaignEndTime = _campaignEndTime;
    }

    function makePledge(uint256 amount) public payable {
        require(now <= campaignEndTime, "Campaign has already ended");
        require(amount > 0, "Pledge amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Insufficient balance or allowance");

        pledges[msg.sender] = pledges[msg.sender].add(amount);
        totalPledges = totalPledges.add(amount);
    }

    function claimFunds() public {
        require(now > campaignEndTime, "Campaign has not yet ended");
        require(totalPledges >= campaignGoal, "Campaign goal has not been reached");
        require(msg.sender == campaignCreator, "Only the campaign creator can claim the funds");

        campaignCreator.transfer(totalPledges);
    }

    function withdrawPledge(uint256 amount) public {
        require(now > campaignEndTime, "Campaign has not yet ended");
        require(totalPledges < campaignGoal, "Campaign goal has been reached, funds have been claimed");
        require(amount > 0 && amount <= pledges[msg.sender], "Invalid pledge amount");

        token.transfer(msg.sender, amount);
        pledges[msg.sender] = pledges[msg.sender].sub(amount);
        totalPledges = totalPledges.sub(amount);
    }
}
