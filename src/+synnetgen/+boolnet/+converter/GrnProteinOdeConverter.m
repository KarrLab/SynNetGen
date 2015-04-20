%Convert Boolean gene regulatory network to ODE model with proteins
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef GrnProteinOdeConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'grn-protein-ode'
        description = 'Convert gene regulatory network to ODE model (with proteins)'
        inputs = struct()
        outputs = struct (...
            'odes', 'ODE model')
    end
    
    methods (Static)
        function odes = run(network, varargin)
            import synnetgen.odes.Odes;
            
            %parse arguments
            validateattributes(network, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
            ip = inputParser;
            ip.parse(varargin{:});
            
            %convert to graph
            odes = Odes(network.nodes, network.getEdges());
        end
    end
end