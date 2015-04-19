function filename = saveFigure(figure, varargin)

% SAVEFIGURE Save a figure to the current directory in two formats (*.fig and *.eps).
% 
%   SAVEFIGURE(FIGURE) generates a filename and saves the figure FIGURE to the associated file.
%
%   SAVEFIGURE(FIGURE, FILENAME) saves the figure FIGURE to the file FILENAME
%
%   Input:
%       figure      - Figure to be saved
%       filename    - (Optional) String containing filename
%
%   Output:
%       filename    - Filename
%

%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 25.11.2002 LastModified: 20.01.2003

switch nargin
    
case 1   
     filename = datestr(now,'yyyymmddTHHMMSS');
     
case 2
     filename = varargin{1}; 
     
 otherwise
   error('Wrong number of arguments. Type: help saveFigure')
end

saveas(figure, filename, 'fig');
saveas(figure, filename, 'eps');
