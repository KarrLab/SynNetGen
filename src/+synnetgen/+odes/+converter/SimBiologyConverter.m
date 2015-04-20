%Convert ODE model to SimBiology model
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef SimBiologyConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'SimBiology'
        description = 'Convert ODE model to SimBiology model'
        inputs = struct()
        outputs = struct (...
            'graph', 'Graph')
    end
    
    methods (Static)
        function sbio = run(odes, varargin)
            %parse arguments
            validateattributes(odes, {'synnetgen.odes.Odes'}, {'scalar'});
            
            ip = inputParser;
            ip.parse(varargin{:});
            
            %convert to graph
            sbio = sbiomodel('Odes');
            
            for iNode = 1:numel(odes.nodes)
                sbio.addspecies(odes.nodes(iNode).id);
            end
            
            for iParam = 1:numel(odes.parameters)
                sbio.addparameter(odes.parameters(iParam).id);
            end
            
            for iNode = 1:numel(odes.nodes)
                sbio.addrule('RuleType', 'rate', 'Rule', sprintf('%s = %s', odes.nodes(iNode).id, odes.differentials{iNode}));
            end
        end
    end
end