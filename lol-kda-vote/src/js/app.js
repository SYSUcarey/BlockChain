var ID_ARRAY;
var HEROES_SIZE;
App = {
  web3Provider: null,
  contracts: {},
  init: async function() {
    // Load heroes.
    console.log("init");
    $.getJSON('../heroes.json', function(data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');
      var str = "";
      ID_ARRAY = new Array(data.length);
      HEROES_SIZE = data.length;
      var test = "";
      for (i = 0; i < data.length; i ++) {
        petTemplate.find('.panel-title').text(data[i].title);
        petTemplate.find('img').attr('src', data[i].picture);
        //petTemplate.find('.hero-id').text(data[i].id);
        petTemplate.find('.hero-name').text(data[i].name);
        petTemplate.find('.vote-count').text(data[i].count);
        petTemplate.find('.btn-vote').attr('data-id', data[i].id);

        petsRow.append(petTemplate.html());
        ID_ARRAY[i] = data[i].id;
      }
    });

    return await App.initWeb3();
  },

  initWeb3: async function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    // 加载Adoption.json，保存了Adoption的ABI（接口说明）信息及部署后的网络(地址)信息，它在编译合约的时候生成ABI，在部署的时候追加网络信息
    $.getJSON('kda_ballot.json', function(data) {
      // 用Adoption.json数据创建一个可交互的TruffleContract合约实例。
      var AdoptionArtifact = data;
      App.contracts.Adoption = TruffleContract(AdoptionArtifact);

      // Set the provider for our contract
      App.contracts.Adoption.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      return App.markVoted();
    });
    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-vote', App.handleVote);
  },


  handleVote: function(event) {
    event.preventDefault();
    var select_id = parseInt($(event.target).data('id'));
    var heroId = ID_ARRAY[select_id];
    var voteInstance;

    // 获取用户账号
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      var account = accounts[0];
    
      App.contracts.Adoption.deployed().then(function(instance) {
        voteInstance = instance;
        // 发送交易领养宠物
        return voteInstance.vote(heroId, {from: account});
      }).then(function(result) {
        return App.markVoted();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  
  },

  markVoted: function(adopters, account) {
    console.log("markVoted");
    var voteInstance;

    App.contracts.Adoption.deployed().then(function(instance) {
      voteInstance = instance;

      var isVoted = voteInstance.isVoted.call();
      console.log(isVoted);
      return isVoted;
    }).then(function(isVoted) {
      if(isVoted) {
        for(i = 0; i < HEROES_SIZE; i++) {
          $('.panel-heroes').eq(i).find('.btn-vote').text('已投票').attr('disabled', true);
        }
      }
    });

    App.contracts.Adoption.deployed().then(function(instance) {
      voteInstance = instance;
      var heroDetail = voteInstance.get_all_Hero.call();
      console.log(heroDetail);
      return heroDetail;
    }).then(function(heroDetail) {
      var num = heroDetail[0];
      var name = heroDetail[1];
      var count = heroDetail[2];

      function swap(str_a, str_b) {
        var temp = str_b;
        str_b = str_a;
        str_a = temp;
      };

      // Bubble Sort
      for(i = 0; i < num.length; i++) {
        for(j = 0; j < num.length-i-1; j++) {
          var a = parseInt(count[j].c[0]);
          var b = parseInt(count[j+1].c[0]);
          if(a < b) {
            [num[j].c[0], num[j+1].c[0]] = [num[j+1].c[0], num[j].c[0]];
            [name[j], name[j+1]] = [name[j+1], name[j]];
            [count[j].c[0], count[j+1].c[0]] = [count[j+1].c[0], count[j].c[0]];

          }
        }
      }
      $.getJSON('heroes.json', function(data) {
        for(i = 0; i < num.length; i++) {
          var heroId = parseInt(num[i].c[0]);
          ID_ARRAY[i] = heroId;
          //console.log(heroId + " " + data[heroId].name + " " + count[i].c[0]);
          $('.panel-heroes').eq(i).find('.vote-count').text(count[i].c[0]);
          $('.panel-heroes').eq(i).find('.panel-title').text(data[heroId].title);
          $('.panel-heroes').eq(i).find('.img-center').attr('src', data[heroId].picture);
          $('.panel-heroes').eq(i).find('.hero-name').text(data[heroId].name);
        }
      });
      
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
