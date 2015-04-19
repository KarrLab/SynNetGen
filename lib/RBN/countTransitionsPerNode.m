function nbChangesPerNode = countTransitionsPerNode(tsm)

% COUNTTRANSITIONSPERNODE Count number of changes of a node through evolution.
% 
%   COUNTTRANSITIONSSPERNODE(TSM) counts for all nodes in TSM how many times they have changed state
%   over all discrete timesteps. 
%
%   Input:
%       tsm                 - n x k+1 matrix containing node-states for n nodes at k timesteps
%
%   Output:
%       nbChangesPerNode    - Number of changes of each node (column vector)
%

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 27.11.2002 LastModified: 20.01.2003


if(nargin == 1)
    
    nbChangesPerNode = zeros(length(tsm(:,1)),1);
    
    % compare step by step node states at j and j-1
    for j=2:length(tsm(1,:))
        temp = tsm(:,j) - tsm(:,j-1);
        indices = find(temp);
        % count number of changes
        for k=1:length(indices)
            nbChangesPerNode(indices(k)) = nbChangesPerNode(indices(k)) + 1;
        end
    end
    
else
    error('Wrong number of arguments. Type: help countTransitionsPerNode'); 
end


        
        
        
