// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 ^0.8.22;

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

// lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

// lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(
        address spender,
        uint256 value
    ) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(
        address spender,
        uint256 value,
        bytes calldata data
    ) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.2.0) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 requestedDecrease
    );

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeCall(token.transferFrom, (from, to, value))
        );
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 requestedDecrease
    ) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(
                    spender,
                    currentAllowance,
                    requestedDecrease
                );
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeCall(
            token.approve,
            (spender, value)
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeCall(token.approve, (spender, 0))
            );
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(
        IERC1363 token,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(
        IERC1363 token,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(
                gas(),
                token,
                0,
                add(data, 0x20),
                mload(data),
                0,
                0x20
            )
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (
            returnSize == 0 ? address(token).code.length == 0 : returnValue != 1
        ) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(
        IERC20 token,
        bytes memory data
    ) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(
                gas(),
                token,
                0,
                add(data, 0x20),
                mload(data),
                0,
                0x20
            )
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return
            success &&
            (
                returnSize == 0
                    ? address(token).code.length > 0
                    : returnValue == 1
            );
    }
}

// src/EaglesLevelSystem.sol

// Custom errors for gas optimizations
error OnlyContractOwner();
error OnlyUnlocked();
error UserDoesNotExist();
error InvalidMatrix();
error InvalidLevel();
error BuyPreviousLevelFirst();
error LevelAlreadyActivated();
error UserExists();
error ReferrerDoesNotExist();

// Library to handle X1 and X2 matrix logic
library MatrixLib {
    struct X1 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }

    struct X2 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;
        address closedPart;
    }

    function updateX1Referrer(
        X1 storage x1,
        address userAddress,
        address referrerAddress,
        uint8 level,
        uint8 LAST_LEVEL,
        address id1,
        function(address, address, uint8, uint8) internal emitNewUserPlace,
        function(address, address, uint8, uint8) internal sendDividends
    ) internal {
        x1.referrals.push(userAddress);

        if (x1.referrals.length < 3) {
            emitNewUserPlace(userAddress, referrerAddress, 1, level);
            sendDividends(referrerAddress, userAddress, 1, level);
            return;
        }

        emitNewUserPlace(userAddress, referrerAddress, 1, level);
        x1.referrals = new address[](0);

        if (!x1.blocked && level != LAST_LEVEL) {
            x1.blocked = true;
        }

        if (referrerAddress != id1) {
            x1.reinvestCount++;
            emitNewUserPlace(referrerAddress, x1.currentReferrer, 1, level);
            sendDividends(referrerAddress, userAddress, 1, level);
        } else {
            sendDividends(id1, userAddress, 1, level);
            x1.reinvestCount++;
        }
    }

    function updateX2Referrer(
        X2 storage x2,
        address userAddress,
        address referrerAddress,
        uint8 level,
        uint8 LAST_LEVEL,
        address id1,
        function(address, address, uint8, uint8) internal emitNewUserPlace,
        function(address, address, uint8, uint8) internal sendDividends
    ) internal {
        if (x2.firstLevelReferrals.length < 2) {
            x2.firstLevelReferrals.push(userAddress);
            emitNewUserPlace(userAddress, referrerAddress, 2, level);
            sendDividends(referrerAddress, userAddress, 2, level);
            return;
        }

        x2.secondLevelReferrals.push(userAddress);

        if (x2.closedPart != address(0)) {
            if (
                x2.firstLevelReferrals[0] == x2.closedPart ||
                x2.firstLevelReferrals[1] == x2.closedPart
            ) {
                x2.blocked = true;
            }
        }

        x2.firstLevelReferrals = new address[](0);
        x2.secondLevelReferrals = new address[](0);
        x2.closedPart = address(0);

        if (!x2.blocked && level != LAST_LEVEL) {
            x2.blocked = true;
        }

        x2.reinvestCount++;

        if (referrerAddress != id1) {
            emitNewUserPlace(referrerAddress, x2.currentReferrer, 2, level);
            sendDividends(referrerAddress, userAddress, 2, level);
        } else {
            sendDividends(id1, userAddress, 2, level);
        }
    }
}

