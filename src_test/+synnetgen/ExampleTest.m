%Tests example
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef ExampleTest < matlab.unittest.TestCase
    methods (Test)
        function testExample(this)
            n = 5;
            graphs = example(n);
            
            graph4 = graphs(4);
            graph5 = graphs(5);
            graph6 = graphs(6);
            
            this.verifyEqual(graph5.edges, graph4.edges - eye(n));
            this.verifyEqual(graph6.edges(1:n, 1:n), -eye(n))
            this.verifyEqual(graph6.edges(n+1:end, n+1:end), -eye(n))
            this.verifyEqual(graph6.edges(1:n, 1:n) + graph6.edges(n+1:end, 1:n), graph5.edges);
            this.verifyEqual(graph6.edges(1:n, n+1:end), eye(n));
        end
    end
end