//Be name khoda

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol';

interface IERC20 {
	function mint(address to, uint256 amount) external;
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Migrator is AccessControl {

	event Migrate(address user, uint256 amount);

	address public fromCoin;
	uint256 public ratio;
	uint256 public scale = 1e18;

	constructor (address _fromCoin) {
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
		fromCoin = _fromCoin;
	}

	function setRatio(uint256 _ratio) external {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
		ratio = _ratio;
	}

	function migrateFor(address user, uint256 amount, address toCoin) public {
		IERC20(fromCoin).transferFrom(msg.sender, address(this), amount);
		IERC20(toCoin).mint(user, amount * ratio / scale);
		Migrate(user, amount);
	}

	function migrate(uint256 amount, address toCoin) external {
		migrateFor(msg.sender, amount, toCoin);
	}

	function withdraw(address to, uint256 amount) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
		IERC20(fromCoin).transfer(to, amount);
	}
}
