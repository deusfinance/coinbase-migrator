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

	address public coinbase;
	address public dCoin;

	constructor (
		address _coinbase,
		address _dCoin
	) {
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

		coinbase = _coinbase;
		dCoin = _dCoin;
    }

	function migrateFor(address user, uint256 amount) public {
		IERC20(coinbase).transferFrom(msg.sender, user, amount);
		IERC20(dCoin).mint(user, amount);
		Migrate(user, amount);
	}

	function migrate(uint256 amount) external {
		migrateFor(msg.sender, amount);
	}

	function withdraw(address to, uint256 amount) public {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        IERC20(coinbase).transfer(to, amount);
    }
}