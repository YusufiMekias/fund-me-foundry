// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//importing the Test contract for forge to assist

//import {Vm} from "../lib/forge-std/src/vm.sol";
//import {StdAssertions} from "../lib/forge-std/src/StdAssertions.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {FundMe} from "../src/FundMe.sol";

import {DeployFundMe} from "../script/DeployFundMe.s.sol";



//different types of tests
//1.unit testing
//      testing specific part of our code
//2. integration
//      testion how our code works with other parts of our code
//3. forked
//      testing our code on a simulated real environment
//4. staging
//      testing our code in a real environment that is not prod

contract FundMeTest is Test{
    FundMe fundme;
    uint256 number;
    uint256 minUSD;
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();

    }
    function testMinDollarIs5() public view {
        console.log(minUSD);
        assertEq(fundme.MINIMUM_USD(),5);
    }
    function testOwnerIsMsgSender() public view {

        //IMPORTANT: when checking ownership be midnful of the order in which contracts call eachother.

        assertEq(fundme.getOwner(),msg.sender);
    }

    //testing accuracy of price feeds

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();
        console.log(version);
        assertEq(version , 4);
    }
    function testPriceFeedData() public view{
        uint256 price = fundme.getCurrentPrice();
        console.log(price);
    }
    function testFundFailsWithoutEnoughEth() public{
        vm.expectRevert();
        fundme.fund{value:10e2}();
    }
    function testFundUpdatesFundedDataStructure() public{
        fundme.fund{value:10e18}();
        // console.log(fundme.getAddressToAmountFunded(address(this)));
        uint256 amountFunded = fundme.getAddressToAmountFunded(address(this));
        assertEq(amountFunded,10e18);
        

    }
}   