%Installs SynNetGen software
%- Check requirements
%  - MATLAB >= 2014a
%  - GraphViz >= 2.36.0
%- Adds source and test code to MATLAB path
%- Verifies tests
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
function install()

%% Check requirements
%MATLAB >= 2014a
if verLessThan('matlab', '8.3.0')
    warning('SynNetGen:warning', 'tested on MATLAB 2014a. MATLAB >= 2014a may be required');
end

%GraphViz >= 2.36
[status, result] = system('dot -V');
if status
    throw(MException('SynNetGen:InvalidRequirements', 'GraphViz not installed'))
end

info = regexp(result, 'dot - graphviz version (?<version>\d+)\.(?<subversion>\d+)\.(?<subsubversion>\d+) \((?<year>\d{4,4})(?<month>\d{2,2})(?<day>\d{2,2}).(?<revision>\d+)\)\n', 'names');
if str2double([info.version '.' info.subversion]) < 2.36
    warning('SynNetGen:InvalidRequirements', 'Tested on GraphViz 2.36. GraphViz >= 2.36 may be required.')
end

%libSBML-matlab
if isempty(which('TranslateSBML'))
    throw(MException('SynNetGen:InvalidRequirements', 'libSBML-MATLAB not installed'))
end

%% check not installed
baseDir = fileparts(mfilename('fullpath'));
currPath = strsplit(path(), pathsep);
if ismember(baseDir, currPath)
    throw(MException('SynNetGen:AlreadyInstalled', 'SynNetGen already installed'));
end

%% add source, test code to path
addpath(fullfile(baseDir, 'src_test'));
addpath(fullfile(baseDir, 'lib/m2html'));
addpath(fullfile(baseDir, 'lib/graphviz4matlab'));
addpath(fullfile(baseDir, 'lib/graphviz4matlab/layouts'));
addpath(fullfile(baseDir, 'lib/graphviz4matlab/util'));
addpath(fullfile(baseDir, 'lib/RBN'));
addpath(fullfile(baseDir, 'src'))
addpath(baseDir)

%% build and run tests
status = true;
try
    build();
    fprintf('Build succeed!\n');
catch
    status = status && false;
    fprintf('Unable to build software.\n');
end

try
    test();
    fprintf('Tests passed!\n');
catch
    status = status && false;
    fprintf('Tests failed.\n');
end

%undo path if not successful
if ~status
    rmpath(fullfile(baseDir, 'src_test'));
    rmpath(fullfile(baseDir, 'lib/m2html'));
    rmpath(fullfile(baseDir, 'lib/graphviz4matlab'));
    rmpath(fullfile(baseDir, 'lib/graphviz4matlab/layouts'));
    rmpath(fullfile(baseDir, 'lib/graphviz4matlab/util'));
    rmpath(fullfile(baseDir, 'lib/RBN'));
    rmpath(fullfile(baseDir, 'src'));
    rmpath(baseDir);
    return
end
    
%% report success
fprintf('SynNetGen succesfully installed!\n');