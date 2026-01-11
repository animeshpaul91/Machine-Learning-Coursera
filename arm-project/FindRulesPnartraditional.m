function [Rules, FreqPItemsets, FreqNItemsets] = FindRulesPnartraditional(transactions, minSup, dms, mc, dmc, nRules, sortFlag, fname)
%
% This function performs Positive and Negative Association Analysis:  Given a set of transactions,
% find rules that will predict  the occurrence of an item based on the occurrences of other
% items in the transaction as well as how the absence of an item predicts the occurence or absence of other items. 
% 
% Rules are of four types  A=>B,~A=>B,A=>~B,~A=>~B where
% support = minSup (minimum support threshold)
% confidence = minConf (minimum confidence threshold)
% 
% Support is the fraction of transactions that contain both A and B:
% Support(A,B) = P(A,B)
% 
% Confidence is the fraction of transactions where items in B appear in transactions  that contain A:
% Confidence(A,B) = P(B|A)
%
%
% INPUT:
%          transactions:           M x N matrix of binary transactions, where each row
%                                  represents one transaction and each column represents
%                                  one attribute/item
%          minSup:                 scalar value that represents the minimum
%                                  threshold for support for each rule
%          mc:                   scalar value that represents the minimum
%                                  threshold for confidence of each rule 
%                                  of type A=>B and ~A=>~B. 
%          dmc:                   scalar value that represents the minimum
%                                  threshold for confidence of each rule 
%                                  of type ~A=>B and A=>~B.
%          mincorr:                A minimum Correlation threshold which
%                                  mines only those rules that are
%                                  interesting.
%          nRules:                 scalar value indicating the number of rules
%                                  the user wants to find
%          sortFlag:               binary value indicating if the rules should be
%                                  sorted by support level or confidence level
%                                  1: sort by rule support level
%                                  2: sort by rule confidence level
%          labels:                 optional parameter that provides labels for
%                                  each attribute (columns of transactions),
%                                  by default attributes are represented
%                                  with increasing numerical values 1:N
%          fname:                  optional file name where rules are saved
%
% OUTPUT:
%          Rules:                 2 x 2 cell array, where  where the first column contains
%                                 Rules a=>b and ~a=>~b and second column contains rules ~a=>b and a=>~b   
%         FreqPItemsets:          A cell array of frequent positive itemsets of size 1, 2,
%                                 etc., with itemset support >= minSup,
%                                 where FreqItemSets{1} represents itemsets
%                                 of size 1, FreqItemSets{2} itemsets of
%                                 size 2, etc.
%         FreqNItemsets:          A cell array of frequent negative itemsets of size 1, 2,
%                                 etc., with itemset support >= minSup,
%                                 where FreqItemSets{1} represents itemsets
%                                 of size 1, FreqItemSets{2} itemsets of
%                                 size 2, etc.
%         fname.txt:      The code creates a text file and stores all the
%                                 rules in the form left_side -> right_side.
%
% Author: Animesh Paul 04/05/2015 

% Number of transactions in the dataset
M = size(transactions,1);
% Number of attributes in the dataset
N = size(transactions,2);

if nargin < 8
    labels = cellfun(@(x){num2str(x)}, num2cell(1:N));
end

if nargin < 7
    sortFlag = 1;
end

if nargin < 6
    nRules = 100;
end

if nargin < 5
    mc = 0.5;
end

if nargin < 4
    minSup = 0.5;
end

if nargin < 3
    mc = 0.7;
end

if nargin < 2
    mincorr = 0.1;
end

if nargin < 1
    dmc = 0.3;
end

if nargin == 0
    error('No input arguments were supplied.  At least one is expected.');
end

% Preallocate memory for Rules and FreqItemsets
maxSize = 10^2;
Rules = cell(4,1);
Rules{1,1} = cell(nRules,1);
Rules{2,1} = cell(nRules,1);
Rules{3,1} = cell(nRules,1);
Rules{4,1} = cell(nRules,1);
FreqPItemsets = cell(maxSize); %Frequent Positive Itemsets
FreqNItemsets = cell(maxSize); %Frequent Negative Itemsets
PRuleConf = zeros(nRules,1);
PRuleSup = zeros(nRules,1);
NRuleConf = zeros(nRules,1);
NRuleSup = zeros(nRules,1);
ct = 1; % For Rules A=>B and ~A=>~B
c = 1;  % For Rules A=>~B and ~A=>B
% Find frequent item sets of size one (list of all items with minSup)
T = [];
W = [];
for i = 1:N
    S = sum(transactions(:,i))/M;
    if S >= minSup
        T = [T; i];
    else
        W = [W; i];
    end
end



FreqPItemsets{1} = T;
FreqNItemsets{1} = W;

%Find frequent item sets of size >=2 and from those identify rules with minConf

