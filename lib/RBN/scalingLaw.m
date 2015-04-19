function [x, y_min, y_max, y_av] = scalingLaw(n, mode, tSteps, r, varargin)

% SCALINGLAW Visualize Scaling Law.
%
%  SCALINGLAW(N, MODE, TSTEPS, R) visualizes scaling law for networks with N(.) nodes and
%  MODE update scheme over TSTEPS time-steps. The averages are formed over R networks at each
%  N(.).
%  Paramters of algorithm: runLength is set to N (number of nodes), threshold to 0 and tMax to infinity. 
%
%  SCALINGLAW(N, MODE, TSTEPS, R, RUNLENGTH, THRESHOLD) visualizes scaling law for networks with N nodes and
%  MODE update scheme over TSTEPS time-steps, using RUNLENGTH, THRESHOLD and TMAX as parameters for the algorithm.
%  The averages are formed over R networks at each N(.).
%
%   Input:
%       n                  - Array containing different values for N
%       mode               - String defining update scheme. Currently supported modes are:
%                            CRBN, ARBN, DARBN, GARBN, DGARBN
%       tSteps             - Number of time steps to run (Parameter T)
%       r                  - Number of networks to evaluate to form average
%       runLength          - (Optional)Array containing lengths of 'activity measuring' (Parameter L)
%       threshold          - (Optional)Array containing activity thresholds 
%
%   Output: 
%       y_max              - Kev(N) - 2 (Max)
%       y_min              - Kev(N) - 2 (Min)
%       y_av               - Kev(N) - 2 (Average)
%       x                  - N


switch nargin
case 4
    for j=1:length(n)
        runLength(j) = n(j);    
    end
    threshold = zeros(length(n),1);  
    
case 6
    runLength = varargin{1};
    threshold = varargin{2}; 
    
otherwise
    error('Wrong number of arguments. Type: help scalingLaw')    
end


y_max = zeros(1,length(n));
y_min = zeros(1,length(n));
fHandleEvolve = figure;

% compute scaling law
for i=1:length(n)    
    for j = 1:1:r
        
        % build network 
        node = initNodes(n(i));
        conn= initConnections(n(i), n(i));
        rules = initRules(n(i), n(i));
        node = assocRules(node, rules);
        nodeUpdated = assocNeighbours(node, conn);
        

        % Thu Feb  6 15:21:07 MET 2003 chT
        % hasard = 1!

        % idea:  node = initNodes(5), then start with K=0 => less memory used!

        % evolve network starting from initialK = n(i) and get critical value for connectivity
        [nuSpill,fHandleEvolve,kav,meankav] = evolveTopology(nodeUpdated, mode, tSteps, n(i),1,fHandleEvolve,runLength(i),threshold(i),inf);
        y_max(i) = y_max(i) + meankav(end);
        
        % evolve network starting from initialK = 0 and get critical value for connectivity
        %[nuSpill,fHandleEvolve,kav,meankav] = evolveTopology(nodeUpdated, mode, tSteps, 0,1,fHandleEvolve,runLength(i),threshold(i),inf);
        %y_min(i) = y_min(i) + meankav(end);
        
                      
    end
end

y_max = (y_max./r); %version without substraction of 2
%y_min = (y_min./r); %version without substraction of 2

%y_av = (y_max + y_min) ./ 2;


% display scaling Law
fHandle1 = figure;
str = sprintf('Scaling Law');
set(fHandle1,'Color','w','Name', str);

loglog(n,y_max,'b'); hold on;
loglog(n,y_max,'bo'); hold on;

%loglog(n,y_max,'r:'); hold on;
%loglog(n,y_min,'r:'); hold on;
%loglog(n,y_av,'bo'); 

str4 = sprintf('Scaling Law average over %d networks with \n Time-steps = %d, Mode = %s, L = %d , Threshold = %d  ',r, tSteps, mode, runLength, threshold);
title(str4);

%legend('average');
xlabel('N');
ylabel('Kev(N)');
hold off;

