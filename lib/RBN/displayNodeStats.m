function nbChangesPerNode = displayNodeStats(node,tsm)

% DISPLAYNODESTATS Visualize node statistics (number of updates / nb of state-transitions).
% 
%   DISPLAYNODESTATS(NODE, TSM) shows number of updates per node (extracted from NODE) and
%   number of transitions per node (extracted from TSM).
%
%   Input:
%       tsm                -  n x k+1 matrix containing node-states for n nodes at k timesteps
%       node               -  1 x n structure-array containing node information
%
%   Output:
%       nbChangesPerNode    - Number of changes of each node (column vector)
%

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 27.11.2002 LastModified: 20.01.2003

if(nargin == 2)
    
    nbUpdatesPerNode = zeros(length(node),1);
    
    % get number of updates per node directly from node structure array
    for i=1:length(node)
        nbUpdatesPerNode(i) = node(i).nbUpdates;
    end
    
    nbChangesPerNode = countTransitionsPerNode(tsm);
    
    % display graph
    str = sprintf('Node Statistics for a network with %d nodes over %d discrete time steps', length(node), length(tsm(1,:))-1);
    fHandle = figure;
    set(fHandle,'Color','w','Name',str);
    
    subplot(2,1,1);
    bar(nbUpdatesPerNode);
    %xlegend('Node number');
    %ylegend('Number of updates');
    title('Updates');
    
    subplot(2,1,2);
    bar(nbChangesPerNode);
    %xlegend('Node number');
    %ylegend('Number of statetransitions');
    title('State-transitions ');
    
else
    error('Wrong number of arguments. Type: help displayNodeStats') 
end


    

