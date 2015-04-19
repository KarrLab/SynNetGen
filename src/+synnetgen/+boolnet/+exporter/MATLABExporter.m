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
            
            fprintf(fid, 'function y1 = updateModel(t, y0)\n');
            
            for iNode = 1:numel(boolnet.nodes)
                fprintf(fid, '%%%s: %s\n', boolnet.nodes(iNode).id, boolnet.nodes(iNode).label);
            end
            fprintf(fid, '\n');
            
            fprintf(fid, 'y1 = false(size(y0));\n');
            for iNode = 1:numel(boolnet.nodes)
                rule = boolnet.rules{iNode};
                if isempty(boolnet.rules{iNode})
                    rule = boolnet.nodes(iNode).id;
                end
                
                for iNode2 = 1:numel(boolnet.nodes)
                    rule = regexprep(rule, ['(^|[^a-zA-Z])' boolnet.nodes(iNode2).id '([^a-zA-Z0-9_]|$)'], sprintf('$1y0(%d)$2', iNode2));
                end
                
                fprintf(fid, 'y1(%d) = %s;\n', iNode, rule);
            end
            
            fclose(fid);
            
            status = true;
        end
    end
end