var marketSanAbi =
[
  {
    "constant": true,
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "tttTokenAddress",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "marketSans",
    "outputs": [
      {
        "name": "sanId",
        "type": "uint256"
      },
      {
        "name": "sanName",
        "type": "string"
      },
      {
        "name": "timeToMarket",
        "type": "uint256"
      },
      {
        "name": "owner",
        "type": "address"
      },
      {
        "name": "bidMin",
        "type": "uint256"
      },
      {
        "name": "currentBid",
        "type": "uint256"
      },
      {
        "name": "bidType",
        "type": "uint8"
      },
      {
        "name": "bidAuctionTime",
        "type": "uint256"
      },
      {
        "name": "claimed",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "sanId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "price",
        "type": "uint256"
      }
    ],
    "name": "SanAddedToMarket",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "newOwner",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "sanId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "price",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "time",
        "type": "uint256"
      }
    ],
    "name": "SanMarketDirectPurchase",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "to",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "sanId",
        "type": "uint256"
      }
    ],
    "name": "MarketBidRefund",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_idx",
        "type": "uint256"
      }
    ],
    "name": "getMarketSanTTM",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_idx",
        "type": "uint256"
      }
    ],
    "name": "getMarketSanOwner",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_idx",
        "type": "uint256"
      }
    ],
    "name": "getMarketSanBidMin",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_idx",
        "type": "uint256"
      }
    ],
    "name": "getMarketSanBidAuctionTime",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_idx",
        "type": "uint256"
      }
    ],
    "name": "getMarketSanInfo",
    "outputs": [
      {
        "name": "minBid",
        "type": "uint256"
      },
      {
        "name": "sanName",
        "type": "string"
      },
      {
        "name": "sanId",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_sanId",
        "type": "uint256"
      },
      {
        "name": "_sanName",
        "type": "string"
      },
      {
        "name": "_price",
        "type": "uint256"
      }
    ],
    "name": "addSanToMarket",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_sanId",
        "type": "uint256"
      },
      {
        "name": "_amount",
        "type": "uint256"
      }
    ],
    "name": "marketDirectPurchase",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_sanId",
        "type": "uint256"
      }
    ],
    "name": "refundMarketBid",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_sanAddress",
        "type": "address"
      }
    ],
    "name": "setSanAddress",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "getMarketSanCount",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_idx",
        "type": "uint256"
      }
    ],
    "name": "getMarketSanIdAt",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }
]
