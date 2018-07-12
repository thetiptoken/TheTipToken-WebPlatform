var HDWalletProvider = require("truffle-hdwallet-provider");


module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    ropsten: {
		 provider: function() {
			// return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/cQbFFhAGUdQG8fXxrKF8", 0)
		 },
		 network_id: 3,
		 gas: 4612388,
		 gasPrice: 1000000
	 }
  }
};
