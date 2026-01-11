function  [Rules, FreqPItemsets, FreqNItemsets]  = Pnar_improved( )
% This file demonstrates a method works for finding positive and negative 
% association analysis from a set of transactions based on a minimum
% correlation threshold which monitors the interestingness and dual confidence 
% approach to mine the respective positve and negative rules.

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
dms = 0.50;
P_mc = 0.70;
N_mc = 1-P_mc;
mincorr = 0.1;
nRules = 100;
sortFlag = 1;
fname = 'PnarRules';
[Rules, FreqPItemsets, FreqNItemsets] = FindRulesPnar(Dataset, minSup, dms, P_mc, N_mc, mincorr, nRules, sortFlag, fname);

disp(['See the file named ' fname '.txt for the association rules']);
end

