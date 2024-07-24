// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../test/aave-v3/strategy.t.sol";

import {Strategy} from "../../aave-v3/strategy.sol";
import "@aave/contracts/interfaces/IPool.sol";
import "@aave/contracts/interfaces/IAToken.sol";
import "@aave/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

import "@aave/contracts/interfaces/IPool.sol";
import "@aave/contracts/protocol/libraries/types/DataTypes.sol";


contract MockAToken is IAToken {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _underlyingAsset;
    IPool private _pool;

    constructor(string memory name_, string memory symbol_, address underlyingAsset_, address pool_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _underlyingAsset = underlyingAsset_;
        _pool = IPool(pool_);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function UNDERLYING_ASSET_ADDRESS() external view returns (address) {
        return _underlyingAsset;
    }

    function POOL() external view returns (IPool) {
        return _pool;
    }

    function transferUnderlyingTo(address target, uint256 amount) external returns (uint256) {
        // Mock implementation
        return amount;
    }

    function handleRepayment(address user, uint256 amount) external {}

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {}

    function nonces(address owner) external view returns (uint256) {
        return 0;
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return bytes32(0);
    }

    function scaledBalanceOf(address user) external view returns (uint256) {
        return _balances[user];
    }

    function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256) {
        return (_balances[user], _totalSupply);
    }

    function scaledTotalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function getPreviousIndex(address user) external view returns (uint256) {
        return 0;
    }

    function RESERVE_TREASURY_ADDRESS() external view returns (address) {
        return address(0);
    }

    function ATOKEN_REVISION() external view returns (uint256) {
        return 1;
    }
}

contract MockERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}


contract MockPool is IPool {
    mapping(address => uint256) private supplies;
    mapping(address => uint256) private borrows;

    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external override {
        supplies[onBehalfOf] += amount;
    }

    function withdraw(address asset, uint256 amount, address to) external override returns (uint256) {
        require(supplies[msg.sender] >= amount, "Insufficient balance");
        supplies[msg.sender] -= amount;
        return amount;
    }

    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf) external override {
        borrows[onBehalfOf] += amount;
    }

    function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf) external override returns (uint256) {
        require(borrows[onBehalfOf] >= amount, "Insufficient borrow");
        borrows[onBehalfOf] -= amount;
        return amount;
    }

    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external override {}

    function liquidationCall(address collateralAsset, address debtAsset, address user, uint256 debtToCover, bool receiveAToken) external override returns (uint256, string memory) {
        return (0, "");
    }

    function flashLoan(address receiverAddress, address[] calldata assets, uint256[] calldata amounts, uint256[] calldata interestRateModes, address onBehalfOf, bytes calldata params, uint16 referralCode) external override returns (uint256[] memory) {
        return new uint256[](assets.length);
    }

    function getUserAccountData(address user) external view override returns (uint256 totalCollateralBase, uint256 totalDebtBase, uint256 availableBorrowsBase, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor) {
        return (supplies[user], borrows[user], supplies[user] - borrows[user], 8000, 8000, 1e18);
    }

    function initReserve(address asset, address aTokenAddress, address stableDebtAddress, address variableDebtAddress, address interestRateStrategyAddress) external override {}

    function dropReserve(address asset) external override {}

    function setReserveInterestRateStrategyAddress(address asset, address rateStrategyAddress) external override {}

    function setConfiguration(address asset, DataTypes.ReserveConfigurationMap calldata configuration) external override {}

    function getConfiguration(address asset) external view override returns (DataTypes.ReserveConfigurationMap memory) {
        return DataTypes.ReserveConfigurationMap(0);
    }

    function getUserConfiguration(address user) external view override returns (DataTypes.UserConfigurationMap memory) {
        return DataTypes.UserConfigurationMap(0);
    }

    function getReserveNormalizedIncome(address asset) external view override returns (uint256) {
        return 1e27;
    }

    function getReserveNormalizedVariableDebt(address asset) external view override returns (uint256) {
        return 1e27;
    }

    function finalizeTransfer(address asset, address from, address to, uint256 amount, uint256 balanceFromBefore, uint256 balanceToBefore) external override {}

    function getReservesList() external view override returns (address[] memory) {
        address[] memory reserves = new address[](1);
        reserves[0] = address(this);
        return reserves;
    }

    function getReserveData(address asset) external view override returns (DataTypes.ReserveData memory) {
        return DataTypes.ReserveData(
            DataTypes.ReserveConfigurationMap(0),
            uint128(0),
            uint128(0),
            uint128(0),
            uint128(0),
            uint128(0),
            uint40(block.timestamp),
            address(0),
            address(0),
            address(0),
            address(0),
            uint8(0)
        );
    }

    function setPause(bool val) external override {}

    function paused() external view override returns (bool) {
        return false;
    }

    function getAddressesProvider() external view override returns (address) {
        return address(this);
    }

    function setAddressesProvider(address provider) external override {}
}

