%Randomize edge signs
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef RandomizeSignsTransform < synnetgen.extension.Extension
    properties (Constant)
        id = 'RandomizeSigns'
        description = 'Randomize edge signs'
        inputs = struct(...
            'p', 'Probabilty to change sign' ...
            )
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(graph, varargin)
            %parse arguments
            ip = inputParser;
            ip.addParameter('p', 0.5, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
            ip.parse(varargin{:});
            p = ip.Results.p;
            
            %randomize signs
            graph.setEdges((graph.edges ~= 0) .* (2 * (rand(size(graph.edges)) < p) - 1));
        end
    end
end