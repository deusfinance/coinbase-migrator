//Be name khoda

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.1/contracts/access/Ownable.sol';

interface IERC20 {
	function mint(address to, uint256 amount) external;
	function burn(address from, uint256 amount) external;
	function transfer(address recipient, uint256 amount) external returns (bool);
}

contract dbETHMigrator is Ownable {

	event Migrate(address user, uint256 amount);

	address public fromToken;
	address public toToken;
	uint256 public ratio;
	uint256 public scale = 1e18;
	// uint256 public endBlock;

	constructor (address _fromToken, address _toToken, uint256 _ratio) {
		fromToken = _fromToken;
		toToken = _toToken;
		ratio = _ratio;
		// endBlock = _endBlock;
	}

	function setTokens(address _fromToken, address _toToken) external onlyOwner {
		require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
		fromToken = _fromToken;
		toToken = _toToken;
	}

	function setRatio(uint256 _ratio) external onlyOwner {
		ratio = _ratio;
	}

	function migrateFor(address user, uint256 amount) public {
		IERC20(fromToken).burn(msg.sender, amount);
		IERC20(toToken).mint(user, amount * ratio / scale);
		Migrate(user, amount * ratio / scale);
	}

	function migrate(uint256 amount) external {
		migrateFor(msg.sender, amount);
	}
}