contract StrategyTest is Test {
    Strategy public strategy;
    MockPool public mockPool;
    MockERC20 public mockUnderlyingAsset;
    MockAToken public mockAToken;
    address public user1;
    address public user2;

    function setUp() public {
        mockPool = new MockPool();
        mockUnderlyingAsset = new MockERC20("Mock Token", "MTK");
        mockAToken = new MockAToken("Mock AToken", "MATK", address(mockUnderlyingAsset), address(mockPool));
        
        strategy = new Strategy(address(mockPool), address(mockUnderlyingAsset), address(mockAToken));
        
        user1 = address(0x1);
        user2 = address(0x2);
    }

    function testDeposit() public {
        uint256 depositAmount = 1000e18;
        
        vm.startPrank(user1);
        mockUnderlyingAsset.mint(user1, depositAmount);
        mockUnderlyingAsset.approve(address(strategy), depositAmount);
        strategy.deposit(depositAmount);
        vm.stopPrank();

        assertEq(mockAToken.balanceOf(address(strategy)), depositAmount, "Deposit amount should match aToken balance");
    }

    function testAutoCompound() public {
        uint256 depositAmount = 1000e18;
        uint256 rewardAmount = 100e18;
        
        vm.startPrank(user1);
        mockUnderlyingAsset.mint(user1, depositAmount);
        mockUnderlyingAsset.approve(address(strategy), depositAmount);
        strategy.deposit(depositAmount);
        vm.stopPrank();

        // Simulate reward accrual
        mockPool.setReserveNormalizedIncome(address(mockUnderlyingAsset), 1.1e27);
        mockUnderlyingAsset.mint(address(mockPool), rewardAmount);

        strategy.autoCompound();

        assertEq(mockAToken.balanceOf(address(strategy)), depositAmount + rewardAmount, "Balance should increase after auto-compound");
    }

    function testWithdraw() public {
        uint256 depositAmount = 1000e18;
        uint256 withdrawAmount = 500e18;
        
        vm.startPrank(user1);
        mockUnderlyingAsset.mint(user1, depositAmount);
        mockUnderlyingAsset.approve(address(strategy), depositAmount);
        strategy.deposit(depositAmount);
        
        uint256 balanceBefore = mockUnderlyingAsset.balanceOf(user1);
        strategy.withdraw(withdrawAmount);
        uint256 balanceAfter = mockUnderlyingAsset.balanceOf(user1);
        vm.stopPrank();

        assertEq(balanceAfter - balanceBefore, withdrawAmount, "Withdrawn amount should match");
    }

    function testWithdrawAll() public {
        uint256 depositAmount = 1000e18;
        
        vm.startPrank(user1);
        mockUnderlyingAsset.mint(user1, depositAmount);
        mockUnderlyingAsset.approve(address(strategy), depositAmount);
        strategy.deposit(depositAmount);
        
        uint256 balanceBefore = mockUnderlyingAsset.balanceOf(user1);
        strategy.withdrawAll();
        uint256 balanceAfter = mockUnderlyingAsset.balanceOf(user1);
        vm.stopPrank();

        assertEq(balanceAfter - balanceBefore, depositAmount, "All funds should be withdrawn");
    }
}

