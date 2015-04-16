%Builds SynNetGen software
%- Verifies tests
%- Generates documentation
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
function build()

%% compile documentation
%create output directory
if exist('doc/m2html', 'dir')
    rmdir('doc/m2html', 's');
end
mkdir('doc/m2html');

%generate documentation
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