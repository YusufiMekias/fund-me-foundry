// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Get funds from users
// withdraw funds 
// set min funding value in usd


//interface for recieving price feeds 
import {PriceConverter} from "./PriceConverter.sol";

// solhint-disable-next-line interface-starts-with-i

// adding error codes
error NotOwner();
error AmountTooSmall();
error CallFailed();


contract FundMe {

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    address public immutable owner;

    constructor( ) {
        owner = msg.sender;
    }

    function fund() public payable{
        // allows users to send funds
        //have a min $ amount to send
        if (msg.value.getConversionRate() >= MINIMUM_USD){
            revert AmountTooSmall();
        }
                 
         /**
          * @dev Withdraws all funds from the contract to the owner's address. 
          * This function can only be called by the contract owner.
          * The withdrawal process iterates over each funder and transfers their contribution back to them,
          * clearing out the dictionary position of the current funder because we are withdrawing the funds.
          * Finally, it resets the funders array to an empty one. 
          * This function is marked as payable so that it can receive Ethers when called.
          * @notice The owner should call this function carefully because it may lose all its balance if not used properly.
          */
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            //clear out the dictionary position of the current funder because we are withdrawing the funds
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        //transfer
        // payable(msg.sender).transfer(address(this).balance);
        // //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"send failed");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        if(!callSuccess){
            revert CallFailed();
        }
    }
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }
    modifier onlyOwner() {
        if(msg.sender != owner){
            revert NotOwner();
        }
        _;
    }
    
   
 }