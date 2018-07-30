/// @title The Tip Tokn SAN marketplace
/// @author Jonathan Teel (jonathan.teel@thetiptoken.io)
/// @dev Marketplace for trading TTTSan tokens

pragma solidity ^0.4.24;

import "./TTTSan.sol";

contract TTTSanMarket is Ownable {

  address public tttTokenAddress = 0x3a518A5F5AC3F3dBF4ECd6b91dfBbb8422832996; // TESTNET
  TTTToken ttt;
  address public sanAddress = 0x6fa333ac2e2737a522b5d28bf1a1ea88d2a76f3a; // TESTNET
  TTTSan tttSan;

  mapping(uint256=>bool) isSanIdOnMarket;
  mapping(address=>uint256) marketSanAddresOwnerToId;
  mapping(uint256=>uint256) sanIdToMarketIdx;

  enum MarketSANType {Direct, Auction}
  struct MarketSAN {
    uint256 sanId;
    string sanName;
    uint256 timeToMarket;
    address owner;
    uint256 bidMin;
    uint256 currentBid;
    MarketSANType bidType;
    uint256 bidAuctionTime;
    bool claimed;
  }
  MarketSAN[] public marketSans;

  event SanAddedToMarket(uint256 sanId, uint256 price);
  event SanMarketDirectPurchase(address newOwner, uint256 sanId, uint256 price, uint256 time);
  event MarketBidRefund(address to, uint256 sanId);

  constructor() {
    ttt = TTTToken(tttTokenAddress);
    tttSan = TTTSan(sanAddress);
  }

  function getMarketSanTTM(uint256 _idx) public view returns(uint256) {
    return marketSans[_idx].timeToMarket;
  }

  function getMarketSanOwner(uint256 _idx) public view returns(address) {
    return marketSans[_idx].owner;
  }

  function getMarketSanBidMin(uint256 _idx) public view returns(uint256) {
    return marketSans[_idx].bidMin;
  }

  function getMarketSanBidAuctionTime(uint256 _idx) public view returns(uint256) {
    return marketSans[_idx].bidAuctionTime;
  }

  function getMarketSanInfo(uint256 _idx) public view returns(
      uint256 minBid, string sanName, uint256 sanId
    ) {
    MarketSAN storage ms = marketSans[_idx];
    minBid = ms.bidMin;
    sanName = ms.sanName;
    sanId = ms.sanId;
  }

  function addSanToMarket(uint256 _sanId, string _sanName, uint256 _price) external {
    require(tttSan.ownerOf(_sanId) == msg.sender, "msg.sender is not san owner");
    require(!isSanIdOnMarket[_sanId], "san is on market already");
    MarketSAN memory ms = MarketSAN({
        sanId: _sanId,
        sanName: _sanName,
        timeToMarket: block.timestamp,
        owner: msg.sender,
        bidMin: _price,
        currentBid: 0,
        bidType: MarketSANType.Direct,
        bidAuctionTime: 0,
        claimed: false
    });

    uint256 marketId = marketSans.push(ms) - 1;
    isSanIdOnMarket[_sanId] = true;
    marketSanAddresOwnerToId[msg.sender] = _sanId;
    sanIdToMarketIdx[_sanId] = marketId;
    tttSan.transferFrom(msg.sender, this, _sanId);
    emit SanAddedToMarket(_sanId, _price);
  }

  function owns(uint256 _sanId, address _owner) internal view returns (bool) {
    return (tttSan.ownerOf(_sanId) == _owner);
  }

  function marketDirectPurchase(uint256 _sanId, uint256 _amount) external {
    require(isSanIdOnMarket[_sanId], "san is not on market");
    require(ttt.balanceOf(msg.sender) >= _amount, "min balance not met");
    uint256 idxOfSan = sanIdToMarketIdx[_sanId];
    MarketSAN storage ms = marketSans[idxOfSan];
    assert(_amount >= ms.bidMin);
    isSanIdOnMarket[_sanId] = false;
    tttSan.marketSale(_sanId, ms.sanName, ms.owner, msg.sender);
    ttt.transferFrom(msg.sender, ms.owner, _amount);
    tttSan.transferFrom(this, msg.sender, _sanId);
    removeFromMarketSAN(idxOfSan);
    emit SanMarketDirectPurchase(msg.sender, _sanId, _amount, block.timestamp);
  }

  function refundMarketBid(uint256 _sanId) external onlyOwner {
    require(isSanIdOnMarket[_sanId], "san is not on market");
    isSanIdOnMarket[_sanId] = false;
    uint256 idxOfSan = sanIdToMarketIdx[_sanId];
    MarketSAN storage ms = marketSans[idxOfSan];
    tttSan.transferFrom(this, ms.owner, _sanId);
    emit MarketBidRefund(ms.owner, _sanId);
    removeFromMarketSAN(idxOfSan);
  }

  function setSanAddress(address _sanAddress) external onlyOwner {
    sanAddress = _sanAddress;
    tttSan = TTTSan(sanAddress);
  }

  function getMarketSanCount() external view returns(uint256) {
    return marketSans.length;
  }

  function getMarketSanIdAt(uint256 _idx) external view returns(uint256) {
    return marketSans[_idx].sanId;
  }

  function removeFromMarketSAN(uint256 _idx) internal {
    require(_idx < marketSans.length);
    for (uint256 i = _idx; i < marketSans.length - 1; i++){
        marketSans[i] = marketSans[i+1];
    }
    delete marketSans[marketSans.length-1];
    marketSans.length--;
  }

}
