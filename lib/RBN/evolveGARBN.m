function [nodeUpdated, timeStateMatrix] = evolveGARBN(node, varargin)

% EVOLVEGARBN Develop network gradually K discrete time steps according to GARBN (Generalized 
% Asynchronous Random Boolean Network) update scheme
%
%   EVOLVEGARBN(NODE) advances all nodes in NODE one time-step in GARBN update mode.
%   
%   EVOLVEGARBN(NODE, K) advances all nodes in NODE K time-steps in GARBN update mode.
% 
%   EVOLVEGARBN(NODE, K, TK) advances all nodes in NODE K time-steps in GARBN update mode
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
    error('Wrong number of arguments. Type: help evolveGARBN');
end

nodeUpdated = resetNodeStats(node);

timeStateMatrix = zeros(length(nodeUpdated), k+1);
timeStateMatrix(1:length(nodeUpdated),1) = getStateVector(nodeUpdated)';

n = length(nodeUpdated);

% evolve network
for i=2:k+1
    
    howManyNodes = randint(1,1,[0 n]);
    nodeSelected = randint(1,howManyNodes,[1 n]);
    
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
