%Trim white space from beginning and end of string
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
function str = trim(str)
str = regexprep(str, '^(\s+)', '');
str = regexprep(str, '(\s+)$', '');