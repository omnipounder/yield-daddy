// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.10;

import {IPool} from "@aave/contracts/interfaces/IPool.sol";
import {IAToken} from "@aave/contracts/interfaces/IAToken.sol";
import {IERC20} from "@aave/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract Strategy {
    IPool public immutable pool;
    IERC20 public immutable underlyingAsset;
    IAToken public immutable aToken;

    constructor(address _pool, address _underlyingAsset, address _aToken) {
        pool = IPool(_pool);
        underlyingAsset = IERC20(_underlyingAsset);
        aToken = IAToken(_aToken);
    }

    function deposit(uint256 amount) external {
        require(underlyingAsset.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        underlyingAsset.approve(address(pool), amount);
        pool.supply(address(underlyingAsset), amount, address(this), 0);
    }

    function autoCompound() external {
        uint256 aTokenBalance = aToken.balanceOf(address(this));
        uint256 underlyingBalance = pool.getReserveNormalizedIncome(address(underlyingAsset)) * aTokenBalance / 1e27;
        uint256 rewards = underlyingBalance - aTokenBalance;

        if (rewards > 0) {
            pool.supply(address(underlyingAsset), rewards, address(this), 0);
        }
    }

    function withdraw(uint256 amount) external {
        pool.withdraw(address(underlyingAsset), amount, msg.sender);
    }

    function withdrawAll() external {
        uint256 aTokenBalance = aToken.balanceOf(address(this));
        pool.withdraw(address(underlyingAsset), aTokenBalance, msg.sender);
    }
}



