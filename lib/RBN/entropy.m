function H = entropy(rulesMatrix)

% ENTROPY Calculate the entropy of the system. Indicator for the diversity of the rules in the network.
%   
%   ENTROPY(RULESMATRIX) calculates the entropy by inspection of the RULESMATRIX
% 
%   Input:
%       rulesMatrix        - 2^k x n matrix containing transition logic rules for each node
%
%   Output: 
%       H                  - Normalized Entropy [0,1]
%


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 4.12.2002 LastModified: 20.01.2003

if(nargin == 1)
    
    rulesMatrix32 = double(rulesMatrix); % as the + operation is not defined for int8
    n = length(rulesMatrix32(1,:)); 
    heigth = length(rulesMatrix32(:,1));
    
    [B, I, J] = unique(rulesMatrix32','rows');
    B = B'; I = I'; J = J';
    rmax = length(I);
    
    H = 0;
    for i=1:rmax
        q=0;
        for j=1:n
            nbIdentical = length(find(B(:,i) == rulesMatrix32(:,j)));
            if (nbIdentical == heigth)
                q = q + 1;
            end
        end   
        q = q/n;
        H = H + q * log10(1/q);
    end   
    
    H = H/log10(n);
    
else
    error('Wrong number of arguments. Type: help entropy')
end

