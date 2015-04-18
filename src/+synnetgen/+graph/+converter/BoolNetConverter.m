%Convert graph to Boolean network
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef BoolNetConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'boolnet'
        description = 'Convert graph to Boolean network'
        inputs = struct()
        outputs = struct (...
            'boolnet', 'Boolean network')
    end
    
    methods (Static)
        function boolnet = run(graph, varargin)
            import synnetgen.boolnet.BoolNet;
            
            %parse arguments
            validateattributes(graph, {'synnetgen.graph.Graph'}, {'scalar'});
            
            ip = inputParser;
            ip.parse(varargin{:});
            
            %convert to graph
            rules = repmat({''}, numel(graph.nodes), 1);
            nodeIds = {graph.nodes.id};
            for iNode = 1:numel(graph.nodes)
                negRegs = find(graph.edges(:, iNode) == -1);
                posRegs = find(graph.edges(:, iNode) ==  1);
                nanRegs = find(isnan(graph.edges(:, iNode)));
                
                %negative
                neg = strjoin(nodeIds(negRegs), ' || ');
                if ~isempty(negRegs) && ~isempty(nanRegs)
                    neg = [neg ' && '];
                end
                neg = [neg strjoin(nodeIds(nanRegs), ' && ')];
                
                if numel(negRegs) + numel(nanRegs) > 1
                    neg = ['(' neg ')'];
                end
                
                if numel(negRegs) + numel(nanRegs) >= 1
                    neg = ['~' neg];
                end
                
                %positive
                pos = strjoin(nodeIds(posRegs), ' || ');
                if ~isempty(posRegs) && ~isempty(nanRegs)
                    pos = [pos ' && '];
                end
                pos = [pos strjoin(nodeIds(nanRegs), ' && ')];
                
                if numel(posRegs) + numel(nanRegs) > 1
                    pos = ['(' pos ')'];
                end
                
                %total
                rules{iNode} = neg;
                if (numel(negRegs) + numel(nanRegs) >= 1) && (numel(posRegs) + numel(nanRegs) >= 1)
                    rules{iNode} = [rules{iNode} ' && '];
                end
                rules{iNode} = [rules{iNode} pos];
            end
            
            boolnet = BoolNet(graph.nodes, rules);
        end
    end
end