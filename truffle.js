
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    ropsten: {
		 provider: function() {

		 },
		 network_id: 3,
		 gas: 4612388,
		 gasPrice: 1000000
	 }
  }
};
