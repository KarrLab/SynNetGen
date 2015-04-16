%Tests directed graph class and associated extensions
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef GraphTest < matlab.unittest.TestCase
    methods (Test)
        function testNewGraph(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            this.verifyEmpty(g.nodes);
            this.verifyEmpty(g.edges);
        end
        
        function testSetNodesAndEdges(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            g.addNode('a', 'A');
            g.addNode('b', 'B');
            g.addNode('c', 'C');
            g.addEdge('a', 'b', 1);
            g.addEdge('c', 'c', -1);
            
            h = Graph();
            h.setNodesAndEdges([
                struct('name', 'a', 'label', 'A')
                struct('name', 'b', 'label', 'B')
                struct('name', 'c', 'label', 'C')
                ], [0 1 0; 0 0 0; 0 0 -1]);
            
            this.verifyEqual(g, h);
        end
        
        function testAddDeleteNode(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            g.addNode('a', 'A');
            this.verifyEqual(struct('name', 'a', 'label', 'A'), g.nodes);
            this.verifyEqual(zeros(1), g.edges);
            
            g.addNode('b', 'B');
            this.verifyEqual([
                struct('name', 'a', 'label', 'A')
                struct('name', 'b', 'label', 'B')
                ], g.nodes);
            this.verifyEqual(zeros(2), g.edges);
            
            g.addNode('c', 'C');
            this.verifyEqual([
                struct('name', 'a', 'label', 'A')
                struct('name', 'b', 'label', 'B')
                struct('name', 'c', 'label', 'C')
                ], g.nodes);
            this.verifyEqual(zeros(3), g.edges);
            
            g.removeNode('b');
            this.verifyEqual([
                struct('name', 'a', 'label', 'A')
                struct('name', 'c', 'label', 'C')
                ], g.nodes);
            this.verifyEqual(zeros(2), g.edges);
        end
        
        function testSetNodes(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            g.addNode('a', 'A');
            g.addNode('b', 'B');
            g.addNode('c', 'C');
            g.setNodes([
                struct('name', 'x', 'label', 'X')
                struct('name', 'y', 'label', 'Y')
                struct('name', 'z', 'label', 'Z')
                ]);
            
            h = Graph();
            h.addNode('x', 'X');
            h.addNode('y', 'Y');
            h.addNode('z', 'Z');
            
            this.verifyEqual(g, h);
        end
        
        function testAddDeleteEdges(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            g.addNode('a', 'A');
            g.addNode('b', 'B');
            g.addNode('c', 'C');
            
            g.addEdge('a', 'b', 1);
            this.verifyEqual(1, nnz(g.edges));
            this.verifyEqual(1, g.edges(1, 2));
            
            g.addEdge('c', 'c', -1);
            this.verifyEqual(2, nnz(g.edges));
            this.verifyEqual(1, g.edges(1, 2));
            this.verifyEqual(-1, g.edges(3, 3));
        end
        
        function testSetEdges(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            g.addNode('a', 'A');
            g.addNode('b', 'B');
            g.addNode('c', 'C');
            g.addEdge('a', 'b', 1);
            g.addEdge('c', 'c', -1);
            
            h = Graph();
            h.addNode('a', 'A');
            h.addNode('b', 'B');
            h.addNode('c', 'C');
            h.setEdges([0 1 0; 0 0 0; 0 0 -1]);
            
            this.verifyEqual(g, h);
        end
        
        function testRandomizeAndRemoveDirectionalityAndSigns(this)
            import synnetgen.graph.Graph;
            
            g = Graph([
                struct('name', 'a', 'label', 'A')
                struct('name', 'b', 'label', 'B')
                struct('name', 'c', 'label', 'C')
                ], [0 1 0; 0 0 0; 0 0 -1]);
            
            g.randomizeDirectionality();
            g.removeDirectionality();
            g.randomizeSigns();
            g.removeSigns();
        end
        
        function testIsEqual(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            g.addNode('a', 'A');
            g.addNode('b', 'B');
            g.addNode('c', 'C');
            g.addEdge('a', 'b', 1);
            g.addEdge('c', 'c', -1);
            
            h = Graph();
            h.addNode('b', 'B');
            h.addNode('c', 'C');
            h.addNode('a', 'A');
            h.addEdge('a', 'b', 1);
            h.addEdge('c', 'c', -1);
            
            i = Graph();
            i.addNode('b', 'B');
            i.addNode('c', 'C');
            i.addNode('a', 'A');
            i.addEdge('a', 'b', 1);
            i.addEdge('b', 'b', -1);
            
            j = Graph();
            j.addNode('b', 'B');
            j.addNode('c', 'C');
            j.addNode('a', 'A');
            j.addNode('d', 'D');
            j.addEdge('a', 'b', 1);
            j.addEdge('c', 'c', -1);
            
            this.verifyEqual(g, h);
            this.verifyNotEqual(g, i);
            this.verifyNotEqual(g, j);
        end
        
        function testCopy(this)
            import synnetgen.graph.Graph;
            
            g = Graph([
                struct('name', 'a', 'label', 'A')
                struct('name', 'b', 'label', 'B')
                struct('name', 'c', 'label', 'C')
                ], [0 1 0; 0 0 0; 0 0 -1]);
            
            this.verifyEqual(g, g.copy());
        end
        
        function testDisplayPlot(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            g.addNode('a', 'a');
            g.addNode('b', 'b');
            g.addNode('c', 'c');
            g.addEdge('a', 'b', 1);
            g.addEdge('b', 'c', -1);
            
            g.print();
            
            h = g.plot();
            close(h.fig);
        end
        
        function testGenerateBarabasiAlbert(this)
            import synnetgen.graph.Graph;
            
            n = 10;
            m = 3;
            g = Graph.generate('barabasi-albert', 'n', n, 'm', m);
            this.verifyEqual(n, numel(g.nodes));
            this.verifyEqual((n-m) * m, nnz(triu(g.edges)));
            this.verifyEqual(triu(g.edges), tril(g.edges)');
        end
        
        function testGenerateEdgarGilbert(this)
            import synnetgen.graph.Graph;
            
            n = 10;
            p = 0.1;
            
            nTest = 100;
            m = zeros(nTest, 1);
            for iTest = 1:nTest
                g = Graph.generate('edgar-gilbert', 'n', n, 'p', p);
                this.verifyEqual(n, numel(g.nodes));
                m(iTest) = nnz(g.edges);
            end
            
            expMean = p * n^2;
            expstd = sqrt(p * (1-p)*n^2);
            this.verifyGreaterThan(mean(m), expMean - 0.25 * expstd);
            this.verifyLessThan(mean(m), expMean + 0.25 * expstd);
            this.verifyEqual(triu(g.edges), tril(g.edges)');
        end
        
        function testGenerateErdosReyni(this)
            import synnetgen.graph.Graph;
            
            n = 10;
            m = 10;
            g = Graph.generate('erdos-reyni', 'n', n, 'm', m);
            this.verifyEqual(n, numel(g.nodes));
            this.verifyEqual(m, nnz(triu(g.edges)));
            this.verifyEqual(triu(g.edges), tril(g.edges)');
        end
        
        function testGenerateWattsStrogatz(this)
            import synnetgen.graph.Graph;
            
            n = 10;
            p = 0.1;
            k = 2;
            g = Graph.generate('watts-strogatz', 'n', n, 'p', p, 'k', k);
            this.verifyEqual(n, numel(g.nodes));
            this.verifyEqual(triu(g.edges), tril(g.edges)');
        end
        
        function testImportExportTGF(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            g.addNode('a', 'a');
            g.addNode('b', 'b');
            g.addNode('c', 'c');
            g.addEdge('a', 'b', 1);
            g.addEdge('c', 'c', -1);
            
            filename = tempname();
            Graph.export('tgf', 'graph', g, 'filename', filename);
            
            h = Graph.import('tgf', 'filename', filename);
            
            this.verifyEqual(g, h);
            
            delete(filename);
        end
        
        function testExportDot(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            g.addNode('a', 'a');
            g.addNode('b', 'b');
            g.addNode('c', 'c');
            g.addEdge('a', 'b', 1);
            g.addEdge('c', 'c', -1);
            
            filename = tempname();
            Graph.export('dot', 'graph', g, 'filename', filename);
            
            delete(filename);
        end
        
        function testExportGraphML(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            g.addNode('a', 'a');
            g.addNode('b', 'b');
            g.addNode('c', 'c');
            g.addEdge('a', 'b', 1);
            g.addEdge('c', 'c', -1);
            
            filename = tempname();
            Graph.export('graphml', 'graph', g, 'filename', filename);
            
            delete(filename);
        end
        
        function testExportGML(this)
            import synnetgen.graph.Graph;
            
            g = Graph();
            
            g.addNode('a', 'a');
            g.addNode('b', 'b');
            g.addNode('c', 'c');
            g.addEdge('a', 'b', 1);
            g.addEdge('c', 'c', -1);
            
            filename = tempname();
            Graph.export('gml', 'graph', g, 'filename', filename);
            
            delete(filename);
        end
    end
end