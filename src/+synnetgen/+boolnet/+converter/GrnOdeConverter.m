%Convert Boolean gene regulatory network to ODE model without proteins
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef GrnOdeConverter < synnetgen.extension.Extension
    properties (Constant)
        id = 'grn-ode'
        description = 'Convert gene regulatory network to ODE model (without proteins)'
        inputs = struct()
        outputs = struct (...
            'odes', 'ODE model')
    end
    
    methods (Static)
        function odes = run(network, varargin)
            import synnetgen.odes.Odes;
            
            %% parse arguments
            validateattributes(network, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
            ip = inputParser;
            ip.parse(varargin{:});
            
            %% convert to ODE model
            nodes = repmat(struct('id', '', 'label', ''), 0, 1);
            parameters = repmat(struct('id', '', 'label', ''), 0, 1);
            differentials = cell(size(network.nodes));
            for iNode = 1:numel(network.nodes)
                nodeId = network.nodes(iNode).id;
                nodes = [
                    nodes
                    struct('id', sprintf('r_%s', nodeId), 'label', sprintf('RNA %s', nodeId))
                    ];
                parameters = [
                    parameters
                    struct('id', sprintf('V_max_r_%s', nodeId), 'label', sprintf('Maximum transcription rate of gene %s', nodeId))
                    struct('id', sprintf('V_rel_on_r_%s', nodeId), 'label', sprintf('Relative transcription rate of gene %s when enhanced [0-1]', nodeId))
                    struct('id', sprintf('V_rel_off_r_%s', nodeId), 'label', sprintf('Releative transcription rate of gene %s when repressed [0-1]', nodeId))
                    struct('id', sprintf('K_r_%s', nodeId), 'label', sprintf('Transcription factor binding site affinity of protein %s', nodeId))
                    struct('id', sprintf('n_r_%s', nodeId), 'label', sprintf('Hill coefficient of gene %s', nodeId))
                    struct('id', sprintf('tau_r_%s', nodeId), 'label', sprintf('Half-life of RNA %s', nodeId))
                    ];
                
                [tt, edges] = network.getTruthTable(network.nodes(iNode).id, 'simplify', true);
                regIdxs = find(edges);
                nRegs = log2(numel(tt));
                f_num = cell(size(tt));
                f_denom = cell(size(tt));
                for i = 1:numel(tt)
                    if tt(i)
                        f_num_i = {sprintf('V_rel_on_r_%s', nodeId)};
                    else
                        f_num_i = {sprintf('V_rel_off_r_%s', nodeId)};
                    end
                    f_denom_i = {};
                    
                    regVals = dec2base(i - 1, 2, nRegs) == '1';
                    for j = 1:nRegs
                        if regVals(j)
                            regId = network.nodes(regIdxs(j)).id;
                            f_num_i = [f_num_i
                                sprintf('(r_%s/K_r_%s)^n_r_%s', regId, regId, regId)
                                ];
                            f_denom_i = [f_denom_i
                                sprintf('(r_%s/K_r_%s)^n_r_%s', regId, regId, regId)
                                ];
                        end
                    end
                    
                    f_num{i} = strjoin(f_num_i', ' * ');
                    f_denom{i} = strjoin(f_denom_i', ' * ');
                    
                    if isempty(f_denom{i})
                        f_denom{i} = '1';
                    end
                end
                
                if isempty(tt)
                    differentials{iNode} = sprintf('V_max_r_%s - %.4f/tau_r_%s * r_%s', ...
                        nodeId, log(2), nodeId, nodeId);
                else
                    differentials{iNode} = sprintf('V_max_r_%s * (%s)/(%s) - %.4f/tau_r_%s * r_%s', ...
                        nodeId, strjoin(f_num, ' + '), strjoin(f_denom, ' + '), log(2), nodeId, nodeId);
                end
            end
            
            %% construct ODE object
            odes = Odes();
            odes.setNodesParametersAndDifferentials(nodes, parameters, differentials);
        end
    end
end