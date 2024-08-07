// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//importing the Test contract for forge to assist

//import {Vm} from "../lib/forge-std/src/vm.sol";
//import {StdAssertions} from "../lib/forge-std/src/StdAssertions.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";



//different types of tests
//1.unit testing
//      testing specific part of our code
//2. integration
//      testion how our code works with other parts of our code
//3. forked
//      testing our code on a simulated real environment
//4. staging
//      testing our code in a real environment that is not prod

contract FundMeTest is Test {
    FundMe fundme;
    uint256 number;
    uint256 minUSD;
    function setUp() external {
        fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        number = 2;

    }
    function testMinDollarIs5() public view {
        console.log(minUSD);
        assertEq(fundme.MINIMUM_USD(),5e18);
    }
    function testOwnerIsMsgSender() public view {

        //IMPORTANT: when checking ownership be midnful of the order in which contracts call eachother.
        //msg.sender is not the right thing to compare to to test ownership, the incorrect code will be left here commented
        //out to show this example
        //CORRECT way to do this is if the current contract is the "owner" then compare msg.sender to "address(this)"
        //INCORRECT WAY ----->
        // console.log(fundme.owner());
        // console.log(msg.sender);
        // assertEq(fundme.owner(), msg.sender);

        //CORRECT WAY +++++>
        assertEq(fundme.getOwner(),address(this));
    }

    //testing accuracy of price feeds

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();
        console.log(version);
        assertEq(version , 4);
    }
    function testPriceFeedData() public view{
        int256 price = fundme.getCurrentPrice();
        console.log(price);
    }
}   