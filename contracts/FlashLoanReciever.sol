// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MobiToken.sol";
import "./FlashLoan.sol";

contract FlashLoanReciever {
    FlashLoan private pool;
    address public owner;

    event loanRecieved(address _token, uint256 _amount);

    constructor(address _poolAddress) {
        pool = FlashLoan(_poolAddress);
        owner = msg.sender;
    }

    function recieveTokens(address _tokenAddress, uint256 _returnAmount)
        external
    {
        require(
            msg.sender == address(pool),
            "Only Flashloan pool can call this fxn"
        );

        emit loanRecieved(_tokenAddress, _returnAmount);

        // execute a trading logic...
        // return funds to pool
        require(
            MobiToken(_tokenAddress).transfer(msg.sender, _returnAmount),
            "Transfer of Tokens failed!"
        );
    }

    function executeFlashLoan(uint256 _borrowAmount) external {
        require(msg.sender == owner, "Only Owner can call this fxn!");
        pool.flashLoan(address(this), _borrowAmount);
    }
}
