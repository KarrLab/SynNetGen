%Generate Watts-Strogatz random network with parameters n and n.
%- n: number of nodes
%- p: probability of edge between two nodes
%- k: probability of edge between two nodes
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef WattsStrogatzGenerator < synnetgen.extension.Extension
    properties (Constant)
        id = 'watts-strogatz'
        description = 'Watts-Strogatz random network generator (n, m)'
        inputs = struct(...
            'n', 'Number of nodes', ...
            'p', 'Rewiring probability', ...
            'k', 'Size of initial 2k-regular graph' ...
            )
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(varargin)
            import synnetgen.graph.Graph;
            
            %% parse arguments
            ip = inputParser;
            ip.addParameter('n', 100, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.addParameter('p', 0.1, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
            ip.addParameter('k', 2, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.parse(varargin{:});
            n = ip.Results.n;
            p = ip.Results.p;
            k = ip.Results.k;
            
            if 2 * k >= n
                throw(MException('SynNetGen:InvalidArgument', 'm must be less than n'));
            end
            if 2 * k == n-1 && p > 0
                throw(MException('SynNetGen:InvalidArgument', 'k must be less than (n-1)/2 if p > 0'));
            end
            
            %% build nodes
            graph = Graph();
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
            
            %% build edges
            %initial regular graph
            iFrom = repmat((1:n)', 1, 2 * k);
            iTo = iFrom + repmat([-k:-1 1:k], n, 1);
            
            iFrom = mod(iFrom - 1, n) + 1;
            iTo = mod(iTo - 1, n) + 1;
            
            tf = iTo > iFrom;
            iFrom = iFrom(tf);
            iTo = iTo(tf);
            
            edges = zeros(n);
            edges(sub2ind([n n], iFrom, iTo)) = 1;
            
            %rewire
            [iPossibleFrom, iPossibleTo] = find(triu(ones(n)) - diag(ones(n, 1)));
            
            rewire = find(rand(k * n, 1) < p);
            for i = 1:numel(rewire)
                while true
                    j = ceil(rand() * numel(iPossibleFrom));
                    iFrom2 = iPossibleFrom(j);
                    iTo2 = iPossibleTo(j);
                    if edges(iFrom2, iTo2) == 0
                        break;
                    end
                end
                
                edges(iFrom2, iTo2) = 1;
                edges(iFrom(rewire(i)), iTo(rewire(i))) = 0;
            end
            
            edges = triu(edges) + triu(edges)' - diag(diag(edges));
            
            %set edges
            graph.setEdges(edges);
        end
    end
end