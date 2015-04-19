function [nodeUpdated, timeStateMatrix] = displayEvolution(node, k, mode, varargin)

% DISPLAYEVOLUTION Calculate and visualize evolution of NODE over K discrete time steps according to MODE update scheme
%
%   DISPLAYEVOLUTION(NODE, K, MODE) advances all nodes in NODE K time steps in update mode defined
%   by MODE and displays node states.
%   
%   DISPLAYEVOLUTION(NODE, K, MODE, TK, SAVEFLAG) advances all nodes in NODE K time steps in update mode defined
%   by MODE and displays node states. All TK steps, node-states and the timeStateMatrix are saved to the current
%   directory. Furthermore, if the SAVEFLAG is set, the figure is saved to the disk.
%   
%
%   Input:
%       node               - 1 x n structure-array containing node information
%       k                  - Number of discrete timesteps
%       mode               - String defining update scheme. Currently supported modes are:
%                            CRBN, ARBN, DARBN, GARBN, DGARBN
%       tk                 - (Optional) Period for saving node-states/timeStateMatrix to disk.
%       saveFlag           - (Optional) Flag: 1 - Figure will be saved to disk  0 - no saving
%
%   Output: 
%       nodeUpdated        - 1 x n structure-array with updated node information
%       timeStateMatrix    - n x k+1 matrix containing calculated time-state evolution                                        
%

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 15.11.2002 LastModified: 20.01.2003

if (nargin == 3 | nargin == 4 | nargin == 5)
   
    if(nargin == 5)
        tk = varargin{1};
        saveFlag = varargin{2};
    else
        tk = inf;
        saveFlag = 0;
    end
    
    
    nodeUpdated = node;    
    
    switch mode
    case 'CRBN'
        fHandle = @evolveCRBN;
    case 'ARBN'
        fHandle = @evolveARBN;
    case 'DARBN'
        fHandle = @evolveDARBN;
    case 'GARBN'
        fHandle = @evolveGARBN;
    case 'DGARBN' 
        fHandle = @evolveDGARBN;
    otherwise
        error('Unknown update mode. Type ''help displayEvolution'' to see supported modes')    
    end
      
    
    timeStateMatrix = zeros(length(nodeUpdated),k+1);
    % evolve network in specified update mode
    [nodeUpdated timeStateMatrix(1:length(nodeUpdated),1:k+1)] = feval(fHandle,nodeUpdated,k,tk);
    
    displayTimeStateMatrix(timeStateMatrix,saveFlag);
    
else
    error('Wrong number of arguments. Type: help displayEvolution')    
end