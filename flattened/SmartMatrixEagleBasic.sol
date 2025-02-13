// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// src/SmartMatrixEagleBasic.sol

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract SmartMatrixEagleBasic {
    address public owner;
    uint256 public constant ACTIVATION_FEE = 5 * 1e18; // 5 USDT (assuming 18 decimals)
    uint256 public constant MAX_LEVELS = 12;
    uint256 public constant SLOTS_PER_MATRIX = 4;

    struct User {
        address upline;
        uint256 level;
        bool active;
        bool x1Blocked;
        uint256 x1SlotsFilled;
        uint256 x2SlotsFilled;
    }

    mapping(address => User) public users;
    mapping(uint256 => uint256) public levelFees; // Level fees (doubling each level)
    IERC20 public usdt;

    event UserRegistered(address indexed user, address indexed upline);
    event ReferralAdded(
        address indexed user,
        address indexed referral,
        uint256 matrix,
        uint256 slot
    );
    event LevelUpgraded(address indexed user, uint256 level);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyActiveUser() {
        require(users[msg.sender].active, "User is not active");
        _;
    }

    constructor(address _usdtAddress) {
        owner = msg.sender;
        usdt = IERC20(_usdtAddress);

        // Initialize level fees (doubling each level)
        levelFees[1] = ACTIVATION_FEE;
        for (uint256 i = 2; i <= MAX_LEVELS; i++) {
            levelFees[i] = levelFees[i - 1] * 2;
        }

        // Owner is automatically active at all levels
        users[owner] = User(address(0), MAX_LEVELS, true, false, 0, 0);
    }

    function register(address _upline) external {
        require(
            users[msg.sender].upline == address(0),
            "User already registered"
        );
        require(users[_upline].active, "Upline is not active");

        // Pay activation fee to upline
        require(
            usdt.transferFrom(msg.sender, _upline, ACTIVATION_FEE),
            "USDT transfer failed"
        );

        // Activate user
        users[msg.sender] = User(_upline, 1, true, false, 0, 0);

        emit UserRegistered(msg.sender, _upline);
    }

    function addReferral(address _referral) external onlyActiveUser {
        require(
            users[_referral].upline == address(0),
            "Referral already registered"
        );

        // Pay activation fee to upline
        require(
            usdt.transferFrom(_referral, msg.sender, ACTIVATION_FEE),
            "USDT transfer failed"
        );

        // Distribute funds according to rules
        distributeFunds(_referral);

        // Update slots
        updateSlots(msg.sender, _referral);

        emit ReferralAdded(
            msg.sender,
            _referral,
            1,
            users[msg.sender].x1SlotsFilled
        );
    }

    function distributeFunds(address /* _referral */) private {
        uint256 amountX1 = ACTIVATION_FEE / 2;
        uint256 amountX2 = ACTIVATION_FEE / 2;

        // Distribute x1 funds
        address eligibleUpline = findEligibleUpline(msg.sender);
        require(
            usdt.transfer(eligibleUpline, amountX1),
            "USDT transfer failed"
        );

        // Distribute x2 funds
        uint256 part = amountX2 / 5;
        for (uint256 i = 0; i < 3; i++) {
            address randomUser = getRandomUser();
            require(usdt.transfer(randomUser, part), "USDT transfer failed");
        }
        require(usdt.transfer(owner, part * 2), "USDT transfer failed");
    }

    function findEligibleUpline(address _user) private view returns (address) {
        address upline = users[_user].upline;
        while (upline != address(0) && users[upline].x1Blocked) {
            upline = users[upline].upline;
        }
        return upline == address(0) ? owner : upline;
    }

    function getRandomUser() private view returns (address) {
        // Simplified random user selection (for demonstration purposes)
        return owner;
    }

    function updateSlots(address _user, address /* _referral */) private {
        User storage user = users[_user];

        // Update x1 slots
        user.x1SlotsFilled++;
        if (user.x1SlotsFilled == SLOTS_PER_MATRIX) {
            user.x1Blocked = true;
        }

        // Update x2 slots
        user.x2SlotsFilled++;
    }

    function upgradeLevel() external onlyActiveUser {
        User storage user = users[msg.sender];
        require(user.level < MAX_LEVELS, "Already at max level");
        require(user.x1Blocked, "x1 matrix must be blocked to upgrade");

        // Pay level fee
        uint256 nextLevel = user.level + 1;
        require(
            usdt.transferFrom(msg.sender, owner, levelFees[nextLevel]),
            "USDT transfer failed"
        );

        // Unblock x1 matrix
        user.level = nextLevel;
        user.x1Blocked = false;
        user.x1SlotsFilled = 0;

        emit LevelUpgraded(msg.sender, nextLevel);
    }

    function withdrawUSDT(uint256 _amount) external onlyOwner {
        require(usdt.transfer(owner, _amount), "USDT transfer failed");
    }
}
