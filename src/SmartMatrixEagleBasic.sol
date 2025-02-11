// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

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
        function(address, address, uint8, uint8, uint256)
            internal sendDividends,
        mapping(uint8 => uint) storage levelPrice
    ) internal {
        x1.referrals.push(userAddress);

        if (x1.referrals.length < 3) {
            emitNewUserPlace(userAddress, referrerAddress, 1, level);
            sendDividends(
                referrerAddress,
                userAddress,
                1,
                level,
                levelPrice[level] / 2
            ); // 50% for X1
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
            sendDividends(
                referrerAddress,
                userAddress,
                1,
                level,
                levelPrice[level] / 2
            ); // 50% for X1
        } else {
            sendDividends(id1, userAddress, 1, level, levelPrice[level] / 2); // 50% for X1
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
        function(address, address, uint8, uint8, uint256)
            internal sendDividends,
        mapping(uint8 => uint) storage levelPrice
    ) internal {
        if (x2.firstLevelReferrals.length < 2) {
            x2.firstLevelReferrals.push(userAddress);
            emitNewUserPlace(userAddress, referrerAddress, 2, level);
            sendDividends(
                referrerAddress,
                userAddress,
                2,
                level,
                levelPrice[level] / 2
            ); // 50% for X2
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
            sendDividends(
                referrerAddress,
                userAddress,
                2,
                level,
                levelPrice[level] / 2
            ); // 50% for X2
        } else {
            sendDividends(id1, userAddress, 2, level, levelPrice[level] / 2); // 50% for X2
        }
    }
}

contract SmartMatrixEagleBasic is ReentrancyGuard {
    // Add `nonReentrant` modifier to functions that transfer tokens or Ether

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
        if (msg.sender != contractOwner) {
            revert OnlyContractOwner();
        }
        _;
    }

    modifier onlyUnlocked() {
        if (locked && msg.sender != contractOwner) {
            revert OnlyUnlocked();
        }
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
        users[msg.sender].partnersCount = uint8(0);
        idToAddress[1] = msg.sender;

        // Activate all X1 and X2 levels for id1 at deployment

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[msg.sender].activeX1Levels[i] = true;
            users[msg.sender].activeX2Levels[i] = true;
            users[msg.sender].x1Matrix[i].currentReferrer = address(0);
            users[msg.sender].x2Matrix[i].currentReferrer = address(0);
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
        require(matrix == 1 || matrix == 2, "Invalid matrix");
        require(level > 1 && level <= LAST_LEVEL, "Invalid level");
        // Existing code

        if (!isUserExists(_userAddress)) {
            revert UserDoesNotExist();
        }
        if (matrix != 1 && matrix != 2) {
            revert InvalidMatrix();
        }
        if (level <= 1 || level > LAST_LEVEL) {
            revert InvalidLevel();
        }

        depositToken.safeTransferFrom(
            msg.sender,
            address(this),
            levelPrice[level]
        );

        if (matrix == 1) {
            if (!users[_userAddress].activeX1Levels[level - 1]) {
                revert BuyPreviousLevelFirst();
            }
            if (users[_userAddress].activeX1Levels[level]) {
                revert LevelAlreadyActivated();
            }

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
                sendBusdDividends,
                levelPrice
            );

            emit Upgrade(_userAddress, freeX1Referrer, 1, level);
        } else {
            if (!users[_userAddress].activeX2Levels[level - 1]) {
                revert BuyPreviousLevelFirst();
            }
            if (users[_userAddress].activeX2Levels[level]) {
                revert LevelAlreadyActivated();
            }

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
                sendBusdDividends,
                levelPrice
            );

            emit Upgrade(_userAddress, freeX2Referrer, 2, level);
        }
    }

    function registration(
        address userAddress,
        address referrerAddress
    ) private {
        require(userAddress != address(0), "Invalid user address");
        require(referrerAddress != address(0), "Invalid referrer address");
        // Existing code

        depositToken.safeTransferFrom(msg.sender, address(this), BASIC_PRICE);
        if (isUserExists(userAddress)) {
            revert UserExists();
        }
        if (!isUserExists(referrerAddress)) {
            revert ReferrerDoesNotExist();
        }

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
            sendBusdDividends,
            levelPrice
        );

        users[userAddress].x2Matrix[1].updateX2Referrer(
            userAddress,
            findFreeX2Referrer(userAddress, 1),
            1,
            LAST_LEVEL,
            id1,
            emitNewUserPlace,
            sendBusdDividends,
            levelPrice
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

    function sendBusdDividends(
        address userAddress,
        address _from,
        uint8 matrix,
        uint8 level,
        uint256 amount
    ) private {
        (address receiver, bool isExtraDividends) = findBusdReceiver(
            userAddress,
            _from,
            matrix,
            level
        );
        depositToken.safeTransfer(receiver, amount);

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }

    function findBusdReceiver(
        address _userAddress,
        address _from,
        uint8 matrix,
        uint8 level
    ) private returns (address receiver, bool isExtraDividends) {
        address tempReceiver = _userAddress;
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

    function withdrawLostTokens(
        address tokenAddress
    ) public onlyContractOwner nonReentrant {
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
