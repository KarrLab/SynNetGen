%Imports Boolean network from SBML using species and repeatedAssignment
%rules. Note: "~" must be replace with "-" because "~" is not supported by
%SimBiology.
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
            'boolnet', 'Boolean network'...
            )
    end
    
    methods (Static)
        function boolnet = run(boolnet, varargin)
            %% parse arguments
            validateattributes(boolnet, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
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
            validateattributes(model.Parameters, {'double'}, {'size' [0 1]});
            assert(all(arrayfun(@(rule) strcmp('repeatedAssignment', rule.RuleType), model.Rules)));
            
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
            
            %read rules
            rules = repmat({''}, size(nodes));
            for iRule = 1:numel(model.Rules)
                nodeRule = strsplit(model.Rules(iRule).Rule, '=');
                nodeId = util.trim(nodeRule{1});
                iNode = find(strcmp(nodeId, nodeIds), 1, 'first');
                rules{iNode} = synnetgen.boolnet.importer.SBMLImporter.decodeRule(nodeRule{2});
            end
            
            %set nodes and rules
            boolnet.setNodesAndRules(nodes, rules);
        end
        
        function rule = decodeRule(rule)
            rule = util.trim(rule);
            rule = strrep(rule, '-', '~');
            
            commaPos = strfind(rule, ',');
            
            andPos = strfind(rule, 'and(');
            tf = andPos == 1;
            tf(andPos > 1) = ismember(rule(andPos(andPos > 1)-1), '~,(');
            andPos = andPos(tf);
            
            orPos = strfind(rule, 'or(');
            tf = orPos == 1;
            tf(orPos > 1) = ismember(rule(orPos(orPos > 1)-1), '~,(');
            orPos = orPos(tf);
            
            isCommaAnd = false(size(commaPos));
            for i = 1:numel(commaPos)
                iAndPos = find(andPos < commaPos(i), 1, 'last');
                iOrPos  = find( orPos < commaPos(i), 1, 'last');
                if isempty(iAndPos)
                    isCommaAnd(i) = false;
                    orPos = orPos([1:iOrPos-1 iOrPos+1:end]);
                elseif isempty(iOrPos)
                    isCommaAnd(i) = true;
                    andPos = andPos([1:iAndPos-1 iAndPos+1:end]);
                elseif andPos(iAndPos) > orPos(iOrPos)
                    andPos = andPos([1:iAndPos-1 iAndPos+1:end]);
                    isCommaAnd(i) = true;
                else
                    orPos = orPos([1:iOrPos-1 iOrPos+1:end]);
                    isCommaAnd(i) = false;
                end
            end
            
            rule(commaPos( isCommaAnd)) = '&';
            rule(commaPos(~isCommaAnd)) = '|';
            while true
                nextRule = regexprep(rule, '(^|~|,|\||&|\()(and|or)\(', '$1(');
%                 nextRule = regexprep(nextRule, '(^|~|,| \()or\(', '$1(');
                if strcmp(nextRule, rule)
                    break;
                end
                rule = nextRule;
            end
            rule = strrep(rule, '|', ' || ');
            rule = strrep(rule, '&', ' && ');            
        end
    end
end