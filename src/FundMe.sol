// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Get funds from users
// withdraw funds 
// set min funding value in usd


//interface for recieving price feeds 
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
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
    mapping(address funder => uint256 amountFunded) private addressToAmountFunded;
    address private immutable owner;
    AggregatorV3Interface private s_priceFeed;
    

    constructor(address price_feed_a) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(price_feed_a);
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
    function getCurrentPrice() public view returns (int256){
        (, int256 price,,,) = s_priceFeed.latestRoundData();
        return price;
    }
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }
    function getAddressToAmountFunded(address fundingAddress) public view returns(uint256){
        return addressToAmountFunded[fundingAddress];
    }
    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }
    function getFunder(uint256 index) public view returns(address){
        return funders[index];
    }
    function getOwner() public view returns(address){
        return owner;
    }
    function getPriceFeed() public view returns (AggregatorV3Interface){
        return s_priceFeed;

    }

    modifier onlyOwner() {
        if(msg.sender != owner){
            revert NotOwner();
        }
        _;
    }
    
   
 }