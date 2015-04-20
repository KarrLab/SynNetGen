%Tests entire pipeline
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef PipelineTest < matlab.unittest.TestCase
    methods (Test)
        function testGenerateDynamics(this)
            %generate undirected, unsigned graph
            model1 = synnetgen.graph.Graph();
            model1.generate('barabasi-albert', 'n', 10, 'm', 3);
            
            %make directed
            model2 = model1.copy();
            model2.setEdges(triu(model1.edges));
            model2.transform('RandomizeDirections');
            
            %make signed
            model3 = model2.copy();
            model3.transform('RandomizeSigns');
            
            %convert to boolean network
            model4 = model3.convert('boolnet');
            
            %simulate
            tMax = 10;
            result = model4.simulate('tMax', tMax);
            figHandle = figure();
            plot(gca, 0:tMax, result);
            close(figHandle);
            
            %TODO: add convert to ODE model
            
            %browse through plots
            graphs = {
                model1
                model2
                model3
                model4
                };
            for i = 1:numel(graphs)
                figHandle = graphs{i}.plot();
                pause(0.25);
                close(figHandle);
            end
        end
    end
end