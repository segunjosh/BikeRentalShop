//SPDX-License-Identifier: <UNLICENSED>

pragma solidity 0.7.4;

import "./Loan.sol";

contract LoanFactory {
    address public owner;
    address public pendingOwner;
    address public admin;
    Loan[] public loans;

    event AccessChanged (
        string access,
        address previous,
        address current
    );

    /*
     * Event names follow the pattern `resource`-`action`.
     */
    event LoanCreated (
        address loanAddress,
        string id,
        uint256 seq
    );

    /*
     * Grace period after a payment instruction, in seconds
     */
    event LoanTimeChanged (
        bytes32 leadTimeType, //can be for margin, interest or principal repayment
        uint256 leadTime,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    constructor() public {
        owner = msg.sender;
        admin = msg.sender;
    }

    /*
     * @dev Create new loan some variables were commented out
     * because we hit the stack size limit of the EVM
     * We might have to compress several array element into one
     * to solve the issue
     */
    function createLoan(string memory id, string memory loanMeta)
        external
        onlyAdmin
    {
        loans.push(new Loan(id, loanMeta));
        emit LoanCreated(
            loans[loans.length - 1],
            id,
            loans.length
        );
    }

    function changeOwner(address _pendingOwner)
        external
        onlyOwner
    {
        emit AccessChanged("pendingOwner", pendingOwner, _pendingOwner);
        pendingOwner = _pendingOwner;
    }

    function acceptOwner()
        external
    {
        require(msg.sender == pendingOwner);
        emit AccessChanged("owner", owner, pendingOwner);
        emit AccessChanged("pendingOwner", pendingOwner, 0x0);
        owner = pendingOwner;
        pendingOwner = 0x0;
    }

    function changeAdmin(address _admin)
        external
        onlyOwner
    {
        emit AccessChanged("admin", admin, _admin);
        admin = _admin;
    }

    function changeLoantime(bytes32 leadTimeType, uint256 leadTime, uint256 timestamp)
        external
        onlyAdmin
    {
        emit LoanTimeChanged(
            leadTimeType,
            leadTime,
            timestamp
        );
    }

    fallback() external {
        revert();
    }
}
