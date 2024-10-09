// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

contract Fundme {

    mapping (address=>uint256) public Addresstovaluefund;

    address[]public funders;

    address public  owner;


    constructor()public{
        owner = msg.sender;
    }

    function fund()public payable {
        uint256 minimumusd = 50 * 10 ** 9;

        require(getrate(msg.value) >= minimumusd , "you need pay more ETH");
        
        Addresstovaluefund[msg.sender]+=msg.value;
        funders.push(msg.sender);
    }
    

    // function getversion() public view returns (uint256){
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //     return  priceFeed.version() ;
    // }

    function getprice() public  view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData() ;
        return uint256(answer) ;
    }

    function getrate (uint256 ethamount)public view returns (uint256){
        uint256 ethprice = getprice();
        uint256 ethamounttousd = uint256(ethprice) * ethamount / 1000000000000000000;
        return ethamounttousd;
    }

    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }

    function withdraw()payable onlyowner public{
    
        payable (msg.sender).transfer(address(this).balance);
        for(uint256 funderindex=0; funderindex < funders.length ; funderindex++){
            address funder = funders[funderindex];
            Addresstovaluefund[funder]=0;
        }
        funders = new address[](0);
    }


}
