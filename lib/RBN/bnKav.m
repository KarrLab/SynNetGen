function [nodeUpdated, kavreal] = bnKav(n, kavdesired)

% BNKAV Generate network with N nodes and at average KAV incoming connections per node.
% If it is not possible to build a network with exactly these parameters, then a network with 
% N nodes and KAVREAL < KAVDESIRED is built.
%
%
%   BNKAV(N, KAV) Generates network with N nodes and at average KAV incoming connections per node.
%
%   Input:
%       n                   - Number of nodes
%       kavdesired          - Average number of connections per node (desired)
%
%   Output: 
%       nodeUpdated         - Structure-array of nodes
%       kavreal             - Average number of connections per node (found by algorithm)

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 13.01.2003 LastModified: 20.01.2003


% build fully connected network
node = initNodes(n);
conn = initConnections(n, n);
node = assocNeighbours(node, conn);

% real connectivity obtained by probing
kavreal = averageConnectivity(node);
nodeUpdated = node;

% probe for kavdesired by gradually removing one link from the network at random
while(kavreal > kavdesired)
    
    affectedNode = randint(1,1,[1,n]);
    k = length(nodeUpdated(affectedNode).input);
    
    if(k > 0)
        nDelete = randint(1,1,[1,k]);
        nodeUpdated(affectedNode).input = [nodeUpdated(affectedNode).input(1:nDelete-1), nodeUpdated(affectedNode).input(nDelete+1:end)];
    end
    
    kavreal = averageConnectivity(nodeUpdated); 
    
end

% search for node with highest connectivity and store kmax
kmax = 0;
for i=1:length(nodeUpdated)
    if(length(nodeUpdated(i).input)>kmax)
        kmax = length(nodeUpdated(i).input);
    end
end
kmax;

% associate rules to network with at most kmax incoming connections per node
rules = initRules(n,kmax);
nodeUpdated = assocRules(nodeUpdated,rules);

kavdesired % display kavdesired for user information
kavreal    % display kavreal for user information








