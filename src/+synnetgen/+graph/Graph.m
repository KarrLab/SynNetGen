%Represents directed graph
%- Methods
%  - setNodesAndEdges
%  - setNodes, addNode, removeNode
%  - setEdges, addEdge, removeEdge
%  - removeDirectionality, removeSigns
%  - copy
%  - isequal, eq
%  - disp, print, plot
%- Static methods
%  - sample: from one of several distributions
%  - import:
%  - export:
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef Graph < handle
    properties (SetAccess = protected)
        nodes %array of nodes. Each node is represented by a struct with two fields name and label
        edges %adjancency matrix representing directed edges and their signs. Rows represent parents. Columns represent children
    end
    
    methods
        function this = Graph(nodes, edges)
            if nargin < 1
                nodes = repmat(struct('name', '', 'label', ''), 0, 1);
            end
            if nargin < 2
                edges = zeros(numel(nodes));
            end
            
            this.setNodesAndEdges(nodes, edges);
        end
    end
    
    methods
        function this = setNodesAndEdges(this, nodes, edges)
            validateattributes(nodes, {'struct'}, {'column'})
            if ~isequal(sort(fieldnames(nodes)), sort({'name'; 'label'}))
                throw(MException('SynNetGen:InvalidArgument', 'Nodes must be struct with two fields name and label'));
            end
            if ~all(cellfun(@(x) ischar(x) && isrow(x) && ~isempty(x), {nodes.name}))
                throw(MException('SynNetGen:InvalidArgument', 'Names must be non-empty strings'));
            end
            if ~all(cellfun(@(x) ischar(x) && isrow(x), {nodes.label}))
                throw(MException('SynNetGen:InvalidArgument', 'Labels must be strings'));
            end
            
            validateattributes(edges, {'numeric'}, {'ndims', 2, 'square', 'integer'});
            if any(edges > 1 | edges < -1)
                throw(MException('SynNetGen:InvalidEdges', 'Edges must have sign -1, 0, or 1'))
            end
            
            if numel(nodes) ~= size(edges, 1)
                throw(MException('SynNetGen:InvalidNodesAndEdges', 'Nodes and edge sizes must be consistent'))
            end
            
            this.nodes = nodes;
            this.edges = edges;
        end
        
        function this = setNodes(this, nodes)
            validateattributes(nodes, {'struct'}, {'column'})
            if ~isequal(sort(fieldnames(nodes)), sort({'name'; 'label'}))
                throw(MException('SynNetGen:InvalidArgument', 'Nodes must be struct with two fields name and label'));
            end
            if ~all(cellfun(@(x) ischar(x) && isrow(x) && ~isempty(x), {nodes.name}))
                throw(MException('SynNetGen:InvalidArgument', 'Names must be non-empty strings'));
            end
            if ~all(cellfun(@(x) ischar(x) && isrow(x), {nodes.label}))
                throw(MException('SynNetGen:InvalidArgument', 'Labels must be strings'));
            end
            
            this.nodes = nodes;
        end
        
        function this = addNode(this, name, label)
            %Adds node with name and label to graph
            
            %% validate arguments
            
            %name is non-empty unique string
            validateattributes(name, {'char'}, {'nonempty', 'row'});
            if any(strcmp({this.nodes.name}, name))
                throw(MException('SynNetGen:InvalidNodeName', 'Invalid node name ''%s''', name))
            end
            
            %label is string
            validateattributes(label, {'char'}, {'row'});
            
            %% add node to network
            this.nodes = [
                this.nodes
                struct('name', name, 'label', label)
                ];
            this.edges = [
                this.edges zeros(numel(this.nodes)-1, 1)
                zeros(1, numel(this.nodes))
                ];
        end
        
        function this = removeNode(this, name)
            %Removes node with name from graph
            
            %% validate arguments
            %name is non-empty string
            validateattributes(name, {'char'}, {'nonempty', 'row'});
            
            %node with name exists
            isNode = strcmp({this.nodes.name}, name);
            if ~any(isNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with name ''%s'' does not exist', name))
            end
            
            %% remove node
            this.nodes = this.nodes(~isNode);
            this.edges = this.edges(~isNode, ~isNode);
        end
        
        function this = setEdges(this, edges)
            validateattributes(edges, {'numeric'}, ...
                {'size' [numel(this.nodes) numel(this.nodes)] 'integer'});
            if any(edges > 1 | edges < -1)
                throw(MException('SynNetGen:InvalidEdges', 'Edges must have sign -1, 0, or 1'))
            end
            
            this.edges = edges;
        end
        
        function this = addEdge(this, fromNodeName, toNodeName, sign)
            %Adds edge from node fromNodeName to node toNodeName with
            %specified sign {-1, 1}
            
            %% validate arguments
            %node with name fromNodeName exists
            validateattributes(fromNodeName, {'char'}, {'nonempty', 'row'});
            iFromNode = find(strcmp({this.nodes.name}, fromNodeName), 1, 'first');
            if isempty(iFromNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with name ''%s'' does not exist', fromNodeName))
            end
            
            %node with name toNodeName exists
            validateattributes(toNodeName, {'char'}, {'nonempty', 'row'});
            iToNode = find(strcmp({this.nodes.name}, toNodeName), 1, 'first');
            if isempty(iToNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with name ''%s'' does not exist', toNodeName))
            end
            
            %edge doesn't already exist
            if this.edges(iFromNode, iToNode)
                throw(MException('SynNetGen:EdgeAlreadyExists', 'Edge already exists from ''%s'' to ''%s''', fromNodeName, toNodeName))
            end
            
            %edge has valid sign
            validateattributes(sign, {'numeric'}, {'scalar', 'integer', 'odd', '<=', 1, '>=', -1});
            
            %% add edge
            this.edges(iFromNode, iToNode) = sign;
        end
        
        function this = removeEdge(this, fromNodeName, toNodeName)
            %Removes edge from node fromNodeName to node toNodeName
            
            %% validate arguments
            
            %node with name fromNodeName exists
            validateattributes(fromNodeName, {'char'}, {'nonempty', 'row'});
            iFromNode = find(strcmp({this.nodes.name}, fromNodeName), 1, 'first');
            if isempty(iFromNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with name ''%s'' does not exist', fromNodeName))
            end
            
            %node with name toNodeName exists
            validateattributes(toNodeName, {'char'}, {'nonempty', 'row'});
            iToNode = find(strcmp({this.nodes.name}, toNodeName), 1, 'first');
            if isempty(iToNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with name ''%s'' does not exist', toNodeName))
            end
            
            %edge already exists
            if ~this.edges(iFromNode, iToNode)
                throw(MException('SynNetGen:EdgeDoesNotExist', 'Edge does not exist from ''%s'' to ''%s''', fromNodeName, toNodeName))
            end
            
            %% remove edge
            this.edges(iFromNode, iToNode) = 0;
        end
    end
    
    methods
        function this = randomizeDirectionality(this, p)
            if nargin < 2
                p = 0.5;
            end
            
            [iFrom, iTo, signs] = find(this.edges);
            flip = rand(size(iFrom)) < p;
            iFrom2 = iFrom;
            iTo2 = iTo;
            iFrom2(flip) = iTo(flip);
            iTo2(flip) = iFrom(flip);
            
            edges = zeros(size(this.edges));
            edges(sub2ind(size(this.edges), iFrom2, iTo2)) = signs; 
            
            this.edges = edges;
        end
        
        function this = removeDirectionality(this)
            this.edges = triu(this.edges) + triu(this.edges)' - diag(diag(this.edges));
        end
        
        function this = randomizeSigns(this, p)
            if nargin < 2
                p = 0.5;
            end
            this.edges = (this.edges ~= 0) .* (2 * (rand(size(this.edges)) < p) - 1);
        end
        
        function this = removeSigns(this)
            this.edges = abs(this.edges);
        end
    end
    
    methods
        function tf = isequal(g, h)
            %Test if graphs are equal
            
            %h is graph
            if ~isa(h, class(g))
                tf = false;
                return;
            end
                
            %same number nodes
            if ~isequal(numel(g.nodes), numel(h.nodes))
                tf = false;
                return;
            end
            
            %same node names and labels
            [nodeNameLabelsG, iRowsG] = sortrows([{g.nodes.name}' {g.nodes.label}']);
            [nodeNameLabelsH, iRowsH] = sortrows([{h.nodes.name}' {h.nodes.label}']);
            if ~isequal(nodeNameLabelsG, nodeNameLabelsH)
                tf = false;
                return;
            end
            
            %same edges
            if ~isequal(g.edges(iRowsG, iRowsG), h.edges(iRowsH, iRowsH))
                tf = false;
                return;
            end
            
            %if all tests pass, return true
            tf = true;
        end
        
        function tf = eq(g, h)
           %Test if graphs are equal
            
           tf = isequal(g, h); 
        end
    end
    
    methods
        function h = copy(g)
            h = synnetgen.graph.Graph();
            h.setNodesAndEdges(g.nodes, g.edges);
        end
    end
    
    methods
        function this = disp(this)
            %Display graph in command window
            str = this.print();
            for iLine = 1:numel(str)
                fprintf('%s\n', str{iLine});
            end
        end
        
        function str = print(this)
            str = cell(0, 1);
            
            str = [str 
                sprintf('Signed, directed graph with %d nodes and %d edges', numel(this.nodes), nnz(this.edges))
                ];
            
            str = [
                str
                sprintf('  Nodes:')
                ];
            for iNode = 1:numel(this.nodes)
                str = [
                    str
                    sprintf('    %s: %s', this.nodes(iNode).name, this.nodes(iNode).label)
                    ];
            end
            
            str = [
                str
                sprintf('  Edges:')
                ];
            [iFrom, iTo] = find(this.edges);
            for iEdge = 1:numel(iFrom)
                if this.edges(iFrom(iEdge), iTo(iEdge))
                    sign = '>';
                else
                    sign = '|';
                end
                str = [
                    str
                    sprintf('    %s --%s %s', this.nodes(iFrom(iEdge)).name, sign, this.nodes(iTo(iEdge)).name)
                    ];
            end
        end
        
        function h = plot(this, varargin)
            %Generates plot of graph
            %  Options:
            %  - layout: see graphviz4matlab\layouts
            %  - nodeColors
            
            ip = inputParser();
            ip.addParameter('layout', 'Gvizlayout')
            ip.addParameter('nodeColors', [1, 1, 0.75])
            ip.parse(varargin{:});
            layout = str2func(ip.Results.layout);
            nodeColors = ip.Results.nodeColors;
            
            [iFrom, iTo] = find(this.edges);
            edgeLabels = [{this.nodes(iFrom).name}' {this.nodes(iTo).name}' cell(numel(iFrom), 1)];
            edgeColors = [{this.nodes(iFrom).name}' {this.nodes(iTo).name}' cell(numel(iFrom), 1)];
            edgeLabels(this.edges(find(this.edges)) ==  1, 3) = {'+'};
            edgeLabels(this.edges(find(this.edges)) == -1, 3) = {'-'};
            edgeColors(this.edges(find(this.edges)) ==  1, 3) = {'k'};
            edgeColors(this.edges(find(this.edges)) == -1, 3) = {'r'};
            
            h = graphViz4Matlab(...
                '-nodeLabels', {this.nodes.name}', ...
                '-nodeDescriptions', {this.nodes.label}', ...
                '-adjMat', this.edges, ...
                '-edgeLabels', edgeLabels, ...
                '-edgeColors', edgeColors, ...
                '-nodeColors', nodeColors, ...
                '-layout', layout());
        end
    end
    
    methods (Static = true)
        function result = generate(extName, varargin)
            %Generates random graph using various generators. See
            %synnetgen.graph.generator for supported algorithms and their
            %options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.graph.generator', extName, varargin{:});
        end
        
        function result = import(extName, varargin)
            %Imports graphs from various formats. See synnetgen.graph.importer
            %for supported formats.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.graph.importer', extName, varargin{:});
        end
        
        function result = export(extName, varargin)
            %Exports graph to various formats. See synnetgen.graph.exporter
            %for supported formats.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.graph.exporter', extName, varargin{:});
        end
    end
end