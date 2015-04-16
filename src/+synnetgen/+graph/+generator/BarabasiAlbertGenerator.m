%Generate Edgar-Gilbert random network with parameters n and m.
%- n: number of nodes
%- m: number edges added at each step
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef BarabasiAlbertGenerator < synnetgen.extension.Extension
    properties (Constant)
        id = 'barabasi-albert'
        description = 'Barabasi-Albert random network generator (n, m)'
        inputs = struct(...
            'n', 'Number of nodes', ...
            'm', 'Number edges added at each step')
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(varargin)
            import synnetgen.graph.Graph;
            
            %parse arguments
            ip = inputParser;
            ip.addParameter('n', 10, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.addParameter('m', 3, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.parse(varargin{:});
            n = ip.Results.n;
            m = ip.Results.m;
            
            if m >= n
                throw(MException('SynNetGen:InvalidArgument', 'm must be less than n'));
            end
            
            %build nodes
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
            
            %build edges
            edges = zeros(n);
            for iNode = m+1:n
                subEdges = edges(1:iNode - 1, 1:iNode - 1);
                pEdge = sum(subEdges, 1)';
                if sum(pEdge) == 0
                    pEdge(:) = 1;
                end
                
                iEdge = util.randsample_noreplace(iNode - 1, m, pEdge);
                edges(iNode, iEdge) = 1;
                edges(iEdge, iNode) = 1;
            end
            
            graph.setEdges(edges);
        end
    end
end