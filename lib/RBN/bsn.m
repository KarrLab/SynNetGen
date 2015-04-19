function [node, conn, rules] = bsn(n, k, optionString)

% BSN Build and show network.
% 
% BSN(N, K, OPTIONSTRING) builds network with N nodes and K connections per node
% and displays the topology using OPTIONSTRING-LineStyle.
% 
% This is just a script that calls some standard initialisation functions with
% common parameters.
% To exercice more control over the parameters of the network, make sure to
% call all initializing functions with specific parameters individually.
%
% Input:
%    n              - Number of nodes in network
%    k              - Incoming connections per node
%    optionString   - LineStyle ('line' or 'arrow')
%
% Output:
%    node           - Structure-array containing node information
%    conn           - n x n adjacent matrix with at average k incoming 
%                     connections per node
%    rules          - 2^k x n (2^kMax x n) matrix containing transition logic rules for each node
%

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 8.11.2002 LastModified: 20.01.2003


node = initNodes(n);
conn= initConnections(n, k);
rules = initRules(n, k);
node = assocRules(node, rules);
node = assocNeighbours(node, conn);
node = displayTopology(node, conn, optionString);