%Convert ODE model to signed, directed graph
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef GraphConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'graph'
        description = 'Convert ODE model to signed, directed graph'
        inputs = struct()
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(odes, varargin)
            import synnetgen.graph.Graph;
            
            %parse arguments
            validateattributes(odes, {'synnetgen.odes.Odes'}, {'scalar'});
            
            ip = inputParser;
            ip.addParameter('y', []);
            ip.addParameter('k', []);
            ip.parse(varargin{:});
            y = ip.Results.y;
            k = ip.Results.k;
            
            %convert to graph
            graph = Graph(odes.nodes, odes.getEdges('y', y, 'k', k));
        end
    end
end