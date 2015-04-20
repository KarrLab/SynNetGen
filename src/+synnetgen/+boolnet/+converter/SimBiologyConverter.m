%Convert Boolean network to SimBiology model
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef SimBiologyConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'SimBiology'
        description = 'Convert network to SimBiology model'
        inputs = struct()
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function sbio = run(boolnet, varargin)
            %parse arguments
            validateattributes(boolnet, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
            ip = inputParser;
            ip.parse(varargin{:});
            
            %convert to graph
            sbio = sbiomodel('BoolNet');
            
            for iNode = 1:numel(boolnet.nodes)
                sbio.addspecies(boolnet.nodes(iNode).id);
                if ~isempty(boolnet.rules{iNode})
                    rule = boolnet.rules{iNode};
                    sbio.addrule('RuleType', 'repeatedAssignment', ...
                        'Rule', sprintf('%s = %s', boolnet.nodes(iNode).id, strrep(rule, '~', '-')));
                end
            end
        end
    end
end