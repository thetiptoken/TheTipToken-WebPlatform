var contractAddress = "0x24358430f5b1f947B04D9d1a22bEb6De01CaBea2";
var sanAddress = "0x799946d6B94394F3859dad6b66B7fb60E6Cd899A";
var marketSanAddress = "0x36f024d74407c65f71fbd10e18e877bf692c466a";
var wallet = "0x515165A6511734A4eFB5Cfb531955cf420b2725B";
var token;
var san;
var marketSan;

var BigNumber = require('bignumber.js');

function fromBigNumberWeiToEth(bigNum) {
  return bigNum.dividedBy(new BigNumber(10).pow(18)).toNumber();
}

function timeConvert(UNIXtimestamp) {
  var a = new Date(UNIXtimestamp * 1000);
  var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var time = a.getDate() + ' ' + months[a.getMonth()] + ' ' + a.getFullYear() + ' ' + a.getHours() + ':' + a.getMinutes();
  return time;
}

function ageConvert(ageMs) {
  var d, h, m;
  m = Math.floor(Math.floor(ageMs / 1000) / 60);
  h = Math.floor(m / 60);
  m = m % 60;
  d = Math.floor(h / 24);
  h = h % 24;
  return d + " Days, " + h + " Hours, " + m + " Minutes";
}

function tttSendGET(q,s) {
    s = (s) ? s : window.location.search;
    return s.split('=')[1];
}

function sanToImage(sanName, addr) {
  var bytes = [];
  var bytes2 = [];
  var img = new Array();
  for(var i = 0; i < sanName.length; ++i) {
    var code = sanName.charCodeAt(i);
    bytes.push((code & 0xFF00) >> 8);
    bytes.push(code & 0xFF);
  }
  for(var i = bytes.length; i < 32; i++) bytes.push(0xFF);

  for(var i = 0; i < bytes.length; i++) {
    bytes2.push(bytes[i] % 32);
  }
  for(var i = 0; i < bytes.length; i++) {
      if(bytes[i] % i == 0) img[i] = 1;
      else img[i] = 0;
      img[i] = new Array();
      for(var j = 0; j < bytes2.length; j++) {
          if(bytes2[j] % j == 0) img[i][j] = 1;
          else img[i][j] = 0;
      }
  }

  $.ajax({
    url: "https://thetiptoken.io/arv/sanage.php",
    type: 'post',
    data: { "sanb" : img },
    success: function(link) {
      var img = link + ".png";
      console.log(link);
    //  if(link.includes("https://thetiptoken.io/arv/img")) {
        san.sanMint(sanName, img, function(err, res) {
          if(err) {
            // delete link TODO
            var errOut = " Minting Error : " + err;
            $("#mintFail").append(errOut).show();
          }
          else {
            var sucOut = '<a href="https://ropsten.etherscan.io/tx/'+res+'" target="_blank">'+res+'</a>';
            $("#txSuc").append(sucOut).show();
            var outp = 'Your SANage : <img src=https://thetiptoken.io/arv/img/'+img+'" alt="icon" height="128px" width="128px" />'
            $("#sanaged").html(outp);
          }
        });
      //}
    }
  });
}

