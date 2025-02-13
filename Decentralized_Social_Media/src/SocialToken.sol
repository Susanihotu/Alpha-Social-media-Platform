// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract SocialToken is ERC20 {
    address public owner;

    constructor() ERC20("SocialToken", "SCT") {
        owner = msg.sender;
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
