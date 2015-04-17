%Randomize edge directions
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef RandomizeDirectionsTransform < synnetgen.extension.Extension
    properties (Constant)
        id = 'RandomizeDirections'
        description = 'Randomize edge directions'
        inputs = struct(...
            'p', 'Probabilty to change direction' ...
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
            
            %randomize directions
            [iFrom, iTo, signs] = find(graph.edges);
            flip = rand(size(iFrom)) < p;
            iFrom2 = iFrom;
            iTo2 = iTo;
            iFrom2(flip) = iTo(flip);
            iTo2(flip) = iFrom(flip);
            
            edges = zeros(size(graph.edges));
            edges(sub2ind(size(graph.edges), iFrom2, iTo2)) = signs;
            
            graph.setEdges(edges);
        end
    end
end
