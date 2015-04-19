function [nodeUpdated, fHandleOut, kav, meankav] = evolveTopology(node, mode, tSteps, initialK, hazard, varargin)

% EVOLVETOPOLOGY Evolve and display topology according to algorithm described by Christof Teuscher and Eduardo Sanchez
% in "Self-Organizing Topology of Turing Neural Networks". Make sure to use a fully connected network (N=K)!
%
%   EVOLVETOPOLOGY(NODE, MODE, TSTEPS, INITIALK, HAZARD) evolves NODE in MODE update-scheme over TSTEPS discrete time-steps with
%   numbers of connections per node initially set to INITIALK.
%   Paramters of algorithm: runLength is set to N (number of nodes), threshold to 0 and tMax to infinity. HAZARD 
%   defines the number of randomly added/removed connections per time-step.
%
%   EVOLVETOPOLOGY(NODE, MODE, TSTEPS, INITIALK, HAZARD, FHANDLEIN) evolves NODE in MODE update-scheme over TSTEPS discrete time-steps with
%   numbers of connections per node initially set to INITIALK. The graph is plotted in the figure window referenced by FHANDLEIN.
%   Paramters of algorithm: runLength is set to N (number of nodes), threshold to 0 and tMax to infinity. HAZARD 
%   defines the number of randomly added/removed connections per time-step.
%
%   EVOLVETOPOLOGY(NODE, MODE, TSTEPS, INITIALK, HAZARD, RUNLENGTH, THRESHOLD) evolves NODE in MODE update-scheme 
%   over TSTEPS discrete time-steps with numbers of connections per node initially set to INITIALK,
%   using RUNLENGTH and THRESHOLD as parameters for the algorithm. tMax is set to infinity. HAZARD 
%   defines the number of randomly added/removed connections per time-step.
%   
%   EVOLVETOPOLOGY(NODE, MODE, TSTEPS, INITIALK, HAZARD, FHANDLEIN, RUNLENGTH, THRESHOLD, TMAX) evolves NODE in MODE update-scheme 
%   over TSTEPS discrete time-steps with numbers of connections per node initially set to INITIALK,
%   using RUNLENGTH, THRESHOLD and TMAX as parameters for the algorithm. The graph is plotted in the figure 
%   window referenced by FHANDLEIN. HAZARD defines the number of randomly added/removed connections per time-step.
%
% 
%   Input:
%       node               - 1 x n structure-array containing node information
%       mode               - String defining update scheme. Currently supported modes are:
%                            CRBN, ARBN, DARBN, GARBN, DGARBN
%       tSteps             - Number of time steps to run (Parameter T)
%       initialK           - Initial value for connectivity
%       hazard             - Number of randomly (not according to evolution rule) added/removed connections per time-step
%       fHandleIn          - (Optional) Handle to figure window
%       runLength          - (Optional) Length of 'activity measuring' (Parameter L)
%       threshold          - (Optional) Activity threshold 
%       tMax               - (Optional) Maximal number of time steps to search for attractor
%
%   Output: 
%       nodeUpdated        - 1 x n sturcture-array with updated node information
%                            ("lineNumber", "state", "nextState")         
%       fHandleOut         - Handle to figure window 
%       kav                - Average connectivity for each time-step (raw)
%       meankav            - Cumulative average connectivity for each time-step
%
%  Examples:
%  [node, conn, rules] = bsn(10, 10, 'line')
%
%  [nodeUpdated, fHandleOut] = evolveTopology(node, 'ARBN', 100, 0, 1, 50, 0)
%  [nodeUpdated, fHandleOut] = evolveTopology(node, 'ARBN', 100, 10, 1, fHandleOut, 50, 0, 50)     
%

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 4.12.2002 LastModified: 20.01.2003
%   
%   Modified and extended:
%   ----------------------------------------------------------------
%   (c) 2004 Christof Teuscher
%   christof@teuscher.ch | http://www.teuscher.ch/christof
%   ----------------------------------------------------------------
% 

switch nargin
case 5
    runLength = length(node);
    threshold = 0;  
    fHandleIn = figure;
    tMax = inf;
    
