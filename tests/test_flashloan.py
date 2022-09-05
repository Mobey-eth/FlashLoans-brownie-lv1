import brownie
from brownie import accounts, MobiToken, FlashLoan, FlashLoanReciever, web3


def test_flash_loan():
    deployer = accounts[0]
    borrower = accounts[1]
    initial_amount = web3.toWei(1000000, "ether")

    # To deploy the token and mint to an address
    print("Testing ; To deploy the token and mint to an address...")
    token = MobiToken.deploy(initial_amount, {"from": deployer})
    print(
        "Deployer Token balance is: ",
        web3.fromWei(token.balanceOf(deployer.address), "ether"),
        token.symbol(),
    )
    assert token.balanceOf(deployer.address) == initial_amount
    print("Tests passed!")

    # To deploy the FlashLoan, approve and deposit tokens to flashloan contract
    print(
        "Testing ; To deploy the FlashLoan, approve and deposit tokens to flashloan contract..."
    )
    flash_loan = FlashLoan.deploy(token.address, {"from": deployer})
    token.approve(flash_loan.address, initial_amount, {"from": deployer})
    tx = flash_loan.depositTokens(deployer.address, initial_amount, {"from": deployer})
    tx.wait(1)

    assert token.balanceOf(flash_loan.address) == initial_amount
    print(
        "FlashLoan Pool balance is : ",
        web3.fromWei(flash_loan.poolBalance(), "ether"),
        token.symbol(),
    )
    print("Tests passed!")

    return borrower, initial_amount, token, flash_loan


def test_flashLoanReciever():
    (borrower, initial_amount, token, flash_loan) = test_flash_loan()
    borrow_amount = web3.toWei(100, "ether")
    flash_loan_reciever = FlashLoanReciever.deploy(
        flash_loan.address, {"from": borrower}
    )
    tx = flash_loan_reciever.executeFlashLoan(borrow_amount, {"from": borrower})
    print(
        "fl reciever Token balance is: ",
        web3.fromWei(token.balanceOf(flash_loan_reciever.address), "ether"),
    )
    print(
        "FlashLoan Pool balance is : ", web3.fromWei(flash_loan.poolBalance(), "ether")
    )
    tx.info()
    # print(tx.events["loanRecieved"])
    print("FlashLoan Successfully Repaid! ")
