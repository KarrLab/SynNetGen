%Exports ODE model to SBML
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
            model = odes.convert('SimBiology');
            sbmlexport(model, filename);
            
            status = true;
        end
    end
end