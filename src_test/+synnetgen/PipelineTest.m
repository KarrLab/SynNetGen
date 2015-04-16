%Tests entire pipeline
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef PipelineTest < matlab.unittest.TestCase
    methods (Test)
        function testGenerateDynamics(this)
            %generate undirected, unsigned graph
            graph1 = synnetgen.graph.Graph.generate('barabasi-albert', 'n', 10, 'm', 3);
            
            %make directed
            graph2 = graph1.copy();
            graph2.setEdges(triu(graph1.edges));
            graph2.randomizeDirectionality();
            
            %make signed
            graph3 = graph2.copy();
            graph3.randomizeSigns();
            
            %browse through plots
            graphs = [
                graph1
                graph2
                graph3
                ];
            for i = 1:numel(graphs)
                h = graphs(i).plot();
                pause(0.25);
                close(h.fig);
            end
        end
    end
end