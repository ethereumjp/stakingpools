// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

interface IDepositContract {
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;
}

contract StakingPool {
    mapping(address => uint) public balances;
    address payable public admin;
    uint public end;
    bool public finalized;
    uint public totalInvested;
    uint public totalChange;
    mapping(address => bool) public investorChangeClaimed;
    mapping(bytes => bool) public pubkeysUsed;
    IDepositContract public depositContract = IDepositContract(0x00000000219ab540356cBB839Cbe05303d7705Fa);

    event NewInvestor (
        address investor
    );

    constructor(){
        admin = payable(msg.sender);
        end = block.timestamp + 7 days;
    }

    function invest() external payable {
        require(block.timestamp < end, "Error: Staking period has ended");
        if(balances[msg.sender] == 0){
            emit NewInvestor(msg.sender);
        }
        uint fee = msg.value / 100;
        uint investAmount = msg.value - fee;
        admin.transfer(fee);

        balances[msg.sender] += investAmount;
    }

    function finalize() external {
        require(block.timestamp >= end, "Error: Staking period has not ended");
        require(finalized == false, "Error: Staking has already been finalized");
        finalized = true;
        totalInvested = address(this).balance;
        totalChange = totalInvested % 32 ether;


        payable(admin).transfer(address(this).balance);
    }

    function claimChange() external {
        require(finalized == true, "Error: Staking has not been finalized");
        require(balances[msg.sender] > 0, "Error: Investor has no balance");
        require(investorChangeClaimed[msg.sender] == false, "Error: Investor has already claimed change");
        investorChangeClaimed[msg.sender] = true;
        uint claimAmount = balances[msg.sender] * totalChange / totalInvested;
        payable(msg.sender).transfer(claimAmount);
    }

    function deposit(
        bytes calldata pubkey, // make it into array for multiple deposits (above 32 eth)
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external {
        ///// validation START /////
        require(finalized == true, "Error: Staking has not been finalized");
        require(msg.sender == admin, "Error: Only admin can call this function");
        require(address(this).balance >= 32 ether, "Error: Not enough funds to deposit");
        require(pubkeysUsed[pubkey] == false, "Error: Pubkey has already been used");
        ///// validation END /////

        ///// update state START /////
        pubkeysUsed[pubkey] = true;
        ///// update state END /////


        depositContract.deposit{value: 32 ether}(
            pubkey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );
    }
}
