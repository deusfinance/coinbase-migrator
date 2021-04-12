//Be name khoda

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol';

interface IERC20 {
	function mint(address to, uint256 amount) external;
	function burn(address from, uint256 amount) external;
	function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Migrator is AccessControl {

	event Migrate(address user, uint256 amount);

	address public fromCoin;
	uint256 public ratio;
	uint256 public scale = 1e18;
	uint256 public endBlock;

	constructor (address _fromCoin, uint256 _ratio, uint256 _endBlock) {
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
		fromCoin = _fromCoin;
		ratio = _ratio;
		endBlock = _endBlock;
	}

	modifier openMigrate {
		require(block.number <= endBlock, "Migration is closed");
		_;
	}

	function setFromCoin(address _fromCoin) external {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
		fromCoin = _fromCoin;
	}

	function setEndBlock(uint256 _endBlock) external {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
		endBlock = _endBlock;
	}

	function setRatio(uint256 _ratio) external {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
		ratio = _ratio;
	}

	function migrateFor(address user, uint256 amount, address toCoin) public openMigrate {
		IERC20(fromCoin).burn(msg.sender, amount);
		IERC20(toCoin).mint(user, amount * ratio / scale);
		Migrate(user, amount * ratio / scale);
	}

	function migrate(uint256 amount, address toCoin) external {
		migrateFor(msg.sender, amount, toCoin);
	}

	function withdraw(address to, uint256 amount, address token) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
		IERC20(token).transfer(to, amount);
	}
}
