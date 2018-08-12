通过对Solidity官方文档的学习，发现文档里的[投票](https://solidity.readthedocs.io/en/latest/solidity-by-example.html#voting)案例代码有些不够严谨，动手做了一些改进。

修改地方：
   `vote`函数，`delegate`函数的调用者判断，提案编号的范围判断。

   `winningProposal`函数，`winnerName`函数出现多个票数最高且相同的情况。
