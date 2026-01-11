function  [Rules, FreqItemsets]  = Apriori( )
% This file demonstrates how the Apriori method works for finding
% association analysis from a set of transactions
% 
% load a matrix of transactions, where each row represents one
% transaction.
% 
% For this demo we are going to use a sample dataset of 20 transactions and
% 10 items. In this example transactions are replaced with the adjacency matrix
% representing connections in the network, where
% row i represents the transaction profile of transaction i,
% 1s indicating presence and 0s absence.
% In this context an association rule Item1, Item2 -> Item3 will
% mean that a person who purshases item1 and item 2 is very likely to purchase 
% item3 as well, therefore can be used to find  missing links in the network. 
% Note: Although the dataset is undirected (if a is connected to b 
% then b is connected to a), the direction of the resulting rules are
% important (a -> b means buying a implies buying b, but not the other way around)

load Dataset
minSup = 0.2;
minConf = 0.7;
nRules = 100;
sortFlag = 1;
fname = 'AprioriRules';
for s = 1:size(Dataset,2)
    labels{s} = ['Item' num2str(s)];
end

[Rules, FreqItemsets] = findRulesapriori(Dataset, minSup, minConf, nRules, sortFlag, labels, fname);
FreqItemsets{1: end}
disp(['See the file named ' fname '.txt for the association rules']);
end

