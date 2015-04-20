%Exports ODE model to MATLAB function
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
            'odes', 'ODE model'...
            )
    end
    
    methods (Static)
        function status = run(odes, varargin)
            %% parse arguments
            validateattributes(odes, {'synnetgen.odes.Odes'}, {'scalar'});
            
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
            
            fprintf(fid, 'function dy = calcDifferentials(t, y0, k)\n');
            
            fprintf(fid, '%%Nodes\n');
            for iNode = 1:numel(odes.nodes)
                fprintf(fid, '%%  y(%d) = %s (%s)\n', iNode, odes.nodes(iNode).id, odes.nodes(iNode).label);
            end
            fprintf(fid, '%%\n');
            
            fprintf(fid, '%%Parameters\n');
            for iParam = 1:numel(odes.parameters)
                fprintf(fid, '%%  k(%d) = %s (%s)\n', iParam, odes.parameters(iParam).id, odes.parameters(iParam).label);
            end
            fprintf(fid, '\n');
            
            fprintf(fid, 'dy = zeros(size(y0));\n');
            for iNode = 1:numel(odes.nodes)
                differential = odes.differentials{iNode};
                if ~isempty(differential)
                    for iNodeReplace = 1:numel(odes.nodes)
                        differential = regexprep(differential, ['(^|[^a-zA-Z0-9_])' odes.nodes(iNodeReplace).id '([^a-zA-Z0-9_]|$)'], sprintf('$1y0(%d)$2', iNodeReplace));
                    end
                    for iParamReplace = 1:numel(odes.parameters)
                        differential = regexprep(differential, ['(^|[^a-zA-Z0-9_])' odes.parameters(iParamReplace).id '([^a-zA-Z0-9_]|$)'], sprintf('$1k(%d)$2', iParamReplace));
                    end
                    
                    fprintf(fid, 'dy(%d, :) = %s;\n', iNode, differential);
                end
            end
            
            fclose(fid);
            
            status = true;
        end
    end
end