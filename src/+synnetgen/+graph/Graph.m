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
%  - generate: from one of several distributions
%  - import: from one of several file formats
%  - export: to one of several file formats
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef Graph < synnetgen.Model
    properties (SetAccess = protected)
        nodes %array of nodes. Each node is represented by a struct with two fields id and label
        edges %adjancency matrix representing directed edges and their signs. Rows represent parents. Columns represent children
    end
    
    methods
        function this = Graph(nodes, edges)
            %Construct signed, directed graph
            
            if nargin < 1
                nodes = repmat(struct('id', '', 'label', ''), 0, 1);
            end
            if nargin < 2
                edges = zeros(numel(nodes));
            end
            
            this.setNodesAndEdges(nodes, edges);
        end
    end
    
    methods
        function this = setNodesAndEdges(this, nodes, edges)
            %Set nodes and edges
            
            validateattributes(nodes, {'struct'}, {'column'})
            if ~isequal(sort(fieldnames(nodes)), sort({'id'; 'label'}))
                throw(MException('SynNetGen:InvalidArgument', 'Nodes must be struct with two fields id and label'));
            end
            if ~all(cellfun(@this.isValidNodeId, {nodes.id}))
                throw(MException('SynNetGen:InvalidArgument', 'Ids must be non-empty strings'));
            end
            if ~all(cellfun(@this.isValidNodeLabel, {nodes.label}))
                throw(MException('SynNetGen:InvalidArgument', 'Labels must be strings'));
            end
            
            validateattributes(edges, {'numeric'}, {'ndims', 2, 'square'});
            if ~all(all((edges >= -1 & edges <= 1 & edges == ceil(edges)) | isnan(edges)))
                throw(MException('SynNetGen:InvalidEdges', 'Edges must have sign -1, 0, 1, or NaN'))
            end
            
            if numel(nodes) ~= size(edges, 1)
                throw(MException('SynNetGen:InvalidNodesAndEdges', 'Nodes and edge sizes must be consistent'))
            end
            
            this.nodes = nodes;
            this.edges = edges;
        end
        
        function this = setNodes(this, nodes)
            %Set nodes
            
            validateattributes(nodes, {'struct'}, {'column'})
            if ~isequal(sort(fieldnames(nodes)), sort({'id'; 'label'}))
                throw(MException('SynNetGen:InvalidArgument', 'Nodes must be struct with two fields id and label'));
            end
            if ~all(cellfun(@this.isValidNodeId, {nodes.id}))
                throw(MException('SynNetGen:InvalidArgument', 'Ids must be non-empty strings'));
            end
            if ~all(cellfun(@this.isValidNodeLabel, {nodes.label}))
                throw(MException('SynNetGen:InvalidArgument', 'Labels must be strings'));
            end
            
            this.nodes = nodes;
        end
        
        function this = addNode(this, id, label)
            %Adds node with id and label to graph
            
            %% validate arguments
            
            %id is non-empty unique string
            validateattributes(id, {'char'}, {'nonempty', 'row'});
            if ~this.isValidNodeId(id) || any(strcmp({this.nodes.id}, id))
                throw(MException('SynNetGen:InvalidNodeId', 'Invalid node id ''%s''', id))
            end
            
            %label is string
            if ~this.isValidNodeLabel(label)
                throw(MException('SynNetGen:InvalidNodeLabel', 'Invalid node label ''%s''', label))
            end
            
            %% add node to network
            this.nodes = [
                this.nodes
                struct('id', id, 'label', label)
                ];
            this.edges = [
                this.edges zeros(numel(this.nodes)-1, 1)
                zeros(1, numel(this.nodes))
                ];
        end
        
        function this = removeNode(this, id)
            %Removes node with id from graph
            
            %% validate arguments
            %id is non-empty string
            validateattributes(id, {'char'}, {'nonempty', 'row'});
            
            %node with id exists
            isNode = strcmp({this.nodes.id}, id);
            if ~any(isNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with id ''%s'' does not exist', id))
            end
            
            %% remove node
            this.nodes = this.nodes(~isNode);
            this.edges = this.edges(~isNode, ~isNode);
        end
        
        function this = setEdges(this, edges)
            %Set Edges
            
            validateattributes(edges, {'numeric'}, ...
                {'size' [numel(this.nodes) numel(this.nodes)]});
            if ~all(all((edges >= -1 & edges <= 1 & edges == ceil(edges)) | isnan(edges)))
                throw(MException('SynNetGen:InvalidEdges', 'Edges must have sign -1, 0, 1, or NaN'))
            end
            
            this.edges = edges;
        end
        
        function this = addEdge(this, fromNodeId, toNodeId, sign)
            %Adds edge from node fromNodeId to node toNodeId with
            %specified sign {-1, 1}
            
            %% validate arguments
            %node with id fromNodeId exists
            validateattributes(fromNodeId, {'char'}, {'nonempty', 'row'});
            iFromNode = find(strcmp({this.nodes.id}, fromNodeId), 1, 'first');
            if isempty(iFromNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with id ''%s'' does not exist', fromNodeId))
            end
            
            %node with id toNodeId exists
            validateattributes(toNodeId, {'char'}, {'nonempty', 'row'});
            iToNode = find(strcmp({this.nodes.id}, toNodeId), 1, 'first');
            if isempty(iToNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with id ''%s'' does not exist', toNodeId))
            end
            
            %edge doesn't already exist
            if this.edges(iFromNode, iToNode) ~= 0
                throw(MException('SynNetGen:EdgeAlreadyExists', 'Edge already exists from ''%s'' to ''%s''', fromNodeId, toNodeId))
            end
            
            %edge has valid sign
            validateattributes(sign, {'numeric'}, {'scalar'});
            if ~((sign >= -1 && sign <= 1 && sign == ceil(sign)) || isnan(sign))
                throw(MException('SynNetGen:InvalidEdges', 'Edges must have sign -1, 0, 1, or NaN'))
            end
            
            %% add edge
            this.edges(iFromNode, iToNode) = sign;
        end
        
        function this = removeEdge(this, fromNodeId, toNodeId)
            %Removes edge from node fromNodeId to node toNodeId
            
            %% validate arguments
            
            %node with id fromNodeId exists
            validateattributes(fromNodeId, {'char'}, {'nonempty', 'row'});
            iFromNode = find(strcmp({this.nodes.id}, fromNodeId), 1, 'first');
            if isempty(iFromNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with id ''%s'' does not exist', fromNodeId))
            end
            
            %node with id toNodeId exists
            validateattributes(toNodeId, {'char'}, {'nonempty', 'row'});
            iToNode = find(strcmp({this.nodes.id}, toNodeId), 1, 'first');
            if isempty(iToNode)
                throw(MException('SynNetGen:NodeDoesNotExist', 'Node with id ''%s'' does not exist', toNodeId))
            end
            
            %edge doesn't exist
            if this.edges(iFromNode, iToNode) == 0
                throw(MException('SynNetGen:EdgeDoesNotExist', 'Edge does not exist from ''%s'' to ''%s''', fromNodeId, toNodeId))
            end
            
            %% remove edge
            this.edges(iFromNode, iToNode) = 0;
        end
    end
    
    methods
        function tf = isequal(this, that)
            %Test if graphs are equal
            
            %that is graph
            if ~isa(that, class(this))
                tf = false;
                return;
            end
            
            %same number nodes
            if ~isequal(numel(this.nodes), numel(that.nodes))
                tf = false;
                return;
            end
            
            %same node ids and labels
            [nodeIdLabelsThis, iRowsThis] = sortrows([{this.nodes.id}' {this.nodes.label}']);
            [nodeIdLabelsThat, iRowsThat] = sortrows([{that.nodes.id}' {that.nodes.label}']);
            if ~isequal(nodeIdLabelsThis, nodeIdLabelsThat)
                tf = false;
                return;
            end
            
            %same edges
            if ~all(all(this.edges(iRowsThis, iRowsThis) == that.edges(iRowsThat, iRowsThat) | (isnan(this.edges(iRowsThis, iRowsThis)) & isnan(that.edges(iRowsThat, iRowsThat)))))
                tf = false;
                return;
            end
            
            %if all tests pass, return true
            tf = true;
        end
    end
    
    methods
        function this = clear(this)
            %clear nodes and edges
            
            this.nodes = repmat(struct('id', [], 'label', []), 0, 1);
            this.edges = zeros(0);
        end
        
        function that = copy(this)
            %Create copy of graph
            
            that = synnetgen.graph.Graph(this.nodes, this.edges);
        end
    end
    
    methods
        function str = print(this)
            %Display graph in command window
            
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
                    sprintf('    %s: %s', this.nodes(iNode).id, this.nodes(iNode).label)
                    ];
            end
            
            str = [
                str
                sprintf('  Edges:')
                ];
            [iFrom, iTo] = find(this.edges);
            for iEdge = 1:numel(iFrom)
                switch this.edges(iFrom(iEdge), iTo(iEdge))
                    case 1
                        sign = '>';
                    case -1
                        sign = '|';
                    otherwise
                        sign = '-';
                end
                str = [
                    str
                    sprintf('    %s --%s %s', this.nodes(iFrom(iEdge)).id, sign, this.nodes(iTo(iEdge)).id)
                    ];
            end
        end
        
        function figHandle = plot(this, varargin)
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
            edgeLabels = [{this.nodes(iFrom).id}' {this.nodes(iTo).id}' cell(numel(iFrom), 1)];
            edgeColors = [{this.nodes(iFrom).id}' {this.nodes(iTo).id}' cell(numel(iFrom), 1)];
            edgeLabels(this.edges(find(this.edges)) ==  1, 3) = {'+'};
            edgeLabels(this.edges(find(this.edges)) == -1, 3) = {'-'};
            edgeLabels(isnan(this.edges(find(this.edges))), 3) = {'?'};
            edgeColors(this.edges(find(this.edges)) ==  1, 3) = {'k'};
            edgeColors(this.edges(find(this.edges)) == -1, 3) = {'r'};
            edgeColors(isnan(this.edges(find(this.edges))), 3) = {[0.5 0.5 0.5]};
            
            result = graphViz4Matlab(...
                '-nodeLabels', {this.nodes.id}', ...
                '-nodeDescriptions', {this.nodes.label}', ...
                '-adjMat', this.edges ~= 0, ...
                '-edgeLabels', edgeLabels, ...
                '-edgeColors', edgeColors, ...
                '-nodeColors', nodeColors, ...
                '-layout', layout());
            figHandle = result.fig;
        end
    end
    
    methods
        function this = generate(this, extId, varargin)
            %Generates random graph using various generators. See
            %synnetgen.graph.generator for supported algorithms and their
            %options.
            
            synnetgen.extension.ExtensionRunner.run('synnetgen.graph.generator', extId, this, varargin{:});
        end
        
        function result = transform(this, extId, varargin)
            %Transforms graph using various transform. See
            %synnetgen.graph.transform for supported algorithms and their
            %options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.graph.transform', extId, this, varargin{:});
        end
        
        function result = convert(this, extId, varargin)
            %Converts graph to other types of models using various
            %algorithms. See synnetgen.graph.transform for supported
            %algorithms and their options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.graph.converter', extId, this, varargin{:});
        end
        
        function result = export(this, extId, varargin)
            %Exports graph to various formats. See synnetgen.graph.exporter
            %for supported formats.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.graph.exporter', extId, this, varargin{:});
        end
        
        function this = import(this, extId, varargin)
            %Imports graphs from various formats. See synnetgen.graph.importer
            %for supported formats.
            
            synnetgen.extension.ExtensionRunner.run('synnetgen.graph.importer', extId, this, varargin{:});
        end
    end
end