App = {
  web3Provider: null,

  init: function() {

    var tts = tttSendGET("sanTo");
    if(tts) $("#receiver").val(tts);
    else console.log("ttt is null");

    $('.navigation-menu li.has-submenu a[href="#"]').on('click', function (e) {
        if ($(window).width() < 992) {
            e.preventDefault();
            $(this).parent('li').toggleClass('open').find('.submenu:first').toggleClass('open');
        }
    });

    $(window).load(function () {
        $('#status').fadeOut();
        $('#preloader').delay(350).fadeOut('slow');
        $('body').delay(350).css({
            'overflow': 'visible'
        });

    });

    $('.slimscroll-noti').slimScroll({
        height: '230px',
        position: 'right',
        size: "5px",
        color: '#98a6ad',
        wheelStep: 10
    });

    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover();

    $('.toggle-search').on('click', function () {
        var targetId = $(this).data('target');
        var $searchBar;
        if (targetId) {
            $searchBar = $(targetId);
            $searchBar.toggleClass('open');
        }
    });

    var ft = '<div class="container-fluid"><div class="row"><div class="col-6">SAN address : ';
    ft += sanAddress + '</div><div class="col-6">TTT address : ';
    ft += contractAddress + '</div></div></div>';
    $('.footer').append(ft);

    return App.initWeb3();
  },

  initWeb3: function() {
    var page = window.location.pathname.split("/").pop();
    token = web3.eth.contract(abi).at(contractAddress);
    san = web3.eth.contract(sanAbi).at(sanAddress);
    web3.eth.getAccounts(function(a,b) {
      var modalStr = "";
      if (web3.currentProvider.publicConfigStore._state.networkVersion != "1") {
        modalStr += "- <b>Meta Mask is set to TEST NET</b><br>";
      }
      if(b[0] == undefined) {
        modalStr += "- <b>No Meta Mask Detected, please use Meta Mask to interact with the platform</b><br>";
      } else {
        modalStr += "<b>Using public key : " + b[0] + "</b><br><br>";
        App.refreshBalance();
        if(page == "san-manage.html") {
            App.setUserTabs();
        }
      }
      $("#tttInfoModalBody").append(modalStr);
    });

    if(page == "san-marketplace.html") {
      marketSan = web3.eth.contract(marketSanAbi).at(marketSanAddress);
      App.setMarketSans();
    }
    else if(page == "san-mint.html") {
      App.setUserSanSlots();
    }
    App.setSanTabs(function(err){console.log(err);});
  },

  buySanSlots: function() {
    var slotCost = 10;
    web3.eth.getAccounts(function(a,b) {
      token.approve(sanAddress, web3.toWei(slotCost, "ether"), {from: b[0]}, function(err, tx) {
        $("#sanSlotBuyTx").modal('show');
        $("#slotTx").append("<a href='https://ropsten.etherscan.io/tx/"+tx+"' target='_blank'>"+tx+"</a> (opens on new tab)");
        var interval = null;
        var max_attempts = 1000;
        var attempts = 0;
        if (err != null) {
          return;
        }
        var interval;
        var readBlock = function() {
          web3.eth.getTransactionReceipt(tx, function(e, txInfo) {
            if (e != null || txInfo == null) {
              return;
            }
            if (txInfo.blockNumber != null) {
                clearInterval(interval);
                if(txInfo.status == "0x0") {
                  console.log("tx failed");
                } else if(txInfo.status == "0x1") {
                  san.buySanSlot(b[0], web3.toWei(slotCost, "ether"), function(err, res) {
                    $("#sanSlotBuyTx").modal('show');
                    $("#slotTx").append("<br><br>Tx Id : <a href='https://ropsten.etherscan.io/tx/"+res+"' target='_blank'>" + res + "</a><br><br>Slot will show once the tx is complete. You can exit this window");
                  });
                }
            }
            if (attempts >= max_attempts) {
              clearInterval(interval);
              console.log("Transaction " + tx + " wasn't processed in " + attempts + " attempts");
            }
            attempts += 1;
          });
        };

        interval = setInterval(readBlock, 1000);
        readBlock();
      });

    });


  },

  setUserSanSlots: function() {
    web3.eth.getAccounts(function(a,b) {
      if(b[0] !== undefined)
        san.getSanSlots.call(b[0], function(err, amt) {
          $("#currSlotAmt").append(amt.toNumber());
        });
      else
        $("#currSlotAmt").append(0);
      san.sanTTTCost.call(function(err, cost) {
        $("#currSlotPrice").append(fromBigNumberWeiToEth(cost) + " TTT");
      });
    });
  },

  addSanToMarket: function() {
    var sanToSale = document.getElementById("sanToSale").value;
    var minBd = document.getElementById("sanMinBid").value;
    web3.eth.getAccounts(function(a,b) {
      san.getSanIdFromName(sanToSale, function(err, si){
        if(!err) {
          san.approve(marketSanAddress, si, {from: b[0]}, function(err, tx) {
            $("#sanMarketTx").modal('show');
            $("#slotTx").append("<a href='https://ropsten.etherscan.io/tx/"+tx+"' target='_blank'>"+tx+"</a> (opens on new tab)");
            var interval = null;
            var max_attempts = 1000;
            var attempts = 0;
            if (err != null) {
              return;
            }
            var interval;
            var readBlock = function() {
              web3.eth.getTransactionReceipt(tx, function(e, txInfo) {
                if (e != null || txInfo == null) {
                  return;
                }
                if (txInfo.blockNumber != null) {
                    clearInterval(interval);
                    if(txInfo.status == "0x0") {
                      console.log("tx failed");
                    } else if(txInfo.status == "0x1") {
                      marketSan.addSanToMarket(si, sanToSale, web3.toWei(minBd, "ether"), function(err, res) {
                        $("#sanMarketTx").modal('show');
                        $("#slotTx").append("<br><br>Tx Id : <a href='https://ropsten.etherscan.io/tx/"+res+"' target='_blank'>" + res + "</a><br><br>San will be added once the tx is complete. You can exit this window");
                      });
                    }
                }
                if (attempts >= max_attempts) {
                  clearInterval(interval);
                  console.log("Transaction " + tx + " wasn't processed in " + attempts + " attempts");
                }
                attempts += 1;
              });
            };

            interval = setInterval(readBlock, 1000);
            readBlock();
          });
        }
      });
    });
  },

  setMarketSans: function() {
    var stp = "";
    marketSan.getMarketSanCount(function(err, res){
      for(var i = 0; i < res; i++) {
        marketSan.getMarketSanInfo(i, function(err, mb){
          var row = "<tr><td>"+mb[2]+"</td><td>"+mb[1]+"</td><td>"+fromBigNumberWeiToEth(mb[0])+" TTT</td></tr>";
          $("#sanMTbl > tbody").append(row);
        });
      }
    });
  },

  buyMarketSan: function() {
    var sanId = document.getElementById("sanToBuy").value;
    var minBd = document.getElementById("sanBid").value;
    web3.eth.getAccounts(function(a,b) {
      token.approve(marketSanAddress, web3.toWei(minBd, "ether"), {from: b[0]}, function(err, tx) {
        $("#sanMarketTx").modal('show');
        $("#slotTx").append("<a href='https://ropsten.etherscan.io/tx/"+tx+"' target='_blank'>"+tx+"</a> (opens on new tab)");
        var interval = null;
        var max_attempts = 1000;
        var attempts = 0;
        if (err != null) {
          return;
        }
        var interval;
        var readBlock = function() {
          web3.eth.getTransactionReceipt(tx, function(e, txInfo) {
            if (e != null || txInfo == null) {
              return;
            }
            if (txInfo.blockNumber != null) {
                clearInterval(interval);
                if(txInfo.status == "0x0") {
                  console.log("tx failed");
                } else if(txInfo.status == "0x1") {
                  marketSan.marketDirectPurchase(sanId, web3.toWei(minBd, "ether"), function(err, res) {
                    if(err) console.log(err);
                    $("#sanMarketTx").modal('show');
                    $("#slotTx").append("<br><br>Tx Id : <a href='https://ropsten.etherscan.io/tx/"+res+"' target='_blank'>" + res + "</a><br><br>San will be added once the tx is complete. You can exit this window");
                  });
                }
            }
            if (attempts >= max_attempts) {
              clearInterval(interval);
              console.log("Transaction " + tx + " wasn't processed in " + attempts + " attempts");
            }
            attempts += 1;
          });
        };

        interval = setInterval(readBlock, 1000);
        readBlock();
      });
    });
  },

  bidForSan: function() {

  },

  acceptSanBid: function(si) {
    web3.eth.getAccounts(function(a,b) {
      marketSan.acceptBid(si, b[0], function(err, txhash){

      });
    });
  },

  setUserTabs: function() {
    var mysanTbl = document.getElementById("mysanTbl");
    if(mysanTbl != undefined)
      web3.eth.getAccounts(function(a,b) {
        // get user SANs
        san.balanceOf.call(b[0], function (err, bal) {
          for(var i = 0; i < bal; i++) {
            san.tokenOfOwnerByIndex(b[0], i, function(err, ti){
              san.getSanName(ti, function(err, sn) {
                san.tokenURI.call(ti, function(err, uri) {
                  var row = "<tr><td>"+ti+"</td><td>"+sn+"</td><td><img src='"+uri+"'></img></td></tr>";
                  $("#mysanTbl > tbody").append(row);
                });
              });
            });
          }
        });

    });
  },

  setSanTabs: function() {
    // get all SANs
    if($("#ssanTbl").length) {
      san.totalSupply(function(err, ts) {
        var remaining = ts;
        for(var i = 0; i < ts; i++) {
          san.tokenByIndex(i, function(err, ti) {
            san.getSanName(ti, function(err, sn) {
              san.ownerOf(ti, function(err, ad) {
                san.getSanTimeAlive(ti, function(err, stm) {
                  san.getSanTimeLastMove(ti, function(err, tm) {
                    var age = Math.abs(new Date() - new Date(stm * 1000));
                    var row = "<tr><td>"+ti+"</td><td><a href='ttt-send.html?sanTo="+sn+"'>"+sn+"</td><td>"+ad+"</td><td>"+ageConvert(age)+"</td><td>"+timeConvert(tm)+"</tr>";
                    $("#ssanTbl > tbody").append(row);
                    --remaining;
                    if(remaining <= 0) $("#ssanTbl").DataTable();
                  });
                });
              });
            });
          });
        }
      });

    }
  },

  mintTTTSan: function() {
    $("#formatFail").hide();
    $("#mintFail").hide();
    $("#txSuc").hide();
    var ms = document.getElementById("msan").value;
    san.getSANitized.call(ms, function(err, res0) {
      if(err) {
        $("#formatFail").show();
        console.log(err);
      } else {
        web3.eth.getAccounts(function(a,b) {
          sanToImage(res0, b[0]);
        });
      }
    });

  },

  refreshBalance: function() {
    web3.eth.getAccounts(function(a,b) {
      token.balanceOf.call(b[0], function (err, bal) {
        var sbal = fromBigNumberWeiToEth(bal);
        var balanceElement = document.getElementById("balance");
        if(balanceElement != undefined)
          balanceElement.innerHTML = sbal == undefined ? "0" : sbal;
      });
    });
  },

  sendTip: function() {
    var amount = document.getElementById("amount").value;

    var receiver = document.getElementById("receiver").value.toLowerCase();
    var br = false;
    if(receiver.substring(0, 2) != "0x") { // sending to a SAN
      san.totalSupply(function(err, ts) {
        for(var i = 0; i < ts; i++) {
          san.tokenByIndex(i, function(err, ti) {
            san.getSanName(ti, function(err, sn) {
              if(sn == receiver) {
                san.ownerOf(ti, function(err, ad) {
                  web3.eth.getAccounts(function(a,b) {
                    token.transfer(ad, web3.toWei(amount, "ether"), { from: b[0] }, function (err, txHash) {
                      if (err) console.error(err);
                      else {
                        var sucOut = '<a href="https://ropsten.etherscan.io/tx/'+txHash+'" target="_blank">'+txHash+'</a>';
                        $("#txSuc").append(sucOut).show();
                      }
                    });
                  });
                  br = true;
                });
              }
            });
          });
          if(br) break;
        }
      });
    } else {
      web3.eth.getAccounts(function(a,b) {
        token.transfer(receiver, web3.toWei(amount, "ether"), { from: b[0] }, function (err, txHash) {
          if (err) console.error(err);
          else {
            var sucOut = '<a href="https://ropsten.etherscan.io/tx/'+txHash+'" target="_blank">'+txHash+'</a>';
            $("#txSuc").append(sucOut).show();
          }
        });
      });
    }

  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
