%Exports network to SBML using species and repeatedAssignment rules. Note:
%Replaces "~" with "-" because "~" is not supported by SimBiology.
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef SBMLExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'sbml'
        description = 'SBML exporter'
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
            model = boolnet.convert('SimBiology');
            sbmlexport(model, filename);
            
            status = true;
        end
    end
end