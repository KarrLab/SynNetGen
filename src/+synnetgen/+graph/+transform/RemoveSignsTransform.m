%Remove signs from edges
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef RemoveSignsTransform < synnetgen.extension.Extension
    properties (Constant)
        id = 'RemoveSigns'
        description = 'Remove signs from edges'
        inputs = struct()
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(graph, varargin)
            graph.setEdges(abs(graph.edges));
        end
    end
end