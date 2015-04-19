function displayTimeStateMatrix(tsm,varargin)

% DISPLAYTIMESTATEMATRIX Visualize Time-State-Matrix.
%
%   DISPLAYTIMESTATEMATRIX(TSM) visualizes Time-State-Matrix TSM.
%   
%   DISPLAYTIMESTATEMATRIX(TSM, SAVEFLAG) visualizes Time-State-Matrix TSM and saves figure to disk.
%
%   Input:
%       tsm                - n x k+1 matrix containing node-states for n nodes at k timesteps
%       saveFlag         - (Optional) Flag: 1 - Figure will be saved to disk  0 - no saving
%
%   Output:
%       -


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 20.11.2002 LastModified: 18.12.2002

if(nargin == 2)
  saveFlag = varargin{1};
elseif(nargin == 1)
  saveFlag = 0;
else    
  error('Wrong number of arguments. Type: help displayTimeStateMatrix');
end

fHandle = figure;
set(fHandle,'Color','w','Name','Time-State Evolution');

n = length(tsm(:,1));
k = length(tsm(1,:))-1;
timeStateMatrix = [tsm zeros(length(tsm(:,1)),1)];
timeStateMatrix = [timeStateMatrix; zeros(1,length(timeStateMatrix(1,:)))];
pcolor(timeStateMatrix);

colormap(gray(2));
axis ij; axis off;
figure(fHandle);

%xlabel('Time');
%ylabel('States');

str = sprintf('Time-State evolution of a network with %d nodes over %d discrete time-steps',n, k);
title(str);

cameratoolbar('Show');
cameratoolbar('SetMode','zoom');

if(saveFlag)
    saveFigure(gcf);
end

