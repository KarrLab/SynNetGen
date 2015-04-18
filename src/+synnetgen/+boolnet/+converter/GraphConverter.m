%Convert Boolean network to signed, directed graph
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef GraphConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'graph'
        description = 'Convert network to signed, directed graph'
        inputs = struct()
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(network, varargin)
            import synnetgen.graph.Graph;
            
            %parse arguments
            validateattributes(network, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
            ip = inputParser;
            ip.parse(varargin{:});
            
            %convert to graph
            graph = Graph(network.nodes, network.getEdges());
        end
    end
end