%Uninstalls SynNetGen software
%- Removes source and test code from MATLAB path
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
function uninstall()

%get root directory of software
baseDir = fileparts(mfilename('fullpath'));

%check installed
currPath = strsplit(path(), pathsep);
if ~ismember(baseDir, currPath)
    throw(MException('SynNetGen:NotInstalled', 'SynNetGen is not installed'));
end

%remove source, test code from path
rmpath(fullfile(baseDir, 'src_test'));
rmpath(fullfile(baseDir, 'doc'))
rmpath(fullfile(baseDir, 'lib/m2html'));
rmpath(fullfile(baseDir, 'lib/graphviz4matlab'));
rmpath(fullfile(baseDir, 'lib/graphviz4matlab/layouts'));
rmpath(fullfile(baseDir, 'lib/graphviz4matlab/util'));
rmpath(fullfile(baseDir, 'lib/RBN'));
rmpath(fullfile(baseDir, 'tmp'));
rmpath(fullfile(baseDir, 'src'));
rmpath(baseDir);

%report success
fprintf('SynNetGen succesfully uninstalled!\n');