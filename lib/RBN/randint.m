function r = randint(i,j,interval)
% randint  Random integer

% r = randint(i,j,[from,to]) Returns a ixj matrix with random 
% integers from the interval [from,to]. 
%
% Note that randint is also function of the Matlab communication
% toolbox!
%
% Inputs:
%   i            : Matrix i dimension
%   j            : Matrix j dimension
%   interval     : Integer interval [from to]
%
% Outputs:
%   r            : ixj random integer matrix
%
% Examples:
%   r = randint(1,1,[1,10])
%   r = randint(1,1,[1,10])
%   r = randint(3,4,[1,10])

       
%----------------------------------------------------------------
% (c) 2006 Christof Teuscher
% christof@teuscher.ch | http://www.teuscher.ch/christof
%----------------------------------------------------------------


from     = interval(1);
to       = interval(2);

r = from + round(rand(i,j) * (to - from));

