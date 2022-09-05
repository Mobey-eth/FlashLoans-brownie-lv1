// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MobiToken.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// using safeMath?
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IFLReciever {
    function recieveTokens(address _tokenAddress, uint256 _returnAmount)
        external;
}

contract FlashLoan is ReentrancyGuard {
    // using SafeMath for uint256;
    MobiToken public token;
    uint256 public poolBalance;

    constructor(address _tokenAddress) {
        // what if I create another ERC20 token and pass the address here??
        token = MobiToken(_tokenAddress);
    }

    function depositTokens(address _deployer, uint256 _amount)
        external
        nonReentrant
    {
        require(_amount > 0, "Must deposit atleast one token...");
        token.transferFrom(_deployer, address(this), _amount);
        // poolBalance = poolBalance.add(_amount);
        poolBalance += _amount;
    }

    /*
    Flash Loan logic
     - Send tokens to reciever
     - Get Tokens paid back
      - function on FL contract calls another fxn on FLR contract
        (some sort of call back fxn...)
     - Ensure Tokens are paid back
    */

    function flashLoan(address _address, uint256 _borrowAmount)
        external
        nonReentrant
    {
        require(_borrowAmount > 0, "Must borrow at least one token...");
        require(
            poolBalance > _borrowAmount,
            "You have exceeded the no of tokens in pool!"
        );
        uint256 balanceBefore = token.balanceOf(address(this));
        // token.transfer(msg.sender, _borrowAmount);
        token.transfer(_address, _borrowAmount);
        poolBalance -= _borrowAmount;

        // Use loan, get tokens paid back

        IFLReciever(_address).recieveTokens(address(token), _borrowAmount);
        uint256 balanceAfter = token.balanceOf(address(this));
        poolBalance += _borrowAmount;
        // Ensure Loan is paid Back...
        require(balanceAfter >= balanceBefore, "FlashLoan Hasn't been repaid!");
    }
}
