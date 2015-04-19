function kav= averageConnectivity(node)

% AVERAGECONNECTIVITY Calculate average network connectivity.
%
%   AVERAGECONNECTIVITY(NODE) calculates average network connectivity over all nodes in NODE.
%   
%   Input:
%       node               - 1 x n structure-array containing node information
%
%   Output: 
%       kav                - Average network connectivity 
% 

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 15.11.2002 LastModified: 20.01.2003
 
if(nargin == 1)
    kav = 0;
    
    % sum up all number of connections
    for i=1:length(node)
        kav = kav + length(node(i).input);
    end
   
    % build average
    kav = kav/length(node);
    
else
    error('Wrong number of arguments. Type: help averageConnectivity')    
end