contract SmartMatrixEagleBasic {
    using SafeERC20 for IERC20;
    using MatrixLib for MatrixLib.X1;
    using MatrixLib for MatrixLib.X2;

    address public contractOwner;

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        mapping(uint8 => bool) activeX1Levels;
        mapping(uint8 => bool) activeX2Levels;
        mapping(uint8 => MatrixLib.X1) x1Matrix;
        mapping(uint8 => MatrixLib.X2) x2Matrix;
    }

    uint8 public constant LAST_LEVEL = 12;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances;

    uint public lastUserId;
    address public id1;

    mapping(uint8 => uint) public levelPrice;

    IERC20 public depositToken;

    uint public constant BASIC_PRICE = 5e18;

    bool public locked;

    event Registration(
        address indexed user,
        address indexed referrer,
        uint indexed userId,
        uint referrerId
    );
    event Reinvest(
        address indexed user,
        address indexed currentReferrer,
        address indexed caller,
        uint8 matrix,
        uint8 level
    );
    event Upgrade(
        address indexed user,
        address indexed referrer,
        uint8 matrix,
        uint8 level
    );
    event NewUserPlace(
        address indexed user,
        address indexed referrer,
        uint8 matrix,
        uint8 level,
        uint8 place
    );
    event MissedEthReceive(
        address indexed receiver,
        address indexed from,
        uint8 matrix,
        uint8 level
    );
    event SentExtraEthDividends(
        address indexed from,
        address indexed receiver,
        uint8 matrix,
        uint8 level
    );

    modifier onlyContractOwner() {
        if (msg.sender != contractOwner) revert OnlyContractOwner();
        _;
    }

    modifier onlyUnlocked() {
        if (locked && msg.sender != contractOwner) revert OnlyUnlocked();
        _;
    }

    constructor(IERC20 _depositTokenAddress) {
        contractOwner = msg.sender;
        levelPrice[1] = BASIC_PRICE;
        for (uint8 i = 2; i <= 8; i++) {
            levelPrice[i] = levelPrice[i - 1] * 2;
        }
        levelPrice[9] = 1250e18;
        levelPrice[10] = 2500e18;
        levelPrice[11] = 5000e18;
        levelPrice[12] = 9900e18;

        id1 = msg.sender;
        users[msg.sender].id = 1;
        users[msg.sender].referrer = address(0);
        users[msg.sender].partnersCount = 0;
        idToAddress[1] = msg.sender;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[msg.sender].activeX1Levels[i] = true;
            users[msg.sender].activeX2Levels[i] = true;
        }

        userIds[1] = msg.sender;
        lastUserId = 2;

        depositToken = _depositTokenAddress;
        locked = true;
    }

    function changeLock() external onlyContractOwner {
        locked = !locked;
    }

    receive() external payable {
        registration(msg.sender, id1);
    }

    fallback() external payable {
        registration(msg.sender, id1);
    }

    function registrationExt(address referrerAddress) external onlyUnlocked {
        registration(msg.sender, referrerAddress);
    }

    function registrationFor(
        address userAddress,
        address referrerAddress
    ) external onlyUnlocked {
        registration(userAddress, referrerAddress);
    }

    function buyNewLevel(uint8 matrix, uint8 level) external onlyUnlocked {
        _buyNewLevel(msg.sender, matrix, level);
    }

    function buyNewLevelFor(
        address userAddress,
        uint8 matrix,
        uint8 level
    ) external onlyUnlocked {
        _buyNewLevel(userAddress, matrix, level);
    }

    function _buyNewLevel(
        address _userAddress,
        uint8 matrix,
        uint8 level
    ) internal {
        if (!isUserExists(_userAddress)) revert UserDoesNotExist();
        if (matrix != 1 && matrix != 2) revert InvalidMatrix();
        if (level <= 1 || level > LAST_LEVEL) revert InvalidLevel();

        depositToken.safeTransferFrom(
            msg.sender,
            address(this),
            levelPrice[level]
        );

        if (matrix == 1) {
            if (!users[_userAddress].activeX1Levels[level - 1])
                revert BuyPreviousLevelFirst();
            if (users[_userAddress].activeX1Levels[level])
                revert LevelAlreadyActivated();

            if (users[_userAddress].x1Matrix[level - 1].blocked) {
                users[_userAddress].x1Matrix[level - 1].blocked = false;
            }

            address freeX1Referrer = findFreeX1Referrer(_userAddress, level);
            users[_userAddress]
                .x1Matrix[level]
                .currentReferrer = freeX1Referrer;
            users[_userAddress].activeX1Levels[level] = true;
            users[_userAddress].x1Matrix[level].updateX1Referrer(
                _userAddress,
                freeX1Referrer,
                level,
                LAST_LEVEL,
                id1,
                emitNewUserPlace,
                sendBUsdDividends
            );

            emit Upgrade(_userAddress, freeX1Referrer, 1, level);
        } else {
            if (!users[_userAddress].activeX2Levels[level - 1])
                revert BuyPreviousLevelFirst();
            if (users[_userAddress].activeX2Levels[level])
                revert LevelAlreadyActivated();

            if (users[_userAddress].x2Matrix[level - 1].blocked) {
                users[_userAddress].x2Matrix[level - 1].blocked = false;
            }

            address freeX2Referrer = findFreeX2Referrer(_userAddress, level);
            users[_userAddress].activeX2Levels[level] = true;
            users[_userAddress].x2Matrix[level].updateX2Referrer(
                _userAddress,
                freeX2Referrer,
                level,
                LAST_LEVEL,
                id1,
                emitNewUserPlace,
                sendBUsdDividends
            );

            emit Upgrade(_userAddress, freeX2Referrer, 2, level);
        }
    }

    function registration(
        address userAddress,
        address referrerAddress
    ) private {
        depositToken.safeTransferFrom(msg.sender, address(this), BASIC_PRICE);
        if (isUserExists(userAddress)) revert UserExists();
        if (!isUserExists(referrerAddress)) revert ReferrerDoesNotExist();

        users[userAddress].id = lastUserId;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].partnersCount = 0;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].activeX1Levels[1] = true;
        users[userAddress].activeX2Levels[1] = true;

        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[referrerAddress].partnersCount++;

        address freeX1Referrer = findFreeX1Referrer(userAddress, 1);
        users[userAddress].x1Matrix[1].currentReferrer = freeX1Referrer;
        users[userAddress].x1Matrix[1].updateX1Referrer(
            userAddress,
            freeX1Referrer,
            1,
            LAST_LEVEL,
            id1,
            emitNewUserPlace,
            sendBUsdDividends
        );

        users[userAddress].x2Matrix[1].updateX2Referrer(
            userAddress,
            findFreeX2Referrer(userAddress, 1),
            1,
            LAST_LEVEL,
            id1,
            emitNewUserPlace,
            sendBUsdDividends
        );

        emit Registration(
            userAddress,
            referrerAddress,
            users[userAddress].id,
            users[referrerAddress].id
        );
    }

    function findFreeX1Referrer(
        address userAddress,
        uint8 level
    ) public view returns (address referrer) {
        while (true) {
            if (users[users[userAddress].referrer].activeX1Levels[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }

    function findFreeX2Referrer(
        address userAddress,
        uint8 level
    ) public view returns (address referrer) {
        while (true) {
            if (users[users[userAddress].referrer].activeX2Levels[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function sendBUsdDividends(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private {
        (address receiver, bool isExtraDividends) = findBUsdReceiver(
            userAddress,
            _from,
            matrix,
            level
        );
        depositToken.safeTransfer(receiver, levelPrice[level]);

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }

    function findBUsdReceiver(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private returns (address receiver, bool isExtraDividends) {
        address tempReceiver = userAddress;
        if (matrix == 1) {
            while (true) {
                if (users[tempReceiver].x1Matrix[level].blocked) {
                    emit MissedEthReceive(tempReceiver, _from, 1, level);
                    isExtraDividends = true;
                    tempReceiver = users[tempReceiver]
                        .x1Matrix[level]
                        .currentReferrer;
                } else {
                    return (tempReceiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[tempReceiver].x2Matrix[level].blocked) {
                    emit MissedEthReceive(tempReceiver, _from, 2, level);
                    isExtraDividends = true;
                    tempReceiver = users[tempReceiver]
                        .x2Matrix[level]
                        .currentReferrer;
                } else {
                    return (tempReceiver, isExtraDividends);
                }
            }
        }
    }

    function withdrawLostTokens(address tokenAddress) public onlyContractOwner {
        if (tokenAddress == address(depositToken))
            revert("Cannot withdraw deposit token");
        if (tokenAddress == address(0)) {
            payable(contractOwner).transfer(address(this).balance);
        } else {
            IERC20(tokenAddress).transfer(
                contractOwner,
                IERC20(tokenAddress).balanceOf(address(this))
            );
        }
    }

    function emitNewUserPlace(
        address userAddress,
        address referrerAddress,
        uint8 matrix,
        uint8 level
    ) private {
        emit NewUserPlace(userAddress, referrerAddress, matrix, level, 0);
    }
}
