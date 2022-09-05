// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MobiToken is ERC20 {
    uint256 public initialAmount;
    address public owner;

    constructor(uint256 _amount) ERC20("MobiToken", "MBY") {
        owner = msg.sender;
        initialAmount = _amount;
        _mint(msg.sender, initialAmount);
    }

    function mintMore(address _toAddress, uint256 _amount) public {
        require(msg.sender == owner, "Only Owner can call this fxn!");
        _mint(_toAddress, _amount);
    }
}
