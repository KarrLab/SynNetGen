function distr = connectivityDistribution(node)

% CONNECTIVITYDISTRIBUTION Calculate and display the network's connectivity distribution. 
%
%   CONNECTIVITYDISTRIBUTION(NODE) calculates and displays the connectivity distribution of the network defined by NODE.
%   
%   Input:
%       node               - 1 x n structure-array containing node information
%
%   Output: 
%       distr              - 1 x n array containing connectivity distribution 
% 

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 13.01.2003 LastModified: 20.01.2003
 
if(nargin == 1)    
    
    distr = zeros(1,length(node)+1);
    
    % count number of incoming connections
    for i=1:length(node)
        distr(length(node(i).input) + 1) = distr(length(node(i).input)+1) + 1;
    end
    
    % display graph
    str = sprintf('Connectivity Distribution for a network with %d nodes', length(node));
    fHandle = figure;
    set(fHandle,'Color','w','Name',str);
    x = [0:1:length(node)];
    bar(x,distr);
    xlabel('K');
    ylabel('Number of nodes with number of incoming links = K');
    title(str);
    
    
else
    error('Wrong number of arguments. Type: help averageConnectivity')    
end