%Represents boolean network
%- Methods
%  - addNode, setNodes, setNodesAndRules, setRule, setRules
%  - getTruthTables, getTruthTable, getEdges, getNodeEdges
%  - areRulesValid
%  - clear, copy
%  - simulate: using synchronous, asynchronous updating
%  - isequal, eq
%  - disp, print, plot
%- Static methods
%  - generate: from one of several distributions
%  - transform: using one of several methods
%  - convert: to other types of models
%  - import: from one of several file formats
%  - export: to one of several file formats
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef BoolNet < synnetgen.Model
    properties (SetAccess = protected)
        nodes
        rules
    end
    
    methods
        function this = BoolNet(nodes, rules)
            %Construct Boolean network
            
            if nargin < 1
                nodes = repmat(struct('id', '', 'label', ''), 0, 1);
            end
            if nargin < 2
                rules = repmat({''}, numel(nodes), 1);
            end
            
            this.setNodesAndRules(nodes, rules);
        end
    end
    
    methods
        function this = setNodesAndRules(this, nodes, rules)
            %Set nodes and rules
            
            validateattributes(nodes, {'struct'}, {'column'});
            if ~isequal(sort(fieldnames(nodes)), sort({'id'; 'label'}))
                throw(MException('SynNetGen:InvalidArgument', 'Nodes must be struct with two fields id and label'));
            end
            if ~all(cellfun(@this.isValidNodeId, {nodes.id}))
                throw(MException('SynNetGen:InvalidArgument', 'Names must be non-empty strings'));
            end
            if ~all(cellfun(@this.isValidNodeLabel, {nodes.label}))
                throw(MException('SynNetGen:InvalidArgument', 'Labels must be strings'));
            end
            
            if numel(nodes) ~= numel(rules) || ~this.areRulesValid(nodes, rules)
                throw(MException('SynNetGen:InvalidArgument', 'Invalid rules'));
            end
            
            this.nodes = nodes;
            this.rules = rules;
        end
        
        function this = addNode(this, id, label)
            %Adds node with id and label to network
            
            %% validate arguments
            
            %id is non-empty unique string
            if ~this.isValidNodeId(id) || any(strcmp({this.nodes.id}, id))
                throw(MException('SynNetGen:InvalidNodeName', 'Invalid node id ''%s''', id));
            end
            
            %label is string
            if ~this.isValidNodeLabel(label)
                throw(MException('SynNetGen:InvalidNodeLabel', 'Invalid node label ''%s''', label));
            end
            
            %% add node to network
            this.nodes = [
                this.nodes
                struct('id', id, 'label', label)
                ];
            this.rules = [
                this.rules
                {''}
                ];
        end
        
        function this = setRule(this, id, rule)
            %set rules
            
            %validate arguments
            if ~this.isValidNodeId(id) || ~any(strcmp(id, {this.nodes.id}))
                throw(MException('SynNetGen:InvalidArgument', 'No node with id'));
            end
            
            if ~this.areRulesValid(this.nodes, {rule})
                throw(MException('SynNetGen:InvalidArgument', 'Invalid rules'));
            end
            
            %set rules
            iNode = find(strcmp(id, {this.nodes.id}), 1, 'first');
            this.rules{iNode} = rule;
        end
        
        function this = setRules(this, rules)
            %set rules
            
            %validate arguments
            if numel(this.nodes) ~= numel(rules) || ~this.areRulesValid(this.nodes, rules)
                throw(MException('SynNetGen:InvalidArgument', 'Invalid rules'));
            end
            
            %set rules
            this.rules = rules;
        end
        
        function [truthTables, edges] = getTruthTables(this, varargin)
            %Calculates truth tables for rules in matrix [nNodes, 2^kmax]
            %and unsigned, directed graph
            
            %parse arguments
            ip = inputParser();
            ip.addParameter('simplify', false, @islogical)
            ip.parse(varargin{:});
            simplify = ip.Results.simplify;
            
            %calculate truth tables
            edges = zeros(numel(this.nodes));
            truthTables = zeros(numel(this.nodes), 0);
            for iNode = 1:numel(this.nodes)
                [truthTable, edges(:, iNode)] = this.getTruthTable(this.nodes(iNode).id, 'simplify', simplify);
                truthTables = [truthTables NaN(numel(this.nodes), size(truthTable, 2) - size(truthTables, 2))];
                truthTables(iNode, 1:numel(truthTable)) = truthTable;
            end
        end
        
        function [truthTable, edges] = getTruthTable(this, nodeId, varargin)
            %Calculates truth table for rule in vector [1 2^k]
            %and unsigned, directed graph
            
            %parse arguments
            iNode = find(strcmp(nodeId, {this.nodes.id}), 1, 'first');
            if isempty(nodeId)
                throw(MException('SynNetGen:InvalidArgument', 'No node with id ''%s''', nodeId));
            end
            
            ip = inputParser();
            ip.addParameter('simplify', false, @islogical)
            ip.addParameter('idFrom', unique(regexpi(this.rules{iNode}, '([a-z][a-z0-9_]*)', 'match')), @(x) iscell(x) && all(ismember(x, {this.nodes.id})))
            ip.parse(varargin{:});
            simplify = ip.Results.simplify;
            idFrom = ip.Results.idFrom;
            
            %exit if no regulators
            if isempty(idFrom)
                edges = zeros(numel(this.nodes), 1);
                truthTable = zeros(1, 0);
                return;
            end
            
            %calculate edges
            edges = ismember({this.nodes.id}', idFrom);
            
            %calculate truth tables
            truthTable = NaN(1, 2^max(sum(edges ~= 0)));
            rule = regexprep(this.rules{iNode}, '([a-z][a-z0-9_]*)', 'nodeValsStr.$1', 'ignorecase');
            
            nodeValsStr = struct();
            for i = 1:numel(this.nodes)
                nodeValsStr.(this.nodes(i).id) = true;
            end
            
            nodeValsArr = false(2^numel(idFrom), numel(idFrom));
            
            for j = 1:2^numel(idFrom)
                nodeValsArr(j, :) = dec2base(j - 1, 2, numel(idFrom)) == '1';
                for k = 1:numel(idFrom)
                    nodeValsStr.(idFrom{k}) = nodeValsArr(j, k);
                end
                truthTable(1, j) = eval(rule);
            end
            
            %determine if any inputs have no effective
            isEffectiveInput = false(size(idFrom));
            for j = 1:numel(idFrom)
                isEffectiveInput(j) = ~isequal(truthTable(1, nodeValsArr(:, j) == 1), truthTable(1, nodeValsArr(:, j) == 0));
            end
            
            %simplify
            if simplify && ~all(isEffectiveInput)
                [truthTable, edges] = this.getTruthTable(nodeId, 'simplify', simplify, 'idFrom', idFrom(isEffectiveInput));
            end
        end
        
        function edges = getEdges(this)
            %Calculates signed, directed graph
            
            edges = zeros(numel(this.nodes));
            for iNode = 1:numel(this.nodes)
                edges(:, iNode) = this.getNodeEdges(this.nodes(iNode).id);
            end
            
            [~, simplifiedEdges] = this.getTruthTables('simplify', true);
            edges(simplifiedEdges == 0) = 0;
        end
        
        function edges = getNodeEdges(this, nodeId)
            %Calculates signed, directed graph for one node
            
            %parse arguments
            iNode = find(strcmp(nodeId, {this.nodes.id}), 1, 'first');
            if isempty(nodeId)
                throw(MException('SynNetGen:InvalidArgument', 'No node with id ''%s''', nodeId));
            end
            
            %eliminate spaces
            rule = strrep(this.rules{iNode}, ' ', '');
            
            %calculate sense at each position
            sense = false(size(rule));
            depth = [];
            senseDepth = true;
            currDepth = 0;
            for i = 1:numel(rule)
                switch rule(i)
                    case '('
                        currDepth = currDepth + 1;
                        if i > 1 && rule(i - 1) == '~'
                            if numel(senseDepth) == currDepth
                                senseDepth = [senseDepth ~senseDepth(currDepth)];
                            else
                                senseDepth(currDepth+1) = ~senseDepth(currDepth);
                            end
                        else
                            if numel(senseDepth) == currDepth
                                senseDepth = [senseDepth senseDepth(currDepth)];
                            else
                                senseDepth(currDepth+1) = senseDepth(currDepth);
                            end
                        end
                    case ')'
                        currDepth = currDepth - 1;
                end
                
                if currDepth < 0
                    throw(MException())
                end
                depth = [depth currDepth];
                
                if i > 1 && rule(i-1) == '~'
                    sense(i) = ~senseDepth(currDepth+1);
                else
                    sense(i) = senseDepth(currDepth+1);
                end
            end
            sense = 2 * sense - 1;
            
            %calculate edge senses
            edges = zeros(numel(this.nodes), 1);
            [nodeIds, nodeStarts] = regexpi(rule, '([a-z]\w*)', 'match', 'start');
            [~, nodeIdxs] = ismember(nodeIds, {this.nodes.id});
            for i = 1:numel(nodeIdxs)
                switch edges(nodeIdxs(i))
                    case 0
                        edges(nodeIdxs(i)) = sense(nodeStarts(i));
                    case {-1, 1}
                        if edges(nodeIdxs(i)) ~= sense(nodeStarts(i))
                            edges(nodeIdxs(i)) = NaN;
                        end
                end
            end
        end
    end
    
    methods (Static)
        function result = areRulesValid(nodes, rules)
            %Check if rules are valid
            
            validateattributes(rules, {'cell'}, {'column'});
            if ~all(cellfun(@(rule) ischar(rule) && (isempty(rule) || isrow(rule)), rules))
                result = false;
                return;
            end
            
            nodeVals = struct();
            for iNode = 1:numel(nodes)
                nodeVals.(nodes(iNode).id) = true;
            end
            for iRule = 1:numel(rules)
                if isempty(rules{iRule})
                    continue;
                end
                    
                if isempty(regexpi(rules{iRule}, '^[(\|\|)(&&)a-z0-9_ \(\)~]*$'))
                    result = false;
                    return;
                end
                
                try
                    rule = regexprep(rules{iRule}, '([a-z]\w*)', 'nodeVals.$1', 'ignorecase');
                    [~] = eval(rule);
                catch
                    result = false;
                    return;
                end
            end
            
            result = true;
        end
    end
    
    methods
        function tf = isequal(this, that)
            %that is BoolNet
            if ~isa(that, class(this))
                tf = false;
                return;
            end
            
            %same number nodes
            if ~isequal(numel(this.nodes), numel(that.nodes))
                tf = false;
                return;
            end
            
            %same node names and labels
            [nodeNameLabelsThis, iRowsThis] = sortrows([{this.nodes.id}' {this.nodes.label}']);
            [nodeNameLabelsThat, iRowsThat] = sortrows([{that.nodes.id}' {that.nodes.label}']);
            if ~isequal(nodeNameLabelsThis, nodeNameLabelsThat)
                tf = false;
                return;
            end
            
            %same edges
            thisSorted = synnetgen.boolnet.BoolNet(this.nodes(iRowsThis), this.rules(iRowsThis));
            thatSorted = synnetgen.boolnet.BoolNet(that.nodes(iRowsThat), that.rules(iRowsThat));
            
            thisEdges = thisSorted.getEdges();
            thatEdges = thatSorted.getEdges();
            if ~all(all(thisEdges == thatEdges | (isnan(thisEdges) & isnan(thatEdges))))
                tf = false;
                return;
            end
            
            thisTruthTables = thisSorted.getTruthTables();
            thatTruthTables = thatSorted.getTruthTables();
            if ~all(all(thisTruthTables == thatTruthTables | (isnan(thisTruthTables) & isnan(thatTruthTables))))
                tf = false;
                return;
            end
            
            %if all tests pass, return true
            tf = true;
        end
    end
    
    methods
        function this = clear(this)
            %clear nodes and rules
            
            this.nodes = repmat(struct('id', [], 'label', []), 0, 1);
            this.rules = cell(0, 1);
        end
        
        function that = copy(this)
            %Create copy of network
            
            that = synnetgen.boolnet.BoolNet(this.nodes, this.rules);
        end
    end
    
    methods
        function str = print(this)
            %Display network in command window
            
            str = cell(0, 1);
            
            str = [str
                sprintf('Boolean network with %d nodes', numel(this.nodes))
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
                sprintf('  Rules:')
                ];
            for iNode = 1:numel(this.nodes)
                str = [
                    str
                    sprintf('    %s: %s', this.nodes(iNode).id, this.rules{iNode})
                    ];
            end
        end
        
        function figHandle = plot(this, varargin)
            %Generates plot of network
            %  Options:
            %  - layout: see graphviz4matlab\layouts
            %  - nodeColors
            
            graph = this.convert('graph');
            figHandle = graph.plot(varargin{:});
        end
    end
    
    methods
        function result = simulate(this, varargin)
            %Simulate model from 0 to tMax starting with state x0 according
            %to method with parameters p and q. See also RBN toolbox.
            
            ip = inputParser;
            ip.addParameter('x0', randi(1, size(this.nodes)), @(x) (isnumeric(x) || islogical(x)) && iscolumn(x) && numel(x) == numel(this.nodes));
            ip.addParameter('tMax', 1, @(x) isnumeric(x) && x == ceil(x) && x >= 0);
            ip.addParameter('method', 'crbn', @(x) ischar(x) && ismember(x, {'crbn', 'arbn', 'darbn', 'garbn', 'dgarbn'}));
            ip.addParameter('p', ones(size(this.nodes)), @(x) isnumeric(x) && iscolumn(x) && numel(x) == numel(this.nodes));
            ip.addParameter('q', zeros(size(this.nodes)), @(x) isnumeric(x) && iscolumn(x) && numel(x) == numel(this.nodes));
            ip.parse(varargin{:});
            x0 = ip.Results.x0;
            tMax = ip.Results.tMax;
            method = ip.Results.method;
            p = ip.Results.p;
            q = ip.Results.q;
            
            nodes = [];
            [truthTables, edges] = this.getTruthTables();
            for iNode = 1:numel(this.nodes)
                input = reshape(find(edges(:, iNode)), 1, []);
                output = reshape(find(edges(iNode, :)), 1, []);
                if numel(input) == 0
                    rule = zeros(0, 1);
                else
                    rule = truthTables(iNode, 1:2^numel(input))';
                end
                node = struct(...
                    'state', x0(iNode), ...
                    'nextState', 0, ...
                    'nbUpdates', 0, ...
                    'input', input, ...
                    'output', output, ...
                    'p', p(iNode), ...
                    'q', q(iNode), ...
                    'lineNumber', 0, ...
                    'rule', rule ...
                    );
                nodes = [nodes; node];
            end
           
            switch lower(method)
                case 'crbn'
                    [~, result] = evolveCRBN(nodes, tMax, 0);
                case 'arbn'
                    [~, result] = evolveARBN(nodes, tMax, 0);
                case 'darbn'
                    [~, result] = evolveDARBN(nodes, tMax, 0);
                case 'garbn'
                    [~, result] = evolveGARBN(nodes, tMax, 0);
                case 'dgarbn'
                    [~, result] = evolveDGARBN(nodes, tMax, 0);
            end
        end
    end    
    
    methods
        function result = generate(this, extId, varargin)
            %Generates random network using various generators. See
            %synnetgen.boolnet.generator for supported algorithms and their
            %options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.boolnet.generator', extId, this, varargin{:});
        end
        
        function result = transform(this, extId, varargin)
            %Transforms network using various transform. See
            %synnetgen.boolnet.transform for supported algorithms and their
            %options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.boolnet.transform', extId, this, varargin{:});
        end
        
        function result = convert(this, extId, varargin)
            %Converts network to other types of models using various
            %algorithms. See synnetgen.boolnet.transform for supported
            %algorithms and their options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.boolnet.converter', extId, this, varargin{:});
        end
        
        function result = import(this, extId, varargin)
            %Imports networks from various formats. See synnetgen.boolnet.importer
            %for supported formats.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.boolnet.importer', extId, this, varargin{:});
        end
        
        function result = export(this, extId, varargin)
            %Exports network to various formats. See synnetgen.boolnet.exporter
            %for supported formats.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.boolnet.exporter', extId, this, varargin{:});
        end
    end
end