// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import {DSTest} from "ds-test/test.sol";
import {VestingWallet} from "./VestingWallet.sol";
import {Simpletoken} from "./Simpletoken.sol";

interface Vm {
  function warp(uint256) external;
}


contract VestingWalletTest is DSTest {
  Simpletoken st;
  Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);


  function setUp() public {
    st = new Simpletoken("symbol", "name", 18, 1000);
    address beneficiary = address(1337);
  }

  function testImpreciseVesting() public {
    // set block.timestamp to today
    vm.warp(1649241791);
    address beneficiary = address(1337);
    // Let's say we start vesting from now on for 86400*2 seconds.
    VestingWallet vw = new VestingWallet(beneficiary, uint64(block.timestamp), 86400*2);
    assertEq(vw.vestedAmount(uint64(block.timestamp)), 0);

    // now 1 day passes, see: https://book.getfoundry.sh/reference/cheatcodes.html
    vm.warp(block.timestamp+86400);
    // We should have vested 50% of our supply.
    // However, since Solidity can only do integer division 1/2 or 50/100 yields
    // 0.

    // We can hence see that instead of vesting 50%, we've vested still 0%.
    assertEq(vw.vestedAmount(uint64(block.timestamp)), 0);
  }

}
