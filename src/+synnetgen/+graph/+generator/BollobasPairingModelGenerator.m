%Generate Bollobas pair model random network with parameters n, k.
%- n: number of nodes
%- k: number of incident edges per node
%
%References
%1. Bollobas B. A probabilistic proof of an asymptotic formula for the
%   number of labelled regular graphs. European J Combin 1980, 4:311-316.
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef BollobasPairingModelGenerator < synnetgen.extension.Extension
    properties (Constant)
        id = 'bollobas-pairing-model'
        description = 'Bollobas pairing model random network generator (n, k)'
        inputs = struct(...
            'n', 'Number of nodes', ...
            'k', 'Number of incident edges per node' ...
            )
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function graph = run(graph, varargin)
            %% parse arguments
            validateattributes(graph, {'synnetgen.graph.Graph'}, {'scalar'});
            
            ip = inputParser;
            ip.addParameter('n', 10, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.addParameter('k', 2, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x == ceil(x));
            ip.parse(varargin{:});
            n = ip.Results.n;
            k = ip.Results.k;
            
            if mod(n * k, 2) ~= 0
                throw(MException('SynNetGen:InvalidArgument', 'n * k must be even'));
            end
            
            graph.clear();
            
            %% build nodes
            nodes = repmat(struct('id', '', 'label', ''), n, 1);
            for iNode = 1:n
                label = dec2base(iNode-1, 26);
                for i = 25:-1:10
                    label(label == char(65 + i - 10)) = char(65 + i);
                end
                for i = 9:-1:0
                    label(label == num2str(i)) = char(65 + i);
                end
                label = [repmat('A', 1, numel(dec2base(n-1, 26)) - numel(label)) label];
                nodes(iNode).id = label;
                nodes(iNode).label = label;
            end
            
            %% build edges
            edges = full(synnetgen.graph.generator.BollobasPairingModelGenerator.createRandRegGraph(n, k));
            
            %% set edges
            graph.setNodesAndEdges(nodes, edges);
        end
        
        %Source: http://www.mathworks.com/matlabcentral/fileexchange/29786-random-regular-generator/content/randRegGraph/createRandRegGraph.m
        function A = createRandRegGraph(vertNum, deg)
            % createRegularGraph - creates a simple d-regular undirected graph
            % simple = without loops or double edges
            % d-reglar = each vertex is adjecent to d edges
            %
            % input arguments :
            %   vertNum - number of vertices
            %   deg - the degree of each vertex
            %
            % output arguments :
            %   A - A sparse matrix representation of the graph
            %
            % algorithm :
            % "The pairing model" : create n*d 'half edges'.
            % repeat as long as possible: pick a pair of half edges
            %   and if it's legal (doesn't creat a loop nor a double edge)
            %   add it to the graph
            % reference: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.67.7957&rep=rep1&type=pdf
            
            n = vertNum;
            d = deg;
            matIter = 10;
            
            %check parameters
            if mod(n * d, 2) == 1
                disp('createRandRegGraph input err: n*d must be even!');
                A = [];
                return;
            end
            
            %a list of open half-edges
            U = repmat(1:n, 1, d);
            
            %the graphs adajency matrix
            A = sparse(n, n);
            
            edgesTested = 0;
            repetition = 1;
            
            %continue until a proper graph is formed
            while ~isempty(U) && repetition < matIter
                
                edgesTested = edgesTested + 1;
                
                %print progress
                if mod(edgesTested, 5000) == 0
                    fprintf('createRandRegGraph() progress: edges=%d/%d\n', edgesTested, n * d);
                end
                
                %chose at random 2 half edges
                i1 = ceil(rand() * length(U));
                i2 = ceil(rand() * length(U));
                v1 = U(i1);
                v2 = U(i2);
                
                %check that there are no loops nor parallel edges
                if v1 == v2 || A(v1, v2) == 1
                    
                    %restart process if needed
                    if edgesTested == n * d
                        repetition = repetition + 1;
                        edgesTested = 0;
                        U = repmat(1:n, 1, d);
                        A = sparse(n, n);
                    end
                else
                    %add edge to graph
                    A(v1, v2) = 1;
                    A(v2, v1) = 1;
                    
                    %remove used half-edges
                    v = sort([i1, i2]);
                    U = [U(1:v(1)-1), U(v(1)+1:v(2)-1), U(v(2)+1:end)];
                end
            end
            
            %check that A is indeed simple regular graph
            msg = synnetgen.graph.generator.BollobasPairingModelGenerator.isRegularGraph(A);
            if ~isempty(msg)
                disp(msg);
            end
        end
        
        %Source: http://www.mathworks.com/matlabcentral/fileexchange/29786-random-regular-generator/content/randRegGraph/createRandRegGraph.m
        function msg = isRegularGraph(G)
            %is G a simple d-regular graph the function returns []
            %otherwise it returns a message describing the problem in G
            
            msg = [];
            
            %check symmetry
            if norm(G - G', 'fro') > 0
                msg = [msg, ' is not symmetric, '];
            end
            
            %check parallel edged
            if max(G(:)) > 1
                msg = [msg, sprintf(' has %d parallel edges, ', length(find(G(:) > 1)))];
            end
            
            %check that d is d-regular
            d_vec = sum(G);
            if min(d_vec) < d_vec(1) || max(d_vec) > d_vec(1)
                msg = [msg, ' not d-regular, '];
            end
            
            %check that g doesn't contain any loops
            if norm(diag(G)) > 0
                msg = [msg, sprintf(' has %d self loops, ', length(find(diag(G) > 0)))];
            end
        end
    end
end