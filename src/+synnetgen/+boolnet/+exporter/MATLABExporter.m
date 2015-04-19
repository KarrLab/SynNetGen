%Exports network to MATLAB function
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef MATLABExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'MATLAB'
        description = 'MATLAB function exporter'
        inputs = struct(...            
            'filename', 'File name' ...
            )
        outputs = struct (...
            'boolnet', 'Boolean network'...
            )
    end
    
    methods (Static)
        function status = run(boolnet, varargin)
            %% parse arguments
            validateattributes(boolnet, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
            ip = inputParser;
            ip.addParameter('filename', []);
            ip.parse(varargin{:});
            filename = ip.Results.filename;
            
            if isempty(filename)
                throw(MException('SynNetGen:InvalidArgument', 'filename must be defined'));
            end
            
            %% export
            fid = fopen(filename, 'w+');
            if fid == -1
                throw(MException('SynNetGen:UnableToOpenFile', 'Unable to open file %s', filename));
            end
            
            fprintf(fid, 'function x1 = updateModel(x0)\n');
            fprintf(fid, 'x1 = x0;\n');
            for iNode = 1:numel(boolnet.nodes)                
                if ~isempty(boolnet.rules{iNode})
                    fprintf(fid, 'x1.%s = %s; %%%s\n', ...
                        boolnet.nodes(iNode).id, ...
                        regexprep(boolnet.rules{iNode}, '([a-z][a-z0-9_]*)', 'x0.$1', 'ignorecase'), ...
                        boolnet.nodes(iNode).label);
                end
            end
            
            fclose(fid);
            
            status = true;
        end
    end
end