pragma solidity ^0.4.16;

contract BallotPlus {
    
    //投票者Voter
    struct Voter {
        //投票者所占的权重
        uint weight;
        //是否是否已经投过票
        bool voted;
        //投票对应的提案编号
        uint vote;
        //投票者的委托对象
        address delegate;
    }
    
    //提案Proposal
    struct Proposal{
        //提案的名称
        bytes32 name;
        //提案的票数 
        uint voteCount;
    }
    
    //投票的主持人
    address chairperson;
    //投票者地址和状态对应的关系 
    mapping(address => Voter) voters;
    //提案列表 
    Proposal[] proposals;
    
    //智能合约的构造函数 
    function BallotPlus (bytes32 proposalNames) {
        //将投票发起者设置为主持人，并赋予投票权利作为投票者  
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        
        //初始化提案列表
        for (uint i = 0; i < proposalNames.length; i++){
            proposals.push(
                Proposal({
                    name:proposalNames[i],
                    voteCount:0
            }));
        }
    }
    
    //赋予Voter投票权利（只有chainperson能给投票权） 
    function giveRightToVoter(address voter) public {
        require((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0));
        voters[voter].weight = 1;
    }
    
    //批量赋予投票权 
    function giveRightToVoterByBatch (address[] batch) public {
        require(msg.sender == chairperson);
        for (uint i = 0; i < batch.length; i++){
            address voter = batch[i];
            require(!voters[voter].voted && (voters[voter].weight == 0));
            voter.weight = 1;
        }
    }
    
    //将投票权委托给其他人 
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        //判断委托人是否已经投票，且投票权重是否为0
        require(!voters[sender].voted && (voters[sender].weight == 0));
        
        //判断是否把投票权委托给了自己 
        require(to != msg.sender);
        
        //判断被委托人是否把投票权利委托给了其他人，如果是，找到被委托人投票权利的所属人
        while(voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender);
        }
        
        //将投票权力转移 
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate = voters[to];
        //判断被委托人是否已经投票 
        if (delegate.voted){
            //已经投票，在被委托人投票的提案上增加权重 
            proposals[delegate.vote].voteCount += sender.weight;
        } else {
            delegate.weight += sender.weight;
        }
    }
    
    //投票者根据提案编号进行投票 
    function vote (uint proposal)  public {
        //所投票提案必须存在 
        require(proposal < proposals.length);
        
        Voter storage sender = voters[msg.sender];
        require((!sender.voted) && (sender.weight != 0));
        sender.voted = true;
        sender.vote = proposal;
        
        proposals[proposal].voteCount += sender.weight;
    }
    
    //获取得到票数最多的提案编号 
    function winningProposal() public view returns (uint[] winningProposals) {
        //创建临时空间存储票数最多的提案编号  
        uint[] memory tempWinner = new uint[](proposals.length);
        
        //tempWinner的下标,也可作为票数最高的提案个数    
        uint winningCount = 0;
        uint winningVoteCount = 0;
        
        for (uint p = 0; p < proposals.length;p++){
            if(proposals[p].voteCount > winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                
                tempWinner[0] = p;
                //0下标已经存储编号p，将下标设为1  
                winningCount = 1;
            } else if (proposals[p].voteCount == winningVoteCount) {
                //每出现一个票数相同的提案下标加1
                tempWinner[winningCount] = p;
                winningCount ++;
            }
        }
        
        winningProposals = new uint[](winningCount);
        
        //将所有票数最高的提案编号存储到winningProposals
        for (uint q = 0; q < winningCount; q++){
            winningProposals[q] = tempWinner[q];
        }
        
        return winningProposals;
    }
    
    //获取票数最多的提案名称 
    function winnerName() public view returns (bytes32[] winnerNames) {
        //获取票数最高的提案编号 
        uint[] memory winningProposals = winningProposal();
        
        winnerNames = new bytes32(winningProposals.length);
        
        for (uint p = 0; p < winningProposals.length; p++){
            winnerNames[p] = proposals[winningProposals[p]].name;
        }
        return winnerNames;
    }
}