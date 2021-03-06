pragma solidity ^0.5.2;

// File: contracts/lib/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        /// @dev This has been modified to accommodate a factory implementation msg.sender -> tx.origin
        // solhint-disable-next-line
        _owner = tx.origin;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/lib/Entity.sol

/// @title Entity
/// @dev The entity contract that the base contracts from the Instant Clearing and Settlement Ecosystem inherit
contract Entity is Ownable {

    enum EntityType{
        BROKER,
        CUSTODIAN,
        EXCHANGE
    }

    // @dev This is used to identity which type of entity the corresponding contract represents
    EntityType public _typeOfEntity;
    // @dev Name of the entity
    bytes32 public _name;
    // @dev Version of the contracts
    uint256 public _version;

    /// @dev Constructor of the Entity
    /// @param name Name of the entity
    /// @param version Version of the contracts being deployed
    constructor(bytes32 name, uint256 version) public {
        _name = name;
        _version = version;
    }
}

// File: contracts/Exchange.sol

/// @title Exchange
/// @dev The base contract for an Exchange entity to utilize the Instant Clearing and Settlement Ecosystem
contract Exchange is Entity {

    /// @dev An event emitted when a trade has been executed
    event Trade(
        uint256 transactionID,
        uint256 timeStamp,
        address buyInvestor,
        address buyBroker,
        address sellInvestor,
        address sellBroker,
        uint256 amount,
        uint256 asset
    );

    /// @dev Constructor of the Entity
    /// @param name Name of the entity
    /// @param version Version of the contracts being deployed
    constructor(
        bytes32 name,
        uint256 version
    )
    Entity(
        name,
        version
    )
        public
    {
        _typeOfEntity = EntityType.EXCHANGE;
    }

    /// @dev Allows the owner of the contract to emit a Trade event
    /// This will update the internal ledger of this contract
    /// Requires:
    ///     - msg.sender is the owner
    /// @param transactionID A unique transaction ID issues by the exchange that allows the custodian to verify a trade
    /// This serves as a nonce to ensure trades are verified in the correct order
    /// @param timeStamp TimeStamp of the trade being entered
    /// @param buyInvestor Indicates the Buyers Investor ID
    /// @param buyBroker Indicates the Buyers Broker ID
    /// @param sellInvestor Indicates the Sellers Investor ID
    /// @param sellBroker Indicates the Sellers Broker ID
    /// @param amount Amount of the asset being bought
    /// @param asset Corresponding asset ID
    function enterTrade(
        uint256 transactionID,
        uint256 timeStamp,
        address buyInvestor,
        address buyBroker,
        address sellInvestor,
        address sellBroker,
        uint256 amount,
        uint256 asset
    )
        external
        onlyOwner
    {
        /// !!! Insert functionality to actually edit balances

        emit Trade(
            transactionID,
            timeStamp,
            buyInvestor,
            buyBroker,
            sellInvestor,
            sellBroker,
            amount,
            asset
        );
    }
}
