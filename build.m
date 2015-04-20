%Builds SynNetGen software
%- Creates folders for extensions
%- Verifies tests
%- Generates documentation
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
function build()

%% setup extension folders
modelTypes = {
    'graph'
    'boolnet'
    'odes'
    };
extTypes = {
    'generator'
    'transform'
    'converter'
    'exporter'
    'importer'
    };
for iModelType = 1:numel(modelTypes)
    for iExtType = 1:numel(extTypes)
        dirName = fullfile('src', '+synnetgen', ['+' modelTypes{iModelType}], ['+' extTypes{iExtType}]);
        if ~exist(dirName, 'dir')
            mkdir(dirName);
        end
    end
end

%% setup temporary directory
if ~exist('tmp', 'dir')
    mkdir('tmp');
end

%% compile documentation
%create output directories
if ~exist('doc', 'dir')
    mkdir('doc');
end

if ~exist('doc/example', 'dir')
    mkdir('doc/example');
end

if exist('doc/m2html', 'dir')
    rmdir('doc/m2html', 's');
end
mkdir('doc/m2html');

%generate source documentation
baseDirAbs = fileparts(mfilename('fullpath'));
tmp = strsplit(baseDirAbs, filesep);
baseDirParent = strjoin(tmp(1:end-1), filesep);
baseDirRel = tmp{end};

cd(baseDirParent);
m2html(...
    'mfiles', baseDirRel, ...
    'ignoredDir', {
        'doc'
        'lib'
        'src_test'
        }, ...
    'recursive', 'on', ...
    'global', 'on', ...
    'htmldir', fullfile(baseDirRel, 'doc/m2html'), ...
    'graph', 'on', ...
    'verbose', 'off')
cd(baseDirAbs);