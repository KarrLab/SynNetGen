function filename = saveMatrix(matrix, varargin)

% SAVEMATRIX Save a matrix to the current directory.
% 
%   SAVEMATRIX(MATRIX) generates a filename and saves the matrix MATRIX to the associated file.
%
%   SAVEMATRIX(MATRIX, FILENAME) saves the matrix MATRIX to the file FILENAME.MAT
%
%   Input:
%       matrix      - Matrix to be saved
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
     if(isstruct(matrix))
        filename = strcat(filename, 'struct');
    else
        filename = strcat(filename, 'mat');
    end 
     
case 2
     filename = varargin{1}; 
     
 otherwise
   error('Wrong number of arguments. Type: help saveMatrix')
end

save(filename, 'matrix');