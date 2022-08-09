// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "./Ownable.sol";


contract GasContract is Ownable {
    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter = 0;
    mapping(address => uint256) public balances;
    address public contractOwner;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;



    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }
    //PaymentType defaultPayment = PaymentType.Unknown;

    // History[] public paymentHistory; // when a payment was updated

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
        uint256 amount;
    }

    // struct History {
    //     uint256 lastUpdate;
    //     address updatedBy;
    //     uint256 blockNumber;
    // }

    uint256 wasLastOdd = 1;
    mapping(address => uint256) public isOddWhitelistUser;
    struct ImportantStruct {
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
    }

    mapping(address => ImportantStruct) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    modifier onlyAdminOrOwner() {
        //address senderOfTx = msg.sender;
        if (checkForAdmin(msg.sender)) {
    
            _;
        // } else if (msg.sender == contractOwner) {
        //     _;
        } else {
            revert(
                "Must be admin"
            );
        }
    }

    modifier checkIfWhiteListed(address sender) {
        //address senderOfTx = msg.sender;
        // require(
        //     senderOfTx == sender,
        //     "Must be sender"
        // );
        uint256 usersTier = whitelist[msg.sender];
        // require(
        //     usersTier > 0,
        //     "user must be whitelisted"
        // );
        // require(
        //     usersTier < 4,
        //     "tier is incorrect"
        // );
         _;
    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        string recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                if (_admins[ii] == contractOwner) {
                    balances[contractOwner] = _totalSupply; //track balance of 
            //     } else {
            //         balances[_admins[ii]] = 0;
            //     }
            //     if (_admins[ii] == contractOwner) {
            //         emit supplyChanged(_admins[ii], _totalSupply);
            //     } else if (_admins[ii] != contractOwner) {
            //         emit supplyChanged(_admins[ii], 0);
            //    }
                }
            }
        }
    }

    // function getPaymentHistory()
    //     public
    //     payable
    //     returns (History[] memory paymentHistory_)
    // {
    //     return paymentHistory;
    // }

    function checkForAdmin(address _user) public view returns (bool) {
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                return true;
            }
        }
        return false;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function getTradingMode() public pure returns (bool mode_) {
        return true;
    }

    // function addHistory(address _updateAddress, bool _tradeMode)
    //     public
    //     returns (bool status_, bool tradeMode_)
    // {
    //     History memory history;
    //     history.blockNumber = block.number;
    //     history.lastUpdate = block.timestamp;
    //     history.updatedBy = _updateAddress;
    //     paymentHistory.push(history);
    //     bool[] memory status = new bool[](tradePercent);
    //     for (uint256 i = 0; i < tradePercent; i++) {
    //         status[i] = true;
    //     }
    //     return ((status[0] == true), _tradeMode);
    // }

    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        // require(
        //     _user != address(0),
        //     "User must have a valid non zero address"
        // );
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool) {
        //address senderOfTx = msg.sender;
        require(
            balances[msg.sender] >= _amount,
            "Insufficient balance"
        );
        // require(
        //     bytes(_name).length < 9,
        //     "max length of 8 characters"
        // );
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        //payment.admin = address(0);
        //payment.adminUpdated = false;

        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        //payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        payments[msg.sender].push(payment);
        //bool[] memory status = new bool[];
        // for (uint256 i = 0; i < 2; i++) {
        //     status[i] = true;
        // }
        //return (status_[0] == true);
        return true;
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) public onlyAdminOrOwner {
        require(
            _ID > 0,
            "ID must be greater than 0"
        );
        // require(
        //     _amount > 0,
        //     "Amount must be greater than 0"
        // );
        // require(
        //     _user != address(0),
        //     "Address"
        // );

        //address senderOfTx = msg.sender;

        for (uint256 ii = 0; ii < payments[_user].length; ii++) {
            if (payments[_user][ii].paymentID == _ID) {
                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
                getTradingMode();
                //addHistory(_user, tradingMode);
                // emit PaymentUpdated(
                //     senderOfTx,
                //     _ID,
                //     _amount,
                //     payments[_user][ii].recipientName
                // );
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
    {

        whitelist[_userAddrs] = _tier;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        ImportantStruct memory _struct
    ) external checkIfWhiteListed(msg.sender) {
        require(
            balances[msg.sender] >= _amount,
            "Sender has insufficient Balance"
        );
       
        balances[msg.sender] = balances[msg.sender] - _amount + whitelist[msg.sender];
        balances[_recipient] = balances[_recipient] + _amount - whitelist[msg.sender];

        ImportantStruct storage newImportantStruct = whiteListStruct[
            msg.sender
        ];
        newImportantStruct.valueA = _struct.valueA;
        newImportantStruct.bigValue = _struct.bigValue;
        newImportantStruct.valueB = _struct.valueB;
        emit WhiteListTransfer(_recipient);
    }
}




