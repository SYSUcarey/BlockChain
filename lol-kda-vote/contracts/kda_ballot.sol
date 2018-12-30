pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;
contract kda_ballot {
    
    /// 投票者的数据结构 
    struct Voter {
        bool isVoted;                // 是否已经投过票
        uint vote_hero_num;          // 投票对应的英雄编号
    }

    /// 参与投票的LOL英雄数据结构
    struct Hero {
        uint hero_num;          // 英雄的编号
        string heroName;        // 英雄名字
        uint voteCount;         // 英雄的得票数
    }

    /// 英雄列表
    Hero[] heroes;

    /// 初始参与投票的英雄名
    string [] names = ["暗", "牛", "殇", "铸", "沙", "星", "蒸", "复", "弗", "虚", "英", "诺", "荣", "祖", "时", "探", "末", "潮", "正", "海", "德", "迷", "酒", "法", "战", "大", "翠", "德", "武", "未", "戏", "死", "虚", "影", "狂", "虚", "永", "暴", "深", "盲", "圣", "熔", "虚", "扭", "无", "齐", "铁", "沙", "深", "永", "雪", "狂", "山", "战", "血", "幻", "披", "虚", "荒", "傲", "机", "符", "恶", "暮", "炼", "亡", "水", "诺", "河", "刀", "瓦", "迅", "魂", "巨", "蛮", "卡", "瘟", "兽", "无", "惩", "邪", "虚", "机", "猩", "雷", "祖", "远", "德", "疾", "牧", "生", "影", "爆", "时"];

    /// 投票者地址和状态的对应关系
    mapping(address=>Voter) voters;

    address chairperson;

    uint heroCount;


    /// 判断用户是否已经投票
    function isVoted() view public returns (bool result) {
        Voter storage sender = voters[msg.sender];
        return sender.isVoted;
    }
    
    /// 在初始化合约时，初始化投票英雄的列表
    constructor() public {
        for(uint i = 0; i < names.length; i++) {
            heroes.push(Hero({
                hero_num : i,
                heroName : names[i],
                voteCount : 0
            }));
        }
        chairperson = msg.sender;
        heroCount = names.length;
    }

    /// 投票函数，每个用户只能投一次票给一个英雄
    function vote(uint _hero_num) public returns (bool result) {
        require(
            _hero_num < heroes.length,
            "Input Error! hero_num is out of index!"
        );
        Voter storage sender = voters[msg.sender];
        require(
            (!sender.isVoted),
            "Error! You have already voted!"
        );
        sender.isVoted = true;
        sender.vote_hero_num = _hero_num;

        heroes[_hero_num].voteCount += 1;

        return true;
    }



    /*/// 添加参与投票的英雄
    function add_Hero(string name) public returns (bool result) {
    	require(
    		msg.sender == chairperson,
    		"You have no right to add voting Hero!"
    	);
    	for(uint i = 0; i < heroCount; i++) {
    		require(
    			keccak256(name) != keccak256(heroes[i].heroName),
    			"The hero is already in the voting List!"
    		);
    	}
    	heroes.push(Hero({
    		hero_num : heroCount,
    		heroName : name,
    		voteCount : 0
    	}));
    	heroCount += 1;
    	return true;
    }*/


    /*/// 根据英雄编号获取英雄的得票数
    function get_hero_voteCount(uint _hero_num) view public returns (uint count) {
        require(
            _hero_num < heroes.length,
            "Input Error! hero_num is out of index!"
        );
        return heroes[_hero_num].voteCount;
    }*/

    /*/// 根据英雄编号获得英雄名
    function get_hero_Name(uint _hero_num) view public returns (string name) {
        require(
            _hero_num < heroes.length,
            "Input Error! hero_num is out of index!"
        );
        return heroes[_hero_num].heroName;
    }*/


    /*/// 获得当前投票数最高的英雄编号,名字和得票数
    function winning_heroDetail() view public returns (uint num, string name, uint count) {
        uint winning_heronum = 0;
        if(heroes.length != 1) {
        	for(uint i = 0; i < heroes.length-1; i++) {
            	if(heroes[i+1].voteCount > heroes[winning_heronum].voteCount) {
                	winning_heronum = i+1;
            	}
        	}
        }
        
        return (heroes[winning_heronum].hero_num, heroes[winning_heronum].heroName, heroes[winning_heronum].voteCount);
    }*/


    /// 获取投票英雄列表信息
   	function get_all_Hero() view public returns (uint[] num, string[] name, uint[] count) {
   		uint[] memory num_temp = new uint[] (heroCount);
   		string[] memory name_temp = new string[] (heroCount);
   		uint[] memory count_temp = new uint[] (heroCount);

    	for(uint i = 0; i < heroCount; i++) {
    		num_temp[i] = heroes[i].hero_num;
    		name_temp[i] = heroes[i].heroName;
    		count_temp[i] = heroes[i].voteCount;
    	}
    	return(num_temp, name_temp, count_temp);
    }
    
    
    /*/// 获得目前得票领先的四名KDA男团成员的英雄编号、英雄名、得票数
    function get_four_leading_heroes() view public returns (uint[] num, string[] name, uint[] count) {
   		uint[] memory num_temp = new uint[] (4);
   		string[] memory name_temp = new string[] (4);
   		uint[] memory count_temp = new uint[] (4);
   		Hero[] memory copy_hero_list = new Hero[] (heroCount);
   		for(uint c = 0; c < heroCount; c++) {
   			copy_hero_list[c] = heroes[c];
   		}
   		
   		Hero memory temp;
   		for(uint i = 0; i < heroCount; i++) {
   			for(uint j = 0; j < heroCount - i - 1; j++) {
   				if(copy_hero_list[j+1].voteCount > copy_hero_list[j].voteCount) {
   					temp = copy_hero_list[j+1];
   					copy_hero_list[j+1] = copy_hero_list[j];
   					copy_hero_list[j] = temp;
   				}
   			}
   		}

   		for(uint k = 0; k < 4; k++) {
   			num_temp[k] = copy_hero_list[k].hero_num;
   			name_temp[k] = copy_hero_list[k].heroName;
   			count_temp[k] = copy_hero_list[k].voteCount;
   		}
    	return(num_temp, name_temp, count_temp);
    }*/
    


    /// 辅助函数: uint to string
    function uint2hexstr(uint i) internal pure returns (string) {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0) {
            length++;
            j = j >> 4;
        }
        uint mask = 15;
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        uint numStart = 48;
        uint letterStarn = 65;
        while (i != 0){
            uint curr = (i & mask);
            bstr[k--] = curr > 9 ? byte(55 + curr ) : byte(48 + curr); // 55 = 65 - 10
            i = i >> 4;
        }
        return string(bstr);
    }

}