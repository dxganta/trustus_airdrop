// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "ds-test/test.sol";
import {TrustusAirdrop} from "../TrustusAirdrop.sol";
import {MockERC20} from "./utils/MockERC20.sol";

contract TrustusAirdropTest is DSTest {
    TrustusAirdrop airdrop;

    function setUp() public {
        MockERC20 token = new MockERC20("ShitCoin69", "S69");
        address[] memory owners = new address[](1);
        owners[0] = address(this);
        airdrop = new TrustusAirdrop(address(token), owners);
        token.transfer(address(airdrop), token.balanceOf(address(this)));
    }
}
