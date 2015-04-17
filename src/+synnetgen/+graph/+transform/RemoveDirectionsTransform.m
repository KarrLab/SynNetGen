%Remove edge directions
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef RemoveDirectionsTransform < synnetgen.extension.Extension
    properties (Constant)
        id = 'RemoveDirections'
        description = 'Remove edge directions'
        inputs = struct()
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(graph, varargin)
            graph.setEdges(triu(graph.edges) + triu(graph.edges)' - diag(diag(graph.edges)));
        end
    end
end