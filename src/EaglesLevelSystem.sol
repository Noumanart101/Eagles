/**
 *Submitted for verification at BscScan.com on 2021-05-31
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract SmartMatrixEagleBasic {
    address public contractOwner;

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        mapping(uint8 => bool) activeX1Levels;
        mapping(uint8 => bool) activeX2Levels;
        mapping(uint8 => X1) x1Matrix;
        mapping(uint8 => X2) x2Matrix;
    }

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

    uint8 public LAST_LEVEL;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances;

    uint public lastUserId;
    address public id1;

    // address public multisig;

    mapping(uint8 => uint) public levelPrice;

    IERC20 public depositToken;

    uint public BASIC_PRICE;

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
}

contract EaglesLevelSystem is SmartMatrixEagleBasic {
    using SafeERC20 for IERC20;

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "onlyOwner");
        _;
    }

    modifier onlyUnlocked() {
        require(!locked || msg.sender == contractOwner);
        _;
    }

    constructor(
        /* address _ownerAddress,*/
        /* address _multisig, */
        IERC20 _depositTokenAddress
    ) /* onlyContractOwner */ {
        contractOwner = msg.sender;
        BASIC_PRICE = 5e18;
        LAST_LEVEL = 12;

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

        // multisig = _multisig;

        depositToken = _depositTokenAddress;

        locked = true;
    }

    function changeLock() external onlyContractOwner {
        locked = !locked;
    }

    fallback() external {
        if (msg.data.length == 0) {
            return registration(msg.sender, id1);
        }

        registration(msg.sender, bytesToAddress(msg.data));
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
        require(
            isUserExists(_userAddress),
            "user is not exists. Register first."
        );
        require(matrix == 1 || matrix == 2, "invalid matrix");

        depositToken.safeTransferFrom(
            msg.sender,
            address(this),
            levelPrice[level]
        );
        // require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1) {
            require(
                users[_userAddress].activeX1Levels[level - 1],
                "buy previous level first"
            );
            require(
                !users[_userAddress].activeX1Levels[level],
                "level already activated"
            );

            if (users[_userAddress].x1Matrix[level - 1].blocked) {
                users[_userAddress].x1Matrix[level - 1].blocked = false;
            }

            address freeX1Referrer = findFreeX1Referrer(_userAddress, level);
            users[_userAddress]
                .x1Matrix[level]
                .currentReferrer = freeX1Referrer;
            users[_userAddress].activeX1Levels[level] = true;
            updateX1Referrer(_userAddress, freeX1Referrer, level);

            emit Upgrade(_userAddress, freeX1Referrer, 1, level);
        } else {
            require(
                users[_userAddress].activeX2Levels[level - 1],
                "buy previous level first"
            );
            require(
                !users[_userAddress].activeX2Levels[level],
                "level already activated"
            );

            if (users[_userAddress].x2Matrix[level - 1].blocked) {
                users[_userAddress].x2Matrix[level - 1].blocked = false;
            }

            address freeX2Referrer = findFreeX2Referrer(_userAddress, level);

            users[_userAddress].activeX2Levels[level] = true;
            updateX2Referrer(_userAddress, freeX2Referrer, level);

            emit Upgrade(_userAddress, freeX2Referrer, 2, level);
        }
    }

    function registration(
        address userAddress,
        address referrerAddress
    ) private {
        depositToken.safeTransferFrom(
            msg.sender,
            address(this),
            BASIC_PRICE * 2
        );
        // require(msg.value == BASIC_PRICE * 2, "invalid registration value");

        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        // require(size == 0, "cannot be a contract");

        users[userAddress].id = lastUserId;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].partnersCount = 0;
        idToAddress[lastUserId] = userAddress;

        users[userAddress].referrer = referrerAddress;

        users[userAddress].activeX1Levels[1] = true;
        users[userAddress].activeX2Levels[1] = true;

        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[referrerAddress].partnersCount++;

        address freeX1Referrer = findFreeX1Referrer(userAddress, 1);
        users[userAddress].x1Matrix[1].currentReferrer = freeX1Referrer;
        updateX1Referrer(userAddress, freeX1Referrer, 1);

        updateX2Referrer(userAddress, findFreeX2Referrer(userAddress, 1), 1);

        emit Registration(
            userAddress,
            referrerAddress,
            users[userAddress].id,
            users[referrerAddress].id
        );
    }

    function updateX1Referrer(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        users[referrerAddress].x1Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x1Matrix[level].referrals.length < 3) {
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                1,
                level,
                uint8(users[referrerAddress].x1Matrix[level].referrals.length)
            );
            return sendBUsdDividends(referrerAddress, userAddress, 1, level);
        }

        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].x1Matrix[level].referrals = new address[](0);
        if (
            !users[referrerAddress].activeX1Levels[level + 1] &&
            level != LAST_LEVEL
        ) {
            users[referrerAddress].x1Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != id1) {
            //check referrer active level
            address freeReferrerAddress = findFreeX1Referrer(
                referrerAddress,
                level
            );
            if (
                users[referrerAddress].x1Matrix[level].currentReferrer !=
                freeReferrerAddress
            ) {
                users[referrerAddress]
                    .x1Matrix[level]
                    .currentReferrer = freeReferrerAddress;
            }

            users[referrerAddress].x1Matrix[level].reinvestCount++;
            emit Reinvest(
                referrerAddress,
                freeReferrerAddress,
                userAddress,
                1,
                level
            );
            updateX1Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendBUsdDividends(id1, userAddress, 1, level);
            users[id1].x1Matrix[level].reinvestCount++;
            emit Reinvest(id1, address(0), userAddress, 1, level);
        }
    }

    function updateX2Referrer(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        require(
            users[referrerAddress].activeX2Levels[level],
            "500. Referrer level is inactive"
        );

        if (
            users[referrerAddress].x2Matrix[level].firstLevelReferrals.length <
            2
        ) {
            users[referrerAddress].x2Matrix[level].firstLevelReferrals.push(
                userAddress
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                uint8(
                    users[referrerAddress]
                        .x2Matrix[level]
                        .firstLevelReferrals
                        .length
                )
            );

            //set current level
            users[userAddress]
                .x2Matrix[level]
                .currentReferrer = referrerAddress;

            if (referrerAddress == id1) {
                return
                    sendBUsdDividends(referrerAddress, userAddress, 2, level);
            }

            address ref = users[referrerAddress]
                .x2Matrix[level]
                .currentReferrer;
            users[ref].x2Matrix[level].secondLevelReferrals.push(userAddress);

            uint len = users[ref].x2Matrix[level].firstLevelReferrals.length;

            if (
                (len == 2) &&
                (users[ref].x2Matrix[level].firstLevelReferrals[0] ==
                    referrerAddress) &&
                (users[ref].x2Matrix[level].firstLevelReferrals[1] ==
                    referrerAddress)
            ) {
                if (
                    users[referrerAddress]
                        .x2Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            } else if (
                (len == 1 || len == 2) &&
                users[ref].x2Matrix[level].firstLevelReferrals[0] ==
                referrerAddress
            ) {
                if (
                    users[referrerAddress]
                        .x2Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (
                len == 2 &&
                users[ref].x2Matrix[level].firstLevelReferrals[1] ==
                referrerAddress
            ) {
                if (
                    users[referrerAddress]
                        .x2Matrix[level]
                        .firstLevelReferrals
                        .length == 1
                ) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }

            return updateX2ReferrerSecondLevel(userAddress, ref, level);
        }

        users[referrerAddress].x2Matrix[level].secondLevelReferrals.push(
            userAddress
        );

        if (users[referrerAddress].x2Matrix[level].closedPart != address(0)) {
            if (
                (users[referrerAddress].x2Matrix[level].firstLevelReferrals[
                    0
                ] ==
                    users[referrerAddress].x2Matrix[level].firstLevelReferrals[
                        1
                    ]) &&
                (users[referrerAddress].x2Matrix[level].firstLevelReferrals[
                    0
                ] == users[referrerAddress].x2Matrix[level].closedPart)
            ) {
                updateX2(userAddress, referrerAddress, level, true);
                return
                    updateX2ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            } else if (
                users[referrerAddress].x2Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x2Matrix[level].closedPart
            ) {
                updateX2(userAddress, referrerAddress, level, true);
                return
                    updateX2ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            } else {
                updateX2(userAddress, referrerAddress, level, false);
                return
                    updateX2ReferrerSecondLevel(
                        userAddress,
                        referrerAddress,
                        level
                    );
            }
        }

        if (
            users[referrerAddress].x2Matrix[level].firstLevelReferrals[1] ==
            userAddress
        ) {
            updateX2(userAddress, referrerAddress, level, false);
            return
                updateX2ReferrerSecondLevel(
                    userAddress,
                    referrerAddress,
                    level
                );
        } else if (
            users[referrerAddress].x2Matrix[level].firstLevelReferrals[0] ==
            userAddress
        ) {
            updateX2(userAddress, referrerAddress, level, true);
            return
                updateX2ReferrerSecondLevel(
                    userAddress,
                    referrerAddress,
                    level
                );
        }

        if (
            users[users[referrerAddress].x2Matrix[level].firstLevelReferrals[0]]
                .x2Matrix[level]
                .firstLevelReferrals
                .length <=
            users[users[referrerAddress].x2Matrix[level].firstLevelReferrals[1]]
                .x2Matrix[level]
                .firstLevelReferrals
                .length
        ) {
            updateX2(userAddress, referrerAddress, level, false);
        } else {
            updateX2(userAddress, referrerAddress, level, true);
        }

        updateX2ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX2(
        address userAddress,
        address referrerAddress,
        uint8 level,
        bool x2
    ) private {
        if (!x2) {
            users[users[referrerAddress].x2Matrix[level].firstLevelReferrals[0]]
                .x2Matrix[level]
                .firstLevelReferrals
                .push(userAddress);
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x2Matrix[level].firstLevelReferrals[0],
                2,
                level,
                uint8(
                    users[
                        users[referrerAddress]
                            .x2Matrix[level]
                            .firstLevelReferrals[0]
                    ].x2Matrix[level].firstLevelReferrals.length
                )
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                2 +
                    uint8(
                        users[
                            users[referrerAddress]
                                .x2Matrix[level]
                                .firstLevelReferrals[0]
                        ].x2Matrix[level].firstLevelReferrals.length
                    )
            );
            //set current level
            users[userAddress].x2Matrix[level].currentReferrer = users[
                referrerAddress
            ].x2Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x2Matrix[level].firstLevelReferrals[1]]
                .x2Matrix[level]
                .firstLevelReferrals
                .push(userAddress);
            emit NewUserPlace(
                userAddress,
                users[referrerAddress].x2Matrix[level].firstLevelReferrals[1],
                2,
                level,
                uint8(
                    users[
                        users[referrerAddress]
                            .x2Matrix[level]
                            .firstLevelReferrals[1]
                    ].x2Matrix[level].firstLevelReferrals.length
                )
            );
            emit NewUserPlace(
                userAddress,
                referrerAddress,
                2,
                level,
                4 +
                    uint8(
                        users[
                            users[referrerAddress]
                                .x2Matrix[level]
                                .firstLevelReferrals[1]
                        ].x2Matrix[level].firstLevelReferrals.length
                    )
            );
            //set current level
            users[userAddress].x2Matrix[level].currentReferrer = users[
                referrerAddress
            ].x2Matrix[level].firstLevelReferrals[1];
        }
    }

    function updateX2ReferrerSecondLevel(
        address userAddress,
        address referrerAddress,
        uint8 level
    ) private {
        if (
            users[referrerAddress].x2Matrix[level].secondLevelReferrals.length <
            4
        ) {
            return sendBUsdDividends(referrerAddress, userAddress, 2, level);
        }

        address[] memory x2 = users[
            users[referrerAddress].x2Matrix[level].currentReferrer
        ].x2Matrix[level].firstLevelReferrals;

        if (x2.length == 2) {
            if (x2[0] == referrerAddress || x2[1] == referrerAddress) {
                users[users[referrerAddress].x2Matrix[level].currentReferrer]
                    .x2Matrix[level]
                    .closedPart = referrerAddress;
            } else if (x2.length == 1) {
                if (x2[0] == referrerAddress) {
                    users[
                        users[referrerAddress].x2Matrix[level].currentReferrer
                    ].x2Matrix[level].closedPart = referrerAddress;
                }
            }
        }

        users[referrerAddress]
            .x2Matrix[level]
            .firstLevelReferrals = new address[](0);
        users[referrerAddress]
            .x2Matrix[level]
            .secondLevelReferrals = new address[](0);
        users[referrerAddress].x2Matrix[level].closedPart = address(0);

        if (
            !users[referrerAddress].activeX2Levels[level + 1] &&
            level != LAST_LEVEL
        ) {
            users[referrerAddress].x2Matrix[level].blocked = true;
        }

        users[referrerAddress].x2Matrix[level].reinvestCount++;

        if (referrerAddress != id1) {
            address freeReferrerAddress = findFreeX2Referrer(
                referrerAddress,
                level
            );

            emit Reinvest(
                referrerAddress,
                freeReferrerAddress,
                userAddress,
                2,
                level
            );
            updateX2Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(id1, address(0), userAddress, 2, level);
            sendBUsdDividends(id1, userAddress, 2, level);
        }
    }

    function findFreeX1Referrer(
        address userAddress,
        uint8 level
    ) public view returns (address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX1Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
        return userAddress;
    }

    function findFreeX2Referrer(
        address userAddress,
        uint8 level
    ) public view returns (address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX2Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
        return userAddress;
    }

    function usersActiveX1Levels(
        address userAddress,
        uint8 level
    ) public view returns (bool) {
        return users[userAddress].activeX1Levels[level];
    }

    function usersActiveX2Levels(
        address userAddress,
        uint8 level
    ) public view returns (bool) {
        return users[userAddress].activeX2Levels[level];
    }

    function usersX1Matrix(
        address userAddress,
        uint8 level
    ) public view returns (address, address[] memory, bool) {
        return (
            users[userAddress].x1Matrix[level].currentReferrer,
            users[userAddress].x1Matrix[level].referrals,
            users[userAddress].x1Matrix[level].blocked
        );
    }

    function usersX2Matrix(
        address userAddress,
        uint8 level
    )
        public
        view
        returns (address, address[] memory, address[] memory, bool, address)
    {
        return (
            users[userAddress].x2Matrix[level].currentReferrer,
            users[userAddress].x2Matrix[level].firstLevelReferrals,
            users[userAddress].x2Matrix[level].secondLevelReferrals,
            users[userAddress].x2Matrix[level].blocked,
            users[userAddress].x2Matrix[level].closedPart
        );
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findBUsdReceiver(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private returns (address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].x1Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x1Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].x2Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x2Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
        return (receiver, isExtraDividends);
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
        // if (!address(uint160(receiver)).send(levelPrice[level])) {
        //     return address(uint160(receiver)).transfer(address(this).balance);
        // }

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }

    function bytesToAddress(
        bytes memory bys
    ) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function withdrawLostTokens(address tokenAddress) public onlyContractOwner {
        require(
            tokenAddress != address(depositToken),
            "cannot withdraw deposit token"
        );
        if (tokenAddress == address(0)) {
            payable(address(uint160(contractOwner))).transfer(
                address(this).balance
            );
        } else {
            IERC20(tokenAddress).transfer(
                contractOwner,
                IERC20(tokenAddress).balanceOf(address(this))
            );
        }
    }
}
