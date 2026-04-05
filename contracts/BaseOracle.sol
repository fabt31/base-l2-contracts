// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
    function decimals() external view returns (uint8);
}

/**
 * @title BaseOracle
 * @dev Chainlink price feed oracle wrapper for Base L2
 */
contract BaseOracle {
    mapping(address => address) public priceFeeds;
    address public owner;

    // Chainlink ETH/USD feed on Base
    address public constant ETH_USD_FEED = 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
    // USDC/USD feed on Base
    address public constant USDC_USD_FEED = 0x7e860098F58bBFC8648a4311b374B1D669a2bc9a;

    constructor() { owner = msg.sender; }

    function addFeed(address token, address feed) external {
        require(msg.sender == owner, "Not owner");
        priceFeeds[token] = feed;
    }

    function getPrice(address token) external view returns (int256 price, uint8 decimals) {
        address feed = priceFeeds[token];
        require(feed != address(0), "No feed");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(feed);
        (, price,,,) = priceFeed.latestRoundData();
        decimals = priceFeed.decimals();
    }

    function getETHPrice() external view returns (int256) {
        AggregatorV3Interface feed = AggregatorV3Interface(ETH_USD_FEED);
        (, int256 price,,,) = feed.latestRoundData();
        return price; // 8 decimals
    }
}
