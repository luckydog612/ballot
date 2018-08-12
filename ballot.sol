pragma solidity ^0.4.16;

contract BallotPlus {
    
    //ͶƱ��Voter
    struct Voter {
        //ͶƱ����ռ��Ȩ��
        uint weight;
        //�Ƿ��Ƿ��Ѿ�Ͷ��Ʊ
        bool voted;
        //ͶƱ��Ӧ���᰸���
        uint vote;
        //ͶƱ�ߵ�ί�ж���
        address delegate;
    }
    
    //�᰸Proposal
    struct Proposal{
        //�᰸������
        bytes32 name;
        //�᰸��Ʊ�� 
        uint voteCount;
    }
    
    //ͶƱ��������
    address chairperson;
    //ͶƱ�ߵ�ַ��״̬��Ӧ�Ĺ�ϵ 
    mapping(address => Voter) voters;
    //�᰸�б� 
    Proposal[] proposals;
    
    //���ܺ�Լ�Ĺ��캯�� 
    function BallotPlus (bytes32 proposalNames) {
        //��ͶƱ����������Ϊ�����ˣ�������ͶƱȨ����ΪͶƱ��  
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        
        //��ʼ���᰸�б�
        for (uint i = 0; i < proposalNames.length; i++){
            proposals.push(
                Proposal({
                    name:proposalNames[i],
                    voteCount:0
            }));
        }
    }
    
    //����VoterͶƱȨ����ֻ��chainperson�ܸ�ͶƱȨ�� 
    function giveRightToVoter(address voter) public {
        require((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0));
        voters[voter].weight = 1;
    }
    
    //��������ͶƱȨ 
    function giveRightToVoterByBatch (address[] batch) public {
        require(msg.sender == chairperson);
        for (uint i = 0; i < batch.length; i++){
            address voter = batch[i];
            require(!voters[voter].voted && (voters[voter].weight == 0));
            voter.weight = 1;
        }
    }
    
    //��ͶƱȨί�и������� 
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        //�ж�ί�����Ƿ��Ѿ�ͶƱ����ͶƱȨ���Ƿ�Ϊ0
        require(!voters[sender].voted && (voters[sender].weight == 0));
        
        //�ж��Ƿ��ͶƱȨί�и����Լ� 
        require(to != msg.sender);
        
        //�жϱ�ί�����Ƿ��ͶƱȨ��ί�и��������ˣ�����ǣ��ҵ���ί����ͶƱȨ����������
        while(voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender);
        }
        
        //��ͶƱȨ��ת�� 
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate = voters[to];
        //�жϱ�ί�����Ƿ��Ѿ�ͶƱ 
        if (delegate.voted){
            //�Ѿ�ͶƱ���ڱ�ί����ͶƱ���᰸������Ȩ�� 
            proposals[delegate.vote].voteCount += sender.weight;
        } else {
            delegate.weight += sender.weight;
        }
    }
    
    //ͶƱ�߸����᰸��Ž���ͶƱ 
    function vote (uint proposal)  public {
        //��ͶƱ�᰸������� 
        require(proposal < proposals.length);
        
        Voter storage sender = voters[msg.sender];
        require((!sender.voted) && (sender.weight != 0));
        sender.voted = true;
        sender.vote = proposal;
        
        proposals[proposal].voteCount += sender.weight;
    }
    
    //��ȡ�õ�Ʊ�������᰸��� 
    function winningProposal() public view returns (uint[] winningProposals) {
        //������ʱ�ռ�洢Ʊ�������᰸���  
        uint[] memory tempWinner = new uint[](proposals.length);
        
        //tempWinner���±�,Ҳ����ΪƱ����ߵ��᰸����    
        uint winningCount = 0;
        uint winningVoteCount = 0;
        
        for (uint p = 0; p < proposals.length;p++){
            if(proposals[p].voteCount > winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                
                tempWinner[0] = p;
                //0�±��Ѿ��洢���p�����±���Ϊ1  
                winningCount = 1;
            } else if (proposals[p].voteCount == winningVoteCount) {
                //ÿ����һ��Ʊ����ͬ���᰸�±��1
                tempWinner[winningCount] = p;
                winningCount ++;
            }
        }
        
        winningProposals = new uint[](winningCount);
        
        //������Ʊ����ߵ��᰸��Ŵ洢��winningProposals
        for (uint q = 0; q < winningCount; q++){
            winningProposals[q] = tempWinner[q];
        }
        
        return winningProposals;
    }
    
    //��ȡƱ�������᰸���� 
    function winnerName() public view returns (bytes32[] winnerNames) {
        //��ȡƱ����ߵ��᰸��� 
        uint[] memory winningProposals = winningProposal();
        
        winnerNames = new bytes32(winningProposals.length);
        
        for (uint p = 0; p < winningProposals.length; p++){
            winnerNames[p] = proposals[winningProposals[p]].name;
        }
        return winnerNames;
    }
}