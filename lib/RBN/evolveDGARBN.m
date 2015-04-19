function [nodeUpdated, timeStateMatrix] = evolveDGARBN(node, varargin)

% EVOLVEDGARBN Develop network gradually K discrete time steps according to DGARBN (Deterministic 
% Generalized Asynchronous Random Boolean Network) update scheme.
%
%   EVOLVEDGARBN(NODE) advances all nodes in NODE one time-step in DGARBN update mode.
%   
%   EVOLVEDGARBN(NODE, K) advances all nodes in NODE K time-steps in DGARBN update mode.
% 
%   EVOLVEDGARBN(NODE, K, TK) advances all nodes in NODE K time-steps in DGARBN update mode
%   and saves all TK steps all node-states and the timeStateMatrix to the disk.
%
%   Input:
%       node               - 1 x n structure-array containing node information
%       k                  - (Optional) Number of time-steps
%       tk                 - (Optional) Period for saving node-states/timeStateMatrix to disk.
%
%   Output: 
%       nodeUpdated        - 1 x n sturcture-array with updated node information
%                            ("lineNumber", "state", "nextState")                           
%       timeStateMatrix    - n x k+1 matrix containing calculated time-state evolution                                        



%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 20.11.2002 LastModified: 20.01.2003

switch nargin
case 1
    k = 1;
    tk = inf;
case 2
    k = varargin{1};
    tk = inf;
case 3
    k = varargin{1};
    tk = varargin{2}; 
otherwise
    error('Wrong number of arguments. Type: help evolveDGARBN');
end

nodeUpdated = resetNodeStats(node);

timeStateMatrix = zeros(length(nodeUpdated), k+1);
timeStateMatrix(1:length(nodeUpdated),1) = getStateVector(nodeUpdated)';

n = length(nodeUpdated);

% evolve network
for i=2:k+1
    
    timeNow = i-1;
    nodeSelected = [];
    for j=1:n
        if(mod(timeNow,nodeUpdated(j).p) == nodeUpdated(j).q)
            nodeSelected = [nodeSelected j];
        end
    end
      
    nodeUpdated = setLUTLines(nodeUpdated);
    nodeUpdated = setNodeNextState(nodeUpdated);
    
    for j=1:length(nodeSelected)
        nodeUpdated(nodeSelected(j)).state = nodeUpdated(nodeSelected(j)).nextState;
        nodeUpdated(nodeSelected(j)).nbUpdates = nodeUpdated(nodeSelected(j)).nbUpdates + 1;    
    end
    
    
    timeStateMatrix(1:length(nodeUpdated),i) = getStateVector(nodeUpdated)';
    
     if(mod(i-1,tk) == 0)
        saveMatrix(nodeUpdated);
        saveMatrix(timeStateMatrix(:,1:i));
        i-1; % display current time-step for user information
    end

end
