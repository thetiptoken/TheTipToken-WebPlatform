// @title The Tip Tokn SAN (Short Address Name)
// @author Jonathan Teel (jonathan.teel@thetiptoken.io)
// @dev First 500 SANs do no require a slot

pragma solidity ^0.4.24;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract TTTToken {
  function transfer(address _to, uint256 _amount) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function balanceOf(address tokenOwner) public constant returns (uint balance);
}

contract TTTSan is ERC721Token, Ownable {

  address public wallet = 0x515165A6511734A4eFB5Cfb531955cf420b2725B;
  address public tttTokenAddress = 0x24358430f5b1f947B04D9d1a22bEb6De01CaBea2;
  address public marketAddress;

  uint256 public sanTTTCost;
  uint256 public sanMaxLength;
  uint256 public sanMinLength;
  uint256 public sanMaxAmount;
  uint256 public sanMaxFree;
  uint256 public sanCurrentTotal;

  string public baseUrl = "https://thetiptoken.io/arv/img/";

  mapping(string=>bool) sanOwnership;
  mapping(address=>uint256) sanSlots;
  mapping(address=>uint256) sanOwnerAmount;
  mapping(string=>uint256) sanNameToId;
  mapping(string=>address) sanNameToAddress;

  struct SAN {
    string sanName;
    uint256 timeAlive;
    uint256 timeLastMove;
    address prevOwner;
    string sanageLink;
  }

  SAN[] public sans;

  TTTToken ttt;

  modifier isMarketAddress() {
		require(msg.sender == marketAddress);
		_;
	}

  event SanMinted(address sanOwner, uint256 sanId, string sanName);
  event SanSlotPurchase(address sanOwner, uint256 amt);
  event SanCostUpdated(uint256 cost);
  event SanLengthReqChange(uint256 sanMinLength, uint256 sanMaxLength);
  event SanMaxAmountChange(uint256 sanMaxAmount);

  constructor() public ERC721Token("TTTSAN", "TTTS") {
    sanTTTCost = 10 ether;
    sanMaxLength = 16;
    sanMinLength = 2;
    sanMaxAmount = 100;
    sanMaxFree = 500;
    ttt = TTTToken(tttTokenAddress);
    // gen0 san
  /* "NeverGonnaGiveYouUp.NeverGonnaLetYouDown" */
    string memory gen0 = "NeverGonnaGiveYouUp.NeverGonnaLetYouDown";
    SAN memory s = SAN({
        sanName: gen0,
        timeAlive: block.timestamp,
        timeLastMove: block.timestamp,
        prevOwner: msg.sender,
        sanageLink: "0x"
    });
    uint256 sanId = sans.push(s).sub(1);
    sanOwnership[gen0] = true;
    _sanMint(sanId, msg.sender, "gen0.jpeg", gen0);
  }

  function sanMint(string _sanName, string _sanageUri) external returns (string) {
    // first 500 SANs do not require a slot
    if(sanCurrentTotal > sanMaxFree)
      require(sanSlots[msg.sender] >= 1, "no san slots available");
    string memory sn = sanitize(_sanName);
    SAN memory s = SAN({
        sanName: sn,
        timeAlive: block.timestamp,
        timeLastMove: block.timestamp,
        prevOwner: msg.sender,
        sanageLink: _sanageUri
    });
    uint256 sanId = sans.push(s).sub(1);
    sanOwnership[sn] = true;
    if(sanCurrentTotal > sanMaxFree)
      sanSlots[msg.sender] = sanSlots[msg.sender].sub(1);
    _sanMint(sanId, msg.sender, _sanageUri, sn);
    return sn;
  }

  function getSANOwner(uint256 _sanId) public view returns (address) {
    return ownerOf(_sanId);
  }

  function getSanIdFromName(string _sanName) public view returns (uint256) {
    return sanNameToId[_sanName];
  }

  function getSanName(uint256 _sanId) public view returns (string) {
    return sans[_sanId].sanName;
  }

  function getSanageLink(uint256 _sanId) public view returns (string) {
    return sans[_sanId].sanageLink;
  }

  function getSanTimeAlive(uint256 _sanId) public view returns (uint256) {
    return sans[_sanId].timeAlive;
  }

  function getSanTimeLastMove(uint256 _sanId) public view returns (uint256) {
    return sans[_sanId].timeLastMove;
  }

  function getSanPrevOwner(uint256 _sanId) public view returns (address) {
    return sans[_sanId].prevOwner;
  }

  function getAddressFromSan(string _sanName) public view returns (address) {
    return sanNameToAddress[_sanName];
  }

  function getSanSlots(address _sanOwner) public view returns(uint256) {
    return sanSlots[_sanOwner];
  }

  // used for initial check to not waste gas
  function getSANitized(string _sanName) external view returns (string) {
    return sanitize(_sanName);
  }

  function buySanSlot(address _sanOwner,  uint256 _tip) external returns(bool) {
    require(_tip >= sanTTTCost, "tip less than san cost");
    require(sanSlots[_sanOwner] < sanMaxAmount, "max san slots owned");
    sanSlots[_sanOwner] = sanSlots[_sanOwner].add(1);
    ttt.transferFrom(msg.sender, wallet, _tip);
    emit SanSlotPurchase(_sanOwner, 1);
    return true;
  }

  function marketSale(uint256 _sanId, string _sanName, address _prevOwner, address _newOwner) external isMarketAddress {
    SAN storage s = sans[_sanId];
    s.prevOwner = _prevOwner;
    s.timeLastMove = block.timestamp;
    sanNameToAddress[_sanName] = _newOwner;
    // no slot movements for first 500 SANs
    if(sanCurrentTotal > sanMaxFree) {
      sanSlots[_prevOwner] = sanSlots[_prevOwner].sub(1);
      sanSlots[_newOwner] = sanSlots[_newOwner].add(1);
    }
    sanOwnerAmount[_prevOwner] = sanOwnerAmount[_prevOwner].sub(1);
    sanOwnerAmount[_newOwner] = sanOwnerAmount[_newOwner].add(1);
  }

  function() public payable { revert(); }

  // OWNER FUNCTIONS

  function setSanTTTCost(uint256 _cost) external onlyOwner {
    sanTTTCost = _cost;
    emit SanCostUpdated(sanTTTCost);
  }

  function setSanLength(uint256 _length, uint256 _pos) external onlyOwner {
    require(_length > 0);
    if(_pos == 0) sanMinLength = _length;
    else sanMaxLength = _length;
    emit SanLengthReqChange(sanMinLength, sanMaxLength);
  }

  function setSanMaxAmount(uint256 _amount) external onlyOwner {
    sanMaxAmount = _amount;
    emit SanMaxAmountChange(sanMaxAmount);
  }

  function setSanMaxFree(uint256 _sanMaxFree) external onlyOwner {
    sanMaxFree = _sanMaxFree;
  }

  function ownerAddSanSlot(address _sanOwner, uint256 _slotCount) external onlyOwner {
    require(_slotCount > 0 && _slotCount <= sanMaxAmount);
    require(sanSlots[_sanOwner] < sanMaxAmount);
    sanSlots[_sanOwner] = sanSlots[_sanOwner].add(_slotCount);
  }

  // owner can add slots in batches, 100 max
  function ownerAddSanSlotBatch(address[] _sanOwner, uint256[] _slotCount) external onlyOwner {
    require(_sanOwner.length == _slotCount.length);
    require(_sanOwner.length <= 100);
    for(uint8 i = 0; i < _sanOwner.length; i++) {
      require(_slotCount[i] > 0 && _slotCount[i] <= sanMaxAmount, "incorrect slot count");
      sanSlots[_sanOwner[i]] = sanSlots[_sanOwner[i]].add(_slotCount[i]);
      require(sanSlots[_sanOwner[i]] <= sanMaxAmount, "max san slots owned");
    }
  }

  function setMarketAddress(address _marketAddress) public onlyOwner {
    marketAddress = _marketAddress;
  }

  function setBaseUrl(string _baseUrl) public onlyOwner {
    baseUrl = _baseUrl;
  }

  function setOwnerWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

  function updateTokenUri(uint256 _sanId, string _newUri) public onlyOwner {
    SAN storage s = sans[_sanId];
    s.sanageLink = _newUri;
    _setTokenURI(_sanId, strConcat(baseUrl, _newUri));
  }

  function emptyTTT() external onlyOwner {
    ttt.transfer(msg.sender, ttt.balanceOf(address(this)));
  }

  function emptyEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }

  // owner can mint special sans for an address
  function specialSanMint(string _sanName, string _sanageUri, address _address) external onlyOwner returns (string) {
    SAN memory s = SAN({
        sanName: _sanName,
        timeAlive: block.timestamp,
        timeLastMove: block.timestamp,
        prevOwner: _address,
        sanageLink: _sanageUri
    });
    uint256 sanId = sans.push(s).sub(1);
    _sanMint(sanId, _address, _sanageUri, _sanName);
    return _sanName;
  }

  // INTERNAL FUNCTIONS

  function sanitize(string _sanName) internal view returns(string) {
    string memory sn = sanToLower(_sanName);
    require(isValidSan(sn), "san is not valid");
    require(!sanOwnership[sn], "san is not unique");
    return sn;
  }

  function _sanMint(uint256 _sanId, address _owner, string _sanageUri, string _sanName) internal {
    require(sanOwnerAmount[_owner] < sanMaxAmount, "max san owned");
    sanNameToId[_sanName] = _sanId;
    sanNameToAddress[_sanName] = _owner;
    sanOwnerAmount[_owner] = sanOwnerAmount[_owner].add(1);
    sanCurrentTotal = sanCurrentTotal.add(1);
    _mint(_owner, _sanId);
    _setTokenURI(_sanId, strConcat(baseUrl, _sanageUri));
    emit SanMinted(_owner, _sanId, _sanName);
  }

  function isValidSan(string _sanName) internal view returns(bool) {
    bytes memory wb = bytes(_sanName);
    uint slen = wb.length;
    if (slen > sanMaxLength || slen <= sanMinLength) return false;
    bytes1 space = bytes1(0x20);
    bytes1 period = bytes1(0x2E);
    // san can not end in .eth - added to avoid conflicts with ens
    bytes1 e = bytes1(0x65);
    bytes1 t = bytes1(0x74);
    bytes1 h = bytes1(0x68);
    uint256 dCount = 0;
    uint256 eCount = 0;
    uint256 eth = 0;
    for(uint256 i = 0; i < slen; i++) {
        if(wb[i] == space) return false;
        else if(wb[i] == period) {
          dCount = dCount.add(1);
          // only 1 '.'
          if(dCount > 1) return false;
          eCount = 1;
        } else if(eCount > 0 && eCount < 5) {
          if(eCount == 1) if(wb[i] == e) eth = eth.add(1);
          if(eCount == 2) if(wb[i] == t) eth = eth.add(1);
          if(eCount == 3) if(wb[i] == h) eth = eth.add(1);
          eCount = eCount.add(1);
        }
    }
    if(dCount == 0) return false;
    if((eth == 3 && eCount == 4) || eCount == 1) return false;
    return true;
  }

  function sanToLower(string _sanName) internal pure returns(string) {
    bytes memory b = bytes(_sanName);
    for(uint256 i = 0; i < b.length; i++) {
      b[i] = byteToLower(b[i]);
    }
    return string(b);
  }

  function byteToLower(bytes1 _b) internal pure returns (bytes1) {
    if(_b >= bytes1(0x41) && _b <= bytes1(0x5A))
      return bytes1(uint8(_b) + 32);
    return _b;
  }

  function strConcat(string _a, string _b) internal pure returns (string) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    string memory ab = new string(_ba.length.add(_bb.length));
    bytes memory bab = bytes(ab);
    uint256 k = 0;
    for (uint256 i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
    return string(bab);
  }

}
