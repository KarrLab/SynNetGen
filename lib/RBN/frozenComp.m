function [x, y] = frozenComp(kMax, n, r, step ,mode)

% FROZENCOMP Visualize frozen components graph.
% 
%  FROZENCOMP(KMAX, N, R, STEP, MODE) visualizes ratio of frozen components for K=0 to KMAX using steps of size STEP.
%  Each ratio is an average over R randomly chosen networks with N nodes being evolved in MODE update-scheme.
%
%   Input:
%       kMax               - Maximum value for K on the x-axis.
%       n                  - Number of nodes
%       r                  - Number of networks to evaluate to form average
%       step               - Step size on x-axis (K-axis)
%       mode               - String defining update scheme. Currently supported modes are:
%                            CRBN, ARBN, DARBN, GARBN, DGARBN

%   Output:
%       x                 - Values of K for which c(k,n) has been calculated 
%       y                 - c(k,n)

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 6.1.2003 LastModified: 20.01.2003

c = zeros(1,round(kMax/step+1));
x = zeros(1,round(kMax/step+1));

c(1) = 1;

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
    error('Unknown update mode. Type ''help frozenComp'' to see supported modes')    
end


% compute c(n,k) for each k over r topologies
for k =step:step:kMax
   
    x_av = 0;
    for i = 1:1:r
                
        [nodeUpdated, x_temp] = bnKav(n,k);
        x_av = x_av + x_temp;
        
        [alength, nodeUpdated, tsm] = findAttractor(nodeUpdated,mode,inf);
        [nodeSpill, tsm] = feval(fHandle, nodeUpdated, alength);
        
        activity = countTransitionsPerNode(tsm);
        
        c(round(k/step+1)) = c(round(k/step+1)) + length(find(activity == 0))/length(activity);
      
    end
    
    x(round(k/step+1)) = x_av/r;
    
end

% form average
y = c./r;
y(1) = y(1)*r;

% display graph
fHandle = figure;
figure(fHandle);
str = sprintf('Frozen Component C(N,K) with N = %d in %s update-mode. Average over %d networks', n, mode,r);
set(fHandle,'Color','w','Name', str);

plot(x,y,'bo-');

str2 = sprintf('Frozen Component C(N,K) with N = %d, Mode = %s, \n Stepsize on x-axis = %d,  Average over R = %d Topologies', n, mode, step , r);

xlabel('K');
ylabel('C(K,N)');

title(str2);
