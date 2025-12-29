// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
contract CommunityWallet {
    address owner;
    uint approveThreshold;

    constructor(uint _threshold) {
        owner = msg.sender;//because owner is going to be the one who is deploying the contract not user input
        approveThreshold = _threshold; 
    } 

    uint256 spendingRequestId;// counter used for both mappings
    mapping(address => uint256) addressToBalance;
    struct SpendingRequest {
        string description;
        uint amount;
        address recipient;
        bool isExecuted;
        uint approvalCount;
    }
    mapping(uint256 => SpendingRequest) IdToRequest;

    event Deposit(address indexed user, uint amount);

    event SpendingRequestCreated(
        uint indexed requestId,
        string description,
        uint amount,
        address indexed recipient
    );

    event SpendingRequestApproved(
        uint indexed requestId,
        address indexed approver
    );

    event SpendingRequestExecuted(uint indexed requestId);

    modifier onlyOwner {
        require(msg.sender == owner, "User can't access this function");
        _; //is used to define the end of modifier and beginning of function call written next to it
    }

    function ethDeposit() public payable {
        // now we dont have to override the function using parameter variable like owner or value 
        // because we already have internal variable and they change every time the function is call
        // thats why we dont use owner even though it is assigned as msg.sender in constructor
        require(msg.value != 0, "You have Zero ETH");
        addressToBalance[msg.sender] += msg.value; 

        emit Deposit(msg.sender,msg.value);
    }
    
    function createSpendingRequest(string memory _description, uint _amount, address _recipient) public onlyOwner {
        require (_amount>0 && _recipient != address(0), "Invalid Input");
        // address(0) defines the address starting with zero  like 0000000000000..
        IdToRequest[spendingRequestId] = SpendingRequest({
            description: _description,
            amount: _amount,
            recipient: _recipient,
            isExecuted: false,
            approvalCount: 0
        });

        emit SpendingRequestCreated(
            spendingRequestId,
            _description,
            _amount,
            _recipient
        );

        spendingRequestId ++; 
        //dont need to wait for the approval because 
        //we have to assign id at creation thats why increment it here
    }

    mapping(uint => mapping(address => bool)) requestIdToApprovals; // to store whic user has approve which spending request
    function approveSpendingRequest(uint _spendingRequestId) public {
        require(_spendingRequestId < spendingRequestId, "Id doesn't exist");
        require(addressToBalance[msg.sender] > 0, "insufficient balance");
        require(IdToRequest[_spendingRequestId].isExecuted == false, "request is already executed");
        require(requestIdToApprovals[_spendingRequestId][msg.sender] == false,"you already approved this tx");
        IdToRequest[_spendingRequestId].approvalCount ++;
        requestIdToApprovals[_spendingRequestId][msg.sender] = true;

        emit SpendingRequestApproved(_spendingRequestId, msg.sender);
    }

    function executeSpendingRequest(uint _spendingRequestId) public {
        require(_spendingRequestId < spendingRequestId, "Id doesn't exist");
        require(IdToRequest[_spendingRequestId].isExecuted == false, "request is already executed");
        require(IdToRequest[_spendingRequestId].approvalCount >= approveThreshold, "Not approved yet");
        require(address(this).balance >= IdToRequest[_spendingRequestId].amount, "not enough balance");
        IdToRequest[_spendingRequestId].isExecuted = true;
        (bool success, ) = IdToRequest[_spendingRequestId].recipient.call{value: IdToRequest[_spendingRequestId].amount}("");
        require(success, "ETH transfer failed");

        emit SpendingRequestExecuted(_spendingRequestId);
    }   

}
