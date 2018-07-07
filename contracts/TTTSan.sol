pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "zeppelin-solidity/contracts//ownership/Ownable.sol";


contract TTTToken {
  function transfer(address _to, uint256 _amount) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function balanceOf(address tokenOwner) public constant returns (uint balance);
}

contract TTTSan is ERC721Token, Ownable {

  address public wallet = 0x5BcFCbdE79895D3D6A115Baf5386ae5463df2aAF;
  address public tttTokenAddress = 0x3a518A5F5AC3F3dBF4ECd6b91dfBbb8422832996;
  address public marketAddress;

  uint256 public sanTTTCost;
  uint256 public sanMaxLength;
  uint256 public sanMinLength;

  string public baseUrl = "https://thetiptoken.io/arv/img/";

  mapping(string=>bool) sanOwnership;
  mapping(address=>uint256) sanSlots;
  mapping(string=>uint256) sanNameToId;
  mapping(string=>address) sanNameToAddress;
  mapping(address=>string[]) ownerToSanName;

  struct SAN {
    string sanName;
    uint256 timeAlive;
    uint256 timeLastMove;
    address prevOwner;
  }

  SAN[] public sans;

  TTTToken ttt;

  modifier isMarketAddress() {
		require(msg.sender == marketAddress);
		_;
	}

  event SanMinted(address sanOwner, uint256 sanId, string sanName);
  event SanSlotsPurchase(address sanOwner, uint256 amt);

  function TTTSan() ERC721Token("TTTSAN", "TTTS") {
    sanTTTCost = 2 ether;
    sanMaxLength = 16;
    sanMinLength = 2;
    ttt = TTTToken(tttTokenAddress);
    // gen0 san
  /* "NeverGonnaGiveYouUp.NeverGonnaLetYouDown" */
    SAN memory s = SAN({
        sanName: "NeverGonnaGiveYouUp.NeverGonnaLetYouDown",
        timeAlive: block.timestamp,
        timeLastMove: block.timestamp,
        prevOwner: msg.sender
    });
    uint256 sanId = sans.push(s) - 1;
    _mint(msg.sender, sanId);
    sanNameToId["NeverGonnaGiveYouUp.NeverGonnaLetYouDown"] = sanId;
    sanNameToAddress["NeverGonnaGiveYouUp.NeverGonnaLetYouDown"] = msg.sender;
    ownerToSanName[msg.sender].push("NeverGonnaGiveYouUp.NeverGonnaLetYouDown");
    SanMinted(msg.sender, sanId, "NeverGonnaGiveYouUp.NeverGonnaLetYouDown");
  }

  function sanMint(string _sanName, string _sanageUri) external returns (string) {
    assert(sanSlots[msg.sender] >= 1);
    string memory sn = SANitize(_sanName);
    SAN memory s = SAN({
        sanName: sn,
        timeAlive: block.timestamp,
        timeLastMove: block.timestamp,
        prevOwner: msg.sender
    });
    uint256 sanId = sans.push(s) - 1;
    _mint(msg.sender, sanId);

    _setTokenURI(sanId, _sanageUri);

    sanNameToId[sn] = sanId;
    sanNameToAddress[sn] = msg.sender;
    ownerToSanName[msg.sender].push(sn);
    sanSlots[msg.sender] = sanSlots[msg.sender].sub(1);
    SanMinted(msg.sender, sanId, sn);
    return sn;
  }

  function getSANOwner(uint256 _sanId) public returns (address) {
    return ownerOf(_sanId);
  }

  function getSanIdFromName(string _sanName) public view returns (uint256) {
    return sanNameToId[_sanName];
  }

  function getSanName(uint256 _sanId) public view returns (string) {
    return sans[_sanId].sanName;
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
    return SANitize(_sanName);
  }

  function buySanSlot(address _sanOwner,  uint256 _tip) external returns(bool) {
    require(_tip >= sanTTTCost);
    sanSlots[_sanOwner] = sanSlots[_sanOwner].add(1);
    ttt.transferFrom(msg.sender, wallet, _tip);
    emit SanSlotsPurchase(_sanOwner, 1);
    return true;
  }

  function setSanPrevOwner(uint256 _sanId, address _prevOwner) external isMarketAddress {
    SAN s = sans[_sanId];
    s.prevOwner = _prevOwner;
  }

  // OWNER FUNCTIONS

  function setSanTTTCost(uint256 _cost) external onlyOwner {
    require(_cost > 0);
    sanTTTCost = _cost;
  }

  function setSanLength(uint256 _length, uint256 _pos) external onlyOwner {
    require(_length > 0);
    if(_pos == 0) sanMinLength = _length;
    else sanMaxLength = _length;
  }

  function ownerAddSanSlot(address _sanOwner, uint256 _slotCount) external onlyOwner {
    require(_slotCount > 0);
    sanSlots[_sanOwner] = sanSlots[_sanOwner].add(_slotCount);
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
    // TODO
  }

  function emptyContract() public onlyOwner {
    uint256 b = ttt.balanceOf(this);
    ttt.transfer(msg.sender, b);
  }

  // owner can mint special sans for an address
  function specialSanMint(string _sanName, string _sanageUri, address _address) external onlyOwner returns (string) {
    SAN memory s = SAN({
        sanName: _sanName,
        timeAlive: block.timestamp,
        timeLastMove: block.timestamp,
        prevOwner: _address
    });
    uint256 sanId = sans.push(s) - 1;
    _mint(_address, sanId);

    // _setTokenURI(sanId, strConcat(baseUrl, _sanName));
    _setTokenURI(sanId, _sanageUri);

    sanNameToId[_sanName] = sanId;
    sanNameToAddress[_sanName] = _address;
    ownerToSanName[_address].push(_sanName);
    SanMinted(_address, sanId, _sanName);
    return _sanName;
  }

  // INTERNAL FUNCTIONS

  function SANitize(string _sanName) internal returns(string) {
    string memory sn = sanToLower(_sanName);
    assert(isValidSan(sn));
    assert(!sanOwnership[sn]);
    sanOwnership[sn] = true;
    return sn;
  }

  function isValidSan(string _sanName) internal returns(bool) {
    bytes memory wb = bytes(_sanName);
    uint slen = wb.length;
    assert(slen <= sanMaxLength && slen > sanMinLength);
    bytes1 space = bytes1(0x20);
    bytes1 period = bytes1(0x2E);
    bytes1 e = bytes1(0x65);
    bytes1 t = bytes1(0x74);
    bytes1 h = bytes1(0x68);
    uint dCount = 0;
    uint eCount = 0;
    uint eth = 0;
    for(uint i = 0; i < slen; i++) {
        if(wb[i] == space) return false;
        else if(wb[i] == period) {
          dCount = dCount + 1;
          // only 1 '.'
          if(dCount > 1) return false;
          eCount = 1;
        } else if(eCount > 0 && eCount < 5) {
          if(eCount == 1) if(wb[i] == e) eth = eth + 1;
          if(eCount == 2) if(wb[i] == t) eth = eth + 1;
          if(eCount == 3) if(wb[i] == h) eth = eth + 1;
          eCount = eCount + 1;
        }
    }
    if(dCount == 0) return false;
    if((eth == 3 && eCount == 4) || eCount == 1) return false;
    return true;
  }

  function sanToLower(string _sanName) internal returns(string) {
    bytes memory b = bytes(_sanName);
    for(uint i = 0; i < b.length; i++) {
      b[i] = byteToLower(b[i]);
    }
    return string(b);
  }

  function byteToLower(bytes1 _b) internal view returns (bytes1) {
    if(_b >= bytes1(0x41) && _b <= bytes1(0x5A))
      return bytes1(uint8(_b) + 32);
    return _b;
  }

  function strConcat(string _a, string _b) internal pure returns (string) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    string memory ab = new string(_ba.length + _bb.length);
    bytes memory bab = bytes(ab);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
    return string(bab);
  }

}
