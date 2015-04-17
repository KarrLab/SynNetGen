%Generate Erdos-Reyni random network with parameters n and m.
%- n: number of nodes
%- m: number of edges
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef ErdosReyniGenerator < synnetgen.extension.Extension
    properties (Constant)
        id = 'erdos-reyni'
        description = 'Erdos-Reyni random network generator (n, m)'
        inputs = struct(...
            'n', 'Number of nodes', ...
            'm', 'Number of edges')
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(graph, varargin)
            import synnetgen.graph.Graph;
            
            %parse arguments
            ip = inputParser;
            ip.addParameter('n', 100, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.addParameter('m',  10, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.parse(varargin{:});
            n = ip.Results.n;
            m = ip.Results.m;
            
            if m >= n^2
                throw(MException('SynNetGen:InvalidArgument', 'm must be less than or equal to n^2'))
            end
            
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
            iEdge = randsample(n * (n + 1) / 2, m, false);
            iTriu = find(triu(ones(n)));
            
            edges = zeros(n);
            edges(iTriu(iEdge)) = 1;
            edges = triu(edges) + triu(edges)' - diag(diag(edges));
            
            graph.setEdges(edges);
        end
    end
end