for steps = 2:N
    
    % If there aren't at least two items  with minSup terminate
    U = unique(T);
    if isempty(U) || size(U,1) == 1
        Rules{1}(ct:end) = [];
        Rules{2}(ct:end) = [];
        Rules{3}(ct:end) = [];
        Rules{4}(ct:end) = [];
        FreqPItemsets(steps-1:end) = [];
        FreqNItemsets(steps-1:end) = [];
        break
    end
    
    % Generate all combinations of items that are in frequent itemset
    Combinations = nchoosek(U',steps);
    TOld = T;
    T = [];
    W = [];
    for j = 1:size(Combinations,1)
        if ct > nRules 
            break;
        else
            % Apriori rule: if any subset of items are not in frequent itemset do not
            % consider the superset (e.g., if {A, B} does not have minSup do not consider {A,B,*})
            if sum(ismember(nchoosek(Combinations(j,:),steps-1),TOld,'rows')) - steps+1>0
                % Calculate the support for the new itemset
                S = mean((sum(transactions(:,Combinations(j,:)),2)-steps)>=0); % Computing Sup(A=>B) 
                if S >= minSup 
                  if ct <= nRules
                    T = [T; Combinations(j,:)];
                     % Check for Minimum correlation Threshold. 
                    for depth = 1:steps-1
                        R = nchoosek(Combinations(j,:),depth);
                        for r = 1:size(R,1)
                            if ct > nRules
                                break;
                            else
                                A = R(r,:);
                                B = setdiff(Combinations(j,:), A);
                                sa = mean((sum(transactions(:,A),2)- depth)>=0); % Support(A)
                                sb = mean((sum(transactions(:,B),2)- depth)>=0);  % Support(B)
                                corr = S - (sa*sb); % Corr(A,B)
                                   if corr > 0
                                     % Generate potential rules and check for mc. Produce Rules of the Form A=>B and ~A=>~B
                                     % Calculate the confidence of the rule
                                     % Produce Rules of type A=>B
                                     Ctemp = S/sa; % Computing Conf(A=>B) 
                                     if Ctemp >= mc % Produce Rules of type A=>B
                                         %Store the rules that have minSup and minConf
                                         Rules{1}{ct} = A;
                                         Rules{2}{ct} = B;
                                         PRuleConf(ct) = Ctemp;
                                         PRuleSup(ct) = S;
                                         ct = ct + 1;
                                     end
                                     
                                     S1 = (1 - sa - sb + S); % Computing Sup(~A=>~B)
                                     Conf = S1/(1 - sa);     % Computing Conf(~A=>~B) 
                                     if Conf >= dmc && S1 >= dms % Produce Rules of type ~A=>~B
                                         Rules{1}{ct} = -A;
                                         Rules{2}{ct} = -B; % All Negative itemsets are prefixed with a '-' sign to identify them.
                                         PRuleConf(ct) = Conf;
                                         NRuleSup(ct) = S1;
                                         ct = ct + 1;   
                                     end 
                                     
                                   end
                                end
                         end
                    end
                  end
                    
                else 
                    if c <= nRules 
                      W = [W; Combinations(j,:)];
                    % Check for Minimum correlation Threshold. 
                    for depth = 1:steps-1
                        R = nchoosek(Combinations(j,:),depth);
                        for r = 1:size(R,1)
                            if c > nRules
                                break;
                            else
                                A = R(r,:);
                                B = setdiff(Combinations(j,:), A);
                                sa = mean((sum(transactions(:,A),2)- depth)>=0); % Support(A)
                                sb = mean((sum(transactions(:,B),2)- depth)>=0);  % Support(B)
                                corr = S - (sa*sb); % Corr(A,B)
                                   if corr < 0
                                     % Generate potential rules and check for dmc. Produce Rules of the Form A=>~B and ~A=>B
                                     % Calculate the confidence of the rule
                                     % Produce Rules of type A=>~B
                                     S2 = (sa - S); % Computing Sup(A=>~B)
                                     Conf1 = S2/sa; % Computing Conf(A=>~B)
                                     if Conf1 >= dmc && S2 >= dms % Produce Rules of type A=>~B
                                         %Store the rules that have minSup and minConf
                                         Rules{3}{c} = A;
                                         Rules{4}{c} = -B; % All Negative itemsets are prefixed with a '-' sign to identify them.
                                         NRuleConf(c) = Conf1;
                                         NRuleSup(c) = S2;
                                         c = c + 1;
                                     end
                                     
                                     S3 = (sb - S); % Computing Sup(~A=>B)
                                     Conf2 = S3/(1 - sa); % Computing Sup(~A=>B)
                                     if Conf2 >= dmc && S3 >= dms % Produce Rules of type ~A=>B
                                         Rules{3}{c} = -A;
                                         Rules{4}{c} = B; % All Negative itemsets are prefixed with a '-' sign to identify them.
                                         NRuleConf(c) = Conf2;
                                         NRuleSup(c) = S3;
                                         c = c + 1;   
                                     end 
                                     
                                   end
                            end
                        end
                    end
                   end 
                end % End of if S>=minSup
            end
        end
    end
    % Store the freqent positive and negative itemsets
    FreqPItemsets{steps} = T;
    FreqNItemsets{steps} = W;
end

ct= min(ct,c);
% Get rid of unnecessary rows due to preallocation (helps with speed)
% freeing if number of Rules generated is less than preallocated memory
FreqPItemsets(steps-1:end) = [];
FreqNItemsets(steps-1:end) = [];
PRuleConf = PRuleConf(1:ct-1);
PRuleSup = PRuleSup(1:ct-1);
NRuleConf = NRuleConf(1:ct-1);
NRuleSup = NRuleSup(1:ct-1);



% Sort the rules in descending order based on the confidence or support level
% Here sortflag=1 so Rules will be sorted in descending order of Support
switch sortFlag
    case 1 % Sort by Support level
        [~, ind] = sort(PRuleSup,'descend');   % ind stores index of PRules in decreasing supports
        [~, ind1] = sort(NRuleSup,'descend');  % ind1 stores index of NRules in decreasing supports
    case 2 % Sort by Confidence level
        [~, ind] = sort(PRuleConf,'descend');  % ind stores index of PRules in decreasing confidence
        [~, ind1] = sort(NRuleConf,'descend'); % ind1 stores index of NRules in decreasing confidence
end

% ~ Holds support and ind holds index/serial number
% ind;items 


PRuleConf = PRuleConf(ind);
PRuleSup  = PRuleSup(ind);
NRuleConf = NRuleConf(ind1);
NRuleSup = NRuleSup(ind1);


for i = 1:2
    temp = Rules{i,1};
    temp = temp(ind);
    Rules{i,1} = temp;
end

for i = 3:4
    temp = Rules{i,1};
    temp = temp(ind1);
    Rules{i,1} = temp;
end
% Sorting Rules Cell array in the order of decreasing order of Support
    


% Save the rule in a text file and print them on display
fid = fopen([fname '.txt'], 'w');
fprintf(fid,'\n\nPositive Association rules are represented by Item A => Item B\n\n');
fprintf(fid,'\n\nNegative Association rules are represented by Item -A => Item -B, Item -A => Item B, Item A => Item -B\n\n');

%Writing Rules A=>B and ~A=>~B into File
fprintf(fid,'\n\n\nWriting Rules A=>B and ~A=>~B into File\n\n');
fprintf(fid, '%s   (%s, %s) \n\n', 'Rule', 'Support', 'Confidence');
for i = 1:size(Rules{1},1)
    s1 = '';
    s2 = '';
    for j = 1:size(Rules{1}{i},2)
        if j == size(Rules{1}{i},2)
            s1 = [s1 'Item ' num2str(Rules{1}{i}(j)) ];
       else
            s1 = [s1 'Item ' num2str(Rules{1}{i}(j)) ' , '];    
        end
    end
    
    for k = 1:size(Rules{2}{i},2)
        if k == size(Rules{2}{i},2)  
             s2 = [s2 'Item ' num2str(Rules{2}{i}(k))];    
        else
    
          s2 = [s2 'Item ' num2str(Rules{2}{i}(k)) ' , '];       
         
        end
        
    end
    s3 = num2str(PRuleSup(i)*100);
    s4 = num2str(PRuleConf(i)*100);
    fprintf(fid, '%s => %s  (%s%%, %s%%)\n', s1, s2, s3, s4);

end


fprintf(fid,'\n\n\nWriting Rules A=>~B and ~A=>B into File\n\n\n');
fprintf(fid, '%s   (%s, %s) \n\n', 'Rule', 'Support', 'Confidence');
for l = 1:size(Rules{3},1)
    s5 = '';
    s6 = '';
    for m = 1:size(Rules{3}{l},2)
        if m == size(Rules{3}{l},2)
            s5 = [s5 'Item ' num2str(Rules{3}{l}(m))];    
        else
            s5 = [s5 'Item ' num2str(Rules{3}{l}(m)) ' , '];    
        end
    end
    
    for n = 1:size(Rules{4}{l},2)
        if n == size(Rules{4}{l},2) 
             s6 = [s6 'Item ' num2str(Rules{4}{l}(n))];     
        else
       
             s6 = [s6 'Item ' num2str(Rules{4}{l}(n)) ' , '];     
        end
    end
    s7 = num2str(NRuleSup(l)*100);
    s8 = num2str(NRuleConf(l)*100);

     fprintf(fid, '%s => %s  (%s%%, %s%%)\n', s5, s6, s7, s8);
end

fclose(fid);
end