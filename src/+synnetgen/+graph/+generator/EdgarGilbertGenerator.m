%Generate Edgar-Gilbert random network with parameters n and p.
%- n: number of nodes
%- p: probability of edge between two nodes
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef EdgarGilbertGenerator < synnetgen.extension.Extension
    properties (Constant)
        id = 'edgar-gilbert'
        description = 'Edgar-Gilbert random network generator (n, p)'
        inputs = struct(...
            'n', 'Number of nodes', ...
            'p', 'Probability of each edge')
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(graph, varargin)
            import synnetgen.graph.Graph;
            
            %parse arguments
            ip = inputParser;
            ip.addParameter('n', 100, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.addParameter('p', 0.01, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
            ip.parse(varargin{:});
            n = ip.Results.n;
            p = ip.Results.p;
            
            graph.clear();
            
            %build nodes
            for iNode = 1:n
                label = dec2base(iNode-1, 26);
                for i = 25:-1:10
                    label(label == char(65 + i - 10)) = char(65 + i);
                end
                for i = 9:-1:0
                    label(label == num2str(i)) = char(65 + i);
                end
                label = [repmat('A', 1, numel(dec2base(n-1, 26)) - numel(label)) label];
                graph.addNode(label, label);
            end
            
            %build edges
            edges = rand(n) < p;
            edges = triu(edges) + triu(edges)' - diag(diag(edges));
            graph.setEdges(edges);
        end
    end
end