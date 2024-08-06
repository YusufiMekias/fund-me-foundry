// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//importing the Test contract for forge to assist

//import {Vm} from "../lib/forge-std/src/vm.sol";
//import {StdAssertions} from "../lib/forge-std/src/StdAssertions.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundme;
    uint256 number;
    uint256 minUSD;
    function setUp() external {
        fundme = new FundMe();
        number = 2;

    }
    function testMinDollarIs5() public view {
        console.log(minUSD);
        assertEq(fundme.MINIMUM_USD(),5e18);
    }
    function testOwnerIsMsgSender() public view {
        assertEq(fundme.owner(), msg.sender);
    }
}   