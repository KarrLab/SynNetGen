function  [varargout] = findAttractor(varargin)

% FINDATTRACTOR Return attractor length and states in attractor. 
%
% 
%(1)FINDATTRACTOR(TSM) searches TSM for an attractor and returns its length and
%   the node-states in the attractor.
%
%(2)FINDATTRACTOR(NODE, MODE, TMAX) evolves all nodes in NODE in MODE update-scheme until an
%   attractor is found. Returns attractor length, NODE structure-array in its first attractor state
%   and the time state matrix up to and including the first attractor state. If after TMAX steps no
%   attractor is found, then the search is stopped and ATTRLENGTH is set to zero.
%
%
%   Input:
%    (1)tsm                   - n x k+1 matrix containing node-states for n nodes at k timesteps
%
%
%    (2)node                  - 1 x n structure-array containing node information
%    (2)mode                  - String defining update scheme. Currently supported modes are:
%                               CRBN, ARBN, DARBN, GARBN, DGARBN
%    (2)tMax                  - Maximal number of time steps to search for attractor
%
%   Output:  
%    (1+2)attrLength          - Attractor length; if tMax has been reached before having found an attractor,
%                               then attrLength is set to zero.
%    (1)attrStates            - n x attractorLength matrix with all node states in attractor
%
%    (2)nodeAtAttractorEntry  - 1 x n structure-array containing node information on entry in attractor
%    (2)tsmOut                - n x k+1 matrix containing node-states for n nodes at k timesteps


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 27.11.2002 LastModified: 20.01.2003


% (1) parameter call has been used
if(nargin == 1)
    tsm = varargin{1};
        
    nmax = length(tsm(:,1));
    kmax = length(tsm(1,:));
    attractorFound = 0;
    
    for k = 1:kmax;
        for j = k+1:kmax;
            nbIdenticalNodes = length(find(tsm(:,k) == tsm(:,j)));
            if(nbIdenticalNodes == nmax)
                attractorFound = 1;   
                break;
            end
        end  
        if(nbIdenticalNodes == nmax)
            break;
        end
    end
    
    if(attractorFound == 1)
        attrStates = zeros(nmax,j-k+1);
        for m=k:j
            attrStates(:,m-k+1) = tsm(:,m);
        end
        attrLength = j-k;
    else
        attrStates = [];
        attrLength = inf;
    end
    
    varargout{1} = attrLength;
    varargout{2} = attrStates;
    
    
% (2) parameter call has been used
elseif(nargin == 3)
    node = varargin{1};
    mode = varargin{2};
    tMax = varargin{3};  
    
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
    
    attractorFound = 0;
    n = length(node);
    attractorIndex = 0;
        
    [nodeUpdated tsmOut(1:n,1:2)] = feval(fHandle,node);    
    k = 3;
    
    while(attractorFound == 0)
        
        [nodeUpdated tsmOut(1:n,k-1:k)] = feval(fHandle,nodeUpdated);
        
        for i=k-1:-1:1
            nbIdenticalNodes = length(find(tsmOut(:,k) == tsmOut(:,i)));
            if(nbIdenticalNodes == n)
                attractorFound = 1;
                attractorIndex = i;                
                break;    
            end
            
        end % end for
        
        k = k + 1;
        if(k > tMax)
            break;
        end
        
    end % end while
    
    k = k - 1; % we've done one iteration to much in the while loop
    
    % attractorIndex;
    if(k+1>tMax)
        varargout{1} = 0;
    else
        varargout{1} = k - attractorIndex;  % attractorLength
    end
    varargout{2} = nodeUpdated;             % nodeAtAttractorEntry
    varargout{3} = tsmOut(:,1:attractorIndex);
    
       
else
    error('Wrong number of arguments. Type: help findAttractor')    
end