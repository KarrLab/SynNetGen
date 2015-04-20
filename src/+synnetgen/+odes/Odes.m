%Represents ordinary differential equation (ODE) model
%- Methods
%  - copy
%  - isequal, eq
%  - disp, print, plot
%  - generate: from one of several distributions
%  - transform: using one of several methods
%  - convert: to other types of models
%  - import: from one of several file formats
%  - export: to one of several file formats
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef Odes < synnetgen.Model
    properties (SetAccess = protected)
        nodes
        differentials
        parameters
    end
    
    methods
        function this = Odes(nodes, parameters, differentials)
            %Construct ODE model
            
            if nargin < 1
                nodes = repmat(struct('id', '', 'label', ''), 0, 1);
            end
            if nargin < 2
                parameters = repmat(struct('id', '', 'label', ''), 0, 1);
            end
            if nargin < 3
                differentials = repmat({''}, numel(nodes), 1);
            end
            
            this.setNodesParametersAndDifferentials(nodes, parameters, differentials);
        end
    end
    
    methods
        function this = setNodesParametersAndDifferentials(this, nodes, parameters, differentials)
            %Set nodes and differentials
            
            validateattributes(nodes, {'struct'}, {'column'});
            if ~isequal(sort(fieldnames(nodes)), sort({'id'; 'label'}))
                throw(MException('SynNetGen:InvalidArgument', 'Nodes must be struct with two fields id and label'));
            end
            if ~all(cellfun(@this.isValidNodeId, {nodes.id}))
                throw(MException('SynNetGen:InvalidArgument', 'IDs must be non-empty strings'));
            end
            if ~all(cellfun(@this.isValidNodeLabel, {nodes.label}))
                throw(MException('SynNetGen:InvalidArgument', 'Labels must be strings'));
            end
            
            validateattributes(parameters, {'struct'}, {'column'});
            if ~isequal(sort(fieldnames(parameters)), sort({'id'; 'label'}))
                throw(MException('SynNetGen:InvalidArgument', 'Parameters must be struct with two fields id and label'));
            end
            if ~all(cellfun(@this.isValidNodeId, {parameters.id}))
                throw(MException('SynNetGen:InvalidArgument', 'IDs must be non-empty strings'));
            end
            if ~all(cellfun(@this.isValidNodeLabel, {parameters.label}))
                throw(MException('SynNetGen:InvalidArgument', 'Labels must be strings'));
            end
            
            if numel(nodes) ~= numel(differentials) || ~this.areDifferentialsValid(nodes, parameters, differentials)
                throw(MException('SynNetGen:InvalidArgument', 'Invalid differentials'));
            end
            
            this.nodes = nodes;
            this.parameters = parameters;
            this.differentials = differentials;
        end
        
        function this = addNode(this, id, label)
            %Adds node with id and label to ODE model
            
            %% validate arguments
            
            %id is non-empty unique string
            if ~this.isValidNodeId(id) || any(strcmp([{this.nodes.id} {this.parameters.id}], id))
                throw(MException('SynNetGen:InvalidNodeID', 'Invalid node id ''%s''', id));
            end
            
            %label is string
            if ~this.isValidNodeLabel(label)
                throw(MException('SynNetGen:InvalidNodeLabel', 'Invalid node label ''%s''', label));
            end
            
            %% add node to ODE model
            this.nodes = [
                this.nodes
                struct('id', id, 'label', label)
                ];
            this.differentials = [
                this.differentials
                {''}
                ];
        end
        
        function this = addParameter(this, id, label)
            %Adds parameter with id and label to ODE model
            
            %% validate arguments
            
            %id is non-empty unique string
            if ~this.isValidNodeId(id) || any(strcmp([{this.nodes.id} {this.parameters.id}], id))
                throw(MException('SynNetGen:InvalidParameterID', 'Invalid parameter id ''%s''', id));
            end
            
            %label is string
            if ~this.isValidNodeLabel(label)
                throw(MException('SynNetGen:InvalidParameterLabel', 'Invalid parameter label ''%s''', label));
            end
            
            %% add parameter to ODE model
            this.parameters = [
                this.parameters
                struct('id', id, 'label', label)
                ];
        end
        
        function this = setDifferential(this, id, differential)
            %set differentials
            
            %validate arguments
            if ~this.isValidNodeId(id) || ~any(strcmp(id, {this.nodes.id}))
                throw(MException('SynNetGen:InvalidArgument', 'No node with id'));
            end
            
            if ~this.areDifferentialsValid(this.nodes, this.parameters, {differential})
                throw(MException('SynNetGen:InvalidArgument', 'Invalid differentials'));
            end
            
            %set differentials
            iNode = find(strcmp(id, {this.nodes.id}), 1, 'first');
            this.differentials{iNode} = differential;
        end
        
        function this = setDifferentials(this, differentials)
            %set differentials
            
            %validate arguments
            if numel(this.nodes) ~= numel(differentials) || ~this.areDifferentialsValid(this.nodes, this.parameters, differentials)
                throw(MException('SynNetGen:InvalidArgument', 'Invalid differentials'));
            end
            
            %set differentials
            this.differentials = differentials;
        end
        
        function edges = getEdges(this, varargin)
            %Calculates signed, directed graph at node values y and
            %parameter values k
            
            ip = inputParser;
            ip.addParameter('y', []);
            ip.addParameter('k', []);
            ip.parse(varargin{:});
            y = ip.Results.y;
            k = ip.Results.k;
            
            if isempty(y)
                y = ones(size(this.parameters));
            end
            if isempty(k)
                k = ones(size(this.nodes));
            end
            
            validateattributes(y, {'numeric'}, {'column', 'nrows', numel(this.nodes)});
            validateattributes(k, {'numeric'}, {'column', 'nrows', numel(this.parameters)});
            
            edges = zeros(numel(this.nodes));
            for iNode = 1:numel(this.nodes)
                edges(:, iNode) = this.getNodeEdges(this.nodes(iNode).id, 'y', y, 'k', k);
            end
        end
        
        function edges = getNodeEdges(this, nodeId, varargin)
            %Calculates signed, directed graph for one node
            
            %parse arguments
            iNode = find(strcmp(nodeId, {this.nodes.id}), 1, 'first');
            if isempty(nodeId)
                throw(MException('SynNetGen:InvalidArgument', 'No node with id ''%s''', nodeId));
            end
            
            ip = inputParser;
            ip.addParameter('y', ones(size(this.nodes)), @(x) isnumeric(x) && iscolumn(x) && numel(x) == numel(this.nodes));
            ip.addParameter('k', ones(size(this.parameters)), @(x) isnumeric(x) && iscolumn(x) && numel(x) == numel(this.parameters));
            ip.parse(varargin{:});
            y = ip.Results.y;
            k = ip.Results.k;
            
            %eliminate spaces
            differential = sym(this.differentials{iNode});
            
            %differentiate differential with respect to each node and
            %evaluate at y, k
            nameIds = [{this.nodes.id} {this.parameters.id}];
            namedVals = [y' k'];
            diffVals = zeros(numel(this.nodes), 1);
            for iNode = 1:numel(this.nodes)
                diffVals(iNode) = feval(matlabFunction(subs(diff(differential, this.nodes(iNode).id), nameIds, namedVals)));
            end
            edges = zeros(numel(this.nodes), 1);
            edges(diffVals > 0) =  1;
            edges(diffVals < 0) = -1;
        end
    end
    
    methods (Static)
        function result = areDifferentialsValid(nodes, parameters, differentials)
            %Check if differentials are valid
            
            validateattributes(nodes, {'struct'}, {'column'});
            assert(ismember('id', fieldnames(nodes)))
            
            validateattributes(parameters, {'struct'}, {'column'});
            assert(ismember('id', fieldnames(parameters)))
            
            validateattributes(differentials, {'cell'}, {'column'});
            if ~all(cellfun(@(differential) ischar(differential) && (isempty(differential) || isrow(differential)), differentials))
                result = false;
                return;
            end
            
            namedVals = struct();
            for iNode = 1:numel(nodes)
                namedVals.(nodes(iNode).id) = 2;
            end
            for iParam = 1:numel(parameters)
                namedVals.(parameters(iParam).id) = 2;
            end
            for iDifferential = 1:numel(differentials)
                if isempty(differentials{iDifferential})
                    continue;
                end
                    
                if isempty(regexpi(differentials{iDifferential}, '^[\+\-*/\\\^a-z0-9_\.\(\) ]*$'))
                    result = false;
                    return;
                end
                
                try
                    differential = regexprep(differentials{iDifferential}, '([a-z]\w*)', 'namedVals.$1', 'ignorecase');
                    [~] = eval(differential);
                    sym(differentials{iDifferential});
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
            
            %same node ids and labels
            [nodeIdLabelsThis, iRowsThis] = sortrows([{this.nodes.id}' {this.nodes.label}']);
            [nodeIdLabelsThat, iRowsThat] = sortrows([{that.nodes.id}' {that.nodes.label}']);
            if ~isequal(nodeIdLabelsThis, nodeIdLabelsThat)
                tf = false;
                return;
            end
            
            %same parameter ids and labels
            paramIdLabelsThis = sortrows([{this.parameters.id}' {this.parameters.label}']);
            paramIdLabelsThat = sortrows([{that.parameters.id}' {that.parameters.label}']);
            if ~isequal(paramIdLabelsThis, paramIdLabelsThat)
                tf = false;
                return;
            end
            
            %same differentials
            thisDiffs = this.differentials(iRowsThis);
            thatDiffs = that.differentials(iRowsThat);
            for iNode = 1:numel(this.nodes)
                if ~isequal(sym(thisDiffs{iNode}), sym(thatDiffs{iNode}))
                    tf = false;
                    return;
                end
            end
            
            %if all tests pass, return true
            tf = true;
        end
    end
    
    methods
        function this = clear(this)
            %clear nodes and differentials
            
            this.nodes = repmat(struct('id', [], 'label', []), 0, 1);
            this.parameters = repmat(struct('id', [], 'label', []), 0, 1);
            this.differentials = cell(0, 1);
        end
        
        function that = copy(this)
            %Create copy of ODE model
            
            that = synnetgen.odes.Odes(this.nodes, this.parameters, this.differentials);
        end
    end
    
    methods
        function str = print(this)
            %Display ODE model in command window
            
            str = cell(0, 1);
            
            str = [str
                sprintf('ODE model with %d nodes', numel(this.nodes))
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
                sprintf('  Parameters:')
                ];
            for iNode = 1:numel(this.parameters)
                str = [
                    str
                    sprintf('    %s: %s', this.parameters(iNode).id, this.parameters(iNode).label)
                    ];
            end
            
            str = [
                str
                sprintf('  Differentials:')
                ];
            for iNode = 1:numel(this.nodes)
                str = [
                    str
                    sprintf('    d(%s)/dt = %s', this.nodes(iNode).id, this.differentials{iNode})
                    ];
            end
        end
        
        function figHandle = plot(this, varargin)
            %Generates plot of ODE model
            %  Options:
            %  - y: node values
            %  - k: parameter values
            %  - layout: see graphviz4matlab\layouts
            %  - nodeColors
            
            opts = struct(varargin{:});
            if isfield(opts, 'y')
                y = opts.y;
                opts = rmfield(opts, 'y');
            end
            if isfield(opts, 'k')
                k = opts.k;
                opts = rmfield(opts, 'k');
            end
            
            graph = this.convert('graph', 'y', y, 'k', k);
            
            optNames = fieldnames(opts);
            varargin = cell(1, 2 * numel(optNames));
            for i = 1:numel(optNames)
                varargin{2*i-1} = optNames{i};
                varargin{2*i} = opts.(optNames{i});
            end
            figHandle = graph.plot(varargin{:});
        end
    end
    
    methods
        function result = simulate(this, varargin)
            %Simulate model from 0 to tMax starting with state y0 and
            %parameters k using solver solver.
            
            ip = inputParser;
            ip.addParameter('y0', ones(size(this.nodes)), @(x) isnumeric(x) && iscolumn(x) && numel(x) == numel(this.nodes));
            ip.addParameter('k', ones(size(this.parameters)), @(x) isnumeric(x) && iscolumn(x) && numel(x) == numel(this.parameters));
            ip.addParameter('tMax', 5, @(x) isnumeric(x) && x >= 0);
            ip.addParameter('tStep', 1, @(x) isnumeric(x) && x > 0);
            ip.addParameter('solver', 'ode45', @(x) ischar(x) && ismember(x, {'ode113', 'ode23', 'ode45', 'ode15s', 'ode23s', 'ode23t', 'ode23tb'}));
            ip.addParameter('solverOptions', odeset(), @isstruct);
            ip.parse(varargin{:});
            y0 = ip.Results.y0;
            k = ip.Results.k;
            tMax = ip.Results.tMax;
            tStep = ip.Results.tStep;
            solver = ip.Results.solver;
            solverOptions = ip.Results.solverOptions;
            
            diffFileName = [tempname('tmp') '.m'];
            [~, diffFuncName] = fileparts(diffFileName);
            
            this.export('matlab', 'filename', diffFileName);
            diffFunc = str2func(diffFuncName);
            rehash();
            
            solverFunc = str2func(solver);
            
            [~, result] = feval(solverFunc, diffFunc, 0:tStep:tMax, y0, solverOptions, k);
            result = result';
        end
    end
    
    methods
        function result = generate(this, extId, varargin)
            %Generates random ODE model using various generators. See
            %synnetgen.odes.generator for supported algorithms and their
            %options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.odes.generator', extId, this, varargin{:});
        end
        
        function result = transform(this, extId, varargin)
            %Transforms ODE model using various transform. See
            %synnetgen.odes.transform for supported algorithms and their
            %options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.odes.transform', extId, this, varargin{:});
        end
        
        function result = convert(this, extId, varargin)
            %Converts ODE model to other types of models using various
            %algorithms. See synnetgen.odes.transform for supported
            %algorithms and their options.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.odes.converter', extId, this, varargin{:});
        end
        
        function result = import(this, extId, varargin)
            %Imports ODE model from various formats. See
            %synnetgen.odes.importer for supported formats.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.odes.importer', extId, this, varargin{:});
        end
        
        function result = export(this, extId, varargin)
            %Exports ODE model to various formats. See
            %synnetgen.odes.exporter for supported formats.
            
            result = synnetgen.extension.ExtensionRunner.run('synnetgen.odes.exporter', extId, this, varargin{:});
        end
    end
end