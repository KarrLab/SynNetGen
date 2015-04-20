%Convert Boolean gene regulatory network to ODE model without proteins
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef GrnOdeConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'grn-ode'
        description = 'Convert gene regulatory network to ODE model (without proteins)'
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