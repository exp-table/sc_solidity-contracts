// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.10;

import "../Vault.sol";
import "../mock/MockERC20.sol";

contract Addresses {
    Vault vault = Vault(0x48BaCB9266a570d521063EF5dD96e61686DbE788);
    MockERC20 underlying = MockERC20(0x1dC4c1cEFEF38a777b15aA20260a54E584b16C48);
}