case 6
    runLength = length(node);
    threshold = 0;  
    fHandleIn = varargin{1};
    tMax = inf;
    
    
case 7
    runLength = varargin{1};
    threshold  = varargin{2};
    fHandleIn = figure;
    tMax = inf;
    
case 9
    fHandleIn = varargin{1};
    runLength = varargin{2};
    threshold  = varargin{3};
    tMax = varargin{4};
    
otherwise
    error('Wrong number of arguments. Type: help evolveTopology')    
end



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
    error('Unknown update mode. Type ''help evolveTopology'' to see supported modes')    
end


nodeUpdated = node;
n = length(node);
kav = zeros(1,tSteps);
meankav =  [];

maxConn = averageConnectivity(nodeUpdated);
if(maxConn < initialK)
    error('Initial value for K is too big.');
end

% set initial connectivity
if(initialK >= 1)
    for j=1:n
        nodeUpdated(j).input = [nodeUpdated(j).input(1:initialK)];
    end
else
    for j=1:n
        nodeUpdated(j).input = [];
    end
    
end


kav(1) = initialK;
meankav(1) = initialK;

% calculate topology evolution
for t=1:tSteps
    t   % display current time-step for user information
    nodeUpdatedOld = nodeUpdated;
    
    [alengthSpill, nodeUpdated, tsmSpill] = findAttractor(nodeUpdatedOld,mode,tMax);
    
    
    if(alengthSpill == 0)   % no attractor found       
        [nodeSpill, tsm] = feval(fHandle, nodeUpdatedOld, tMax);
    else                   % attractorHasBeenfound = 1;                                      
        [nodeSpill, tsm] = feval(fHandle, nodeUpdated, runLength);   
    end
    
    activity = countTransitionsPerNode(tsm); % display activity in attractor for user information
    
    for i=1:n 
        
        activity(i);
        k = length(nodeUpdated(i).input);
        
        if(activity(i) <= threshold)
            if(k<maxConn)   % add new connection at random
                newInput = randint(1,1,[1,n]);
                nodeUpdated(i).input(k+1) = newInput;     
            end
        else
            if(k>0)         % delete one connection at random
                nDelete = randint(1,1,[1,k]);
                nodeUpdated(i).input = [nodeUpdated(i).input(1:nDelete-1), nodeUpdated(i).input(nDelete+1:end)];
            end             
            
        end % end first if
        
    end % end for i=1:n           
    
    % hazard - adds or removes connections at random
    if(hazard > 0)
        
        for j=1:1:hazard
            affectedNode = randint(1,1,[1,n]);
            add_remove = randint(1,1,[0,1]);
            k = length(nodeUpdated(affectedNode).input);
            
            if(add_remove == 1 & k < maxConn)
                newInput = randint(1,1,[1,n]);
                nodeUpdated(affectedNode).input(k+1) = newInput;
            else if(add_remove == 0 & k > 0)
                    nDelete = randint(1,1,[1,k]);
                    nodeUpdated(affectedNode).input = [nodeUpdated(affectedNode).input(1:nDelete-1), nodeUpdated(affectedNode).input(nDelete+1:end)];
                end
            end
        end        
    end
    
    kav(t+1) = averageConnectivity(nodeUpdated);
    meankav(t+1)= mean(kav(1:t+1));
    
end % end for t=1:tSteps



% display topology evolution
figure(fHandleIn);
str = sprintf('Evolution of Network Topology for N = %d over T = %d', n, tSteps);
set(fHandleIn,'Color','w','Name', str);

str3 = '';
str3 = sprintf('N = %d , T = %d, Mode = %s , L = %d , Threshold = %d, Hazard = %d  ', n, tSteps, mode, runLength, threshold, hazard);

plot(0:1:tSteps,meankav,'b'); hold on;
plot(0:1:tSteps,kav,'r:'); 
legend('cumulative mean', 'raw');

xlabel('Time Steps');
ylabel('Connectivity = Number of incoming links per node');

title(str3);
fHandleOut = fHandleIn;




