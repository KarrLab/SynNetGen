function [nodeUpdated, timeStateMatrix] = evolveCRBN(node, varargin)

% EVOLVECRBN Develop network gradually K discrete time-steps according to CRBN (Classical
% Random Boolean Network) update scheme.
%
%   EVOLVECRBN(NODE) advances all nodes in NODE one time-step in CRBN update mode.
%   
%   EVOLVECRBN(NODE, K) advances all nodes in NODE K time-steps in CRBN update mode.
% 
%   EVOLVECRBN(NODE, K, TK) advances all nodes in NODE K time-steps in CRBN update mode
%   and saves all TK steps all node-states and the timeStateMatrix to the disk.
%
%
%   Input:
%       node               - 1 x n structure-array containing node information
%       k                  - (Optional) Number of time-steps
%       tk                 - (Optional) Period for saving node-states/timeStateMatrix to disk.
%
%
%   Output: 
%       nodeUpdated        - 1 x n sturcture-array with updated node information
%                            ("lineNumber", "state", "nextState")                           
%       timeStateMatrix    - n x k+1 matrix containing calculated time-state evolution                                        



%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 15.11.2002 LastModified: 20.01.2003




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
    error('Wrong number of arguments. Type: help evolveCRBN');
end

nodeUpdated = resetNodeStats(node);

timeStateMatrix = zeros(length(nodeUpdated), k+1);
timeStateMatrix(1:length(nodeUpdated),1) = getStateVector(nodeUpdated)';

% evolve network
for i=2:k+1
    
  
    nodeUpdated = setLUTLines(nodeUpdated);        
    nodeUpdated = setNodeNextState(nodeUpdated);
    
    
    for j=1:length(nodeUpdated)
        nodeUpdated(j).state = nodeUpdated(j).nextState;
        nodeUpdated(j).nbUpdates = nodeUpdated(j).nbUpdates + 1;
    end
    
    timeStateMatrix(1:length(nodeUpdated),i) = getStateVector(nodeUpdated)';
    
    if(mod(i-1,tk) == 0)
        saveMatrix(nodeUpdated);
        saveMatrix(timeStateMatrix(:,1:i));
        i-1; % display current time-step for user information
    end

end
