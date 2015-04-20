%Imports ODE model from SBML
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef SBMLImporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'sbml'
        description = 'SBML importer'
        inputs = struct(...
            'filename', 'File name' ...
            )
        outputs = struct (...
            'odes', 'ODE model'...
            )
    end
    
    methods (Static)
        function odes = run(odes, varargin)
            %% parse arguments
            validateattributes(odes, {'synnetgen.odes.Odes'}, {'scalar'});
            
            ip = inputParser;
            ip.addParameter('filename', []);
            ip.parse(varargin{:});
            filename = ip.Results.filename;
            
            if isempty(filename)
                throw(MException('SynNetGen:InvalidArgument', 'filename must be defined'));
            end
            
            %% import
            model = sbmlimport(filename);
            
            %validate
            %- 1 compartment
            %- no events, reactions, parameters
            %- rules are all of type rate
            validateattributes(model.Compartments, {'SimBiology.Compartment'}, {'scalar'});
            validateattributes(model.Events, {'double'}, {'size' [0 1]});
            validateattributes(model.Reactions, {'double'}, {'size' [0 1]});
            assert(all(arrayfun(@(rule) strcmp('rate', rule.RuleType), model.Rules)));
            
            %read species
            nodes = repmat(struct('id', '', 'label', ''), 0, 1);
            for iSpecies = 1:numel(model.Species)
                species = model.Species(iSpecies);
                nodes = [
                    nodes
                    struct('id', species.Name, 'label', species.Name)
                    ];
            end
            
            nodeIds = {nodes.id}';
            assert(numel(nodeIds) == numel(unique(nodeIds)));
            
            %read parameters
            parameters = repmat(struct('id', '', 'label', ''), 0, 1);
            for iParam = 1:numel(model.Parameters)
                parameter = model.Parameters(iParam);
                parameters = [
                    parameters
                    struct('id', parameter.Name, 'label', parameter.Name)
                    ];
            end
                        
            %read rules
            differentials = cell(size(nodes));
            for iRule = 1:numel(model.Rules)
                nodeDifferential = strsplit(model.Rules(iRule).Rule, '=');
                nodeId = util.trim(nodeDifferential{1});
                iNode = find(strcmp(nodeId, nodeIds), 1, 'first');
                differential = util.trim(nodeDifferential{2});
                differentials{iNode} = differential;
            end
            
            %set nodes and differentials
            odes.setNodesParametersAndDifferentials(nodes, parameters, differentials);
        end
    end
end