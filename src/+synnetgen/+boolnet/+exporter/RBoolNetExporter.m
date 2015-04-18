%Exports network to R BoolNet format
%(http://cran.r-project.org/package=BoolNet).
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef RBoolNetExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'R-BoolNet'
        description = 'R BoolNet exporter'
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
            
            fprintf(fid, 'targets, factors\n');
            for iNode = 1:numel(boolnet.nodes)
                if ~isempty(boolnet.rules{iNode})
                    rule = boolnet.rules{iNode};
                else
                    rule = '1';
                end
                    
                fprintf(fid, '#%s: %s\n', boolnet.nodes(iNode).id, boolnet.nodes(iNode).label);
                fprintf(fid, '%s, %s\n', boolnet.nodes(iNode).id, rule);
            end
            
            fclose(fid);
            
            status = true;
        end
    end
end