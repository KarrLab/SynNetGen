%Tests ODE model class and associated extensions
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef OdesTest < matlab.unittest.TestCase
    methods (Test)
        function testNewModel(this)
            m = synnetgen.odes.Odes();
        end
        
        function testAddNode(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            
            this.verifyEqual(m.nodes, [
                struct('id', 'a', 'label', 'A')
                struct('id', 'b', 'label', 'B')
                struct('id', 'c', 'label', 'C')
                ]);
        end
        
        function testAddParameter(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            
            this.verifyEqual(m.parameters, [
                struct('id', 'k', 'label', 'K')
                struct('id', 'l', 'label', 'L')
                struct('id', 'm', 'label', 'M')
                ]);
        end
        
        function testAreDifferentialsValid(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            
            this.verifyTrue(m.areDifferentialsValid(m.nodes, m.parameters, {'a^k-2+3+-2+(a*b/c)'}))
            this.verifyTrue(m.areDifferentialsValid(m.nodes, m.parameters, {'a^2-2.1+3+-2+(a*b/c)'}))
            this.verifyFalse(m.areDifferentialsValid(m.nodes, m.parameters, {'a^K-2+3+-2+(a*b/c)'}))
            this.verifyFalse(m.areDifferentialsValid(m.nodes, m.parameters, {'a^2-2+3+-2+(a*b/d)'}))
            this.verifyFalse(m.areDifferentialsValid(m.nodes, m.parameters, {'a^2-2+3+-2+(a*b/c'}))
            this.verifyFalse(m.areDifferentialsValid(m.nodes, m.parameters, {'a^2-2+3+-2+(A*b/c)'}))
        end
        
        function testSetDifferential(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'a^k-2+3+-2+(a*b/c)');
            m.setDifferential('b', 'a*l - c');
            m.setDifferential('c', 'a^2 + -((3/a^2)+2)');
            
            this.verifyEqual(m.differentials, {
                'a^k-2+3+-2+(a*b/c)'
                'a*l - c'
                'a^2 + -((3/a^2)+2)'
                });
        end
        
        function testSetDifferentials(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            
            differentials = {
                'a^k-2+3+-2+(a*b/c)'
                'a*l - c'
                'a^2 + -((3/a^2)+2)'
                };
            m.setDifferentials(differentials);
            
            this.verifyEqual(m.differentials, differentials);
        end
        
        function testSetNodesParametersAndDifferentials(this)
            m = synnetgen.odes.Odes();
            nodes = [
                struct('id', 'a', 'label', 'A')
                struct('id', 'b', 'label', 'B')
                struct('id', 'c', 'label', 'C')
                ];
            parameters = [
                struct('id', 'k', 'label', 'K')
                struct('id', 'l', 'label', 'L')
                struct('id', 'm', 'label', 'M')
                ];
            differentials = {
                'a^k-2+3+-2+(a*b/c)'
                'a*l - c'
                'a^2 + -((3/a^2)+2)'
                };
            m.setNodesParametersAndDifferentials(nodes, parameters, differentials);
            
            this.verifyEqual(m.nodes, nodes);
            this.verifyEqual(m.parameters, parameters);
            this.verifyEqual(m.differentials, differentials);
        end
        
        function testGetEdges(this)
            mdl = synnetgen.odes.Odes();
            mdl.addNode('a', 'A');
            mdl.addNode('b', 'B');
            mdl.addNode('c', 'C');
            mdl.addParameter('k', 'K');
            mdl.addParameter('l', 'L');
            mdl.addParameter('m', 'M');
            mdl.setDifferential('a', 'a^2 - (a*b/c) - 1');
            mdl.setDifferential('b', 'a*b - c');
            mdl.setDifferential('c', 'c - b^k');
            
            a = 2;
            b = 3;
            c = 5;
            k = 7;
            l = 11;
            m = 13;
            edges = [
                2*a-b/c   b   0
                -a/c      a   -k*b^(k-1)
                a*b/c^2   -1  1
                ];
            edges(edges > 0) =  1;
            edges(edges < 0) = -1;
            
            this.verifyEqual(mdl.getEdges('y', [a; b; c], 'k', [k; l; m]), edges);
        end

        function testIsequal(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'a^2-2+3+-2+(a*b/c)');
            m.setDifferential('b', 'a*b - c');
            m.setDifferential('c', 'a^2 + -((3/a^2)+2)');
            
            n = synnetgen.odes.Odes();
            n.addNode('a', 'A');
            n.addNode('c', 'C');
            n.addNode('b', 'B');
            n.addParameter('l', 'L');
            n.addParameter('m', 'M');
            n.addParameter('k', 'K');
            n.setDifferential('a', 'a^2-2+3+-2+(b*a/c)');
            n.setDifferential('b', 'b*a - c');
            n.setDifferential('c', 'a^2 - ((3/a^2)+2)');
            
            this.verifyEqual(n, m);
        end

        function testClear(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'a^2-2+3+-2+(a*b/c)');
            m.setDifferential('b', 'a*b - c');
            m.setDifferential('c', 'a^2 + -((3/a^2)+2)');
            
            m.clear();
            this.verifyEqual(m.nodes, repmat(struct('id', '', 'label', ''), 0, 1));
            this.verifyEqual(m.parameters, repmat(struct('id', '', 'label', ''), 0, 1));
            this.verifyEqual(m.differentials, cell(0, 1));
        end
        
        function testCopy(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'a^k-2+3+-2+(a*b/c)');
            m.setDifferential('b', 'a*l - c');
            m.setDifferential('c', 'a^2 + -((3/a^2)+2)');
            
            n = m.copy();
            
            this.verifyEqual(n.nodes, m.nodes);
            this.verifyEqual(n.parameters, m.parameters);
            this.verifyEqual(n.differentials, m.differentials);
            
            this.verifyEqual(n, m);
        end

        function testPrint(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'a^k-2+3+-2+(a*b/c)');
            m.setDifferential('b', 'a*l - c');
            m.setDifferential('c', 'a^2 + -((3/a^2)+2)');
            
            msg = m.print();
            this.verifyClass(msg, 'cell');
            this.verifyTrue(all(cellfun(@ischar, msg)));
            
            m.disp();
        end
        
        function testPlot(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', '-c');
            m.setDifferential('b', 'a');
            m.setDifferential('c', 'a * b');
            
            h = m.plot();
            close(h);
        end
        
        function testSimulate(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'k');
            m.setDifferential('b', 'b*l');
            m.setDifferential('c', 'm/c');
            
            tMax = 10;
            tStep = 1;
            y0 = [2; 3; 5];
            k = [7; 0.011; 13];
            vals = m.simulate('tMax', tMax, 'tStep', tStep, 'y0', y0, 'k', k);
            this.verifySize(vals, [numel(m.nodes) numel(0:tStep:tMax)]);
            
            endVals = vals(:, end);
            expEndVals = [
                k(1)*tMax+y0(1)
                y0(2) * exp(k(2)*tMax)
                sqrt(2*k(3)*tMax + y0(3)^2)
                ];
            
            this.verifyLessThan((endVals(1)-expEndVals(1)).^2 ./ expEndVals(1), 1e-6);
            this.verifyLessThan((endVals(2)-expEndVals(2)).^2 ./ expEndVals(2), 1e-6);
            this.verifyLessThan((endVals(3)-expEndVals(3)).^2 ./ expEndVals(3), 1e-6);
        end
                
        function testConvertToSimBiology(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'b - c');
            m.setDifferential('b', 'a*k + c');
            m.setDifferential('c', 'a^l * b');
            
            mdl = m.convert('SimBiology');
            this.verifyClass(mdl, 'SimBiology.Model');
        end
        
        function testConvertToGraph(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'b - c');
            m.setDifferential('b', 'a*k + c');
            m.setDifferential('c', 'a^l * b');
            
            g = m.convert('graph');
            this.verifyClass(g, 'synnetgen.graph.Graph');
        end
        
        function testMATLABExport(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'A');
            m.addNode('b', 'B');
            m.addNode('c', 'C');
            m.addParameter('k', 'K');
            m.addParameter('l', 'L');
            m.addParameter('m', 'M');
            m.setDifferential('a', 'b - c');
            m.setDifferential('b', 'a*k + c');
            m.setDifferential('c', 'a^l * b');
            
            filename = [tempname('tmp') '.m'];
            funcName = filename(5:end-2);
            m.export('MATLAB', 'filename', filename);

            rehash();
            func = str2func(funcName);
            this.verifyTrue(isa(func, 'function_handle'));

            y0 = [3; 4; 5];
            k = [2; 3; 2];
            dy = feval(func, 0, y0, k);
            delete(filename);
            
            this.verifyEqual(dy, [
                -1;
                11
                108
                ]);
        end
        
        function testSBMLExportImport(this)
            m = synnetgen.odes.Odes();
            m.addNode('a', 'a');
            m.addNode('b', 'b');
            m.addNode('c', 'c');
            m.addParameter('k', 'k');
            m.addParameter('l', 'l');
            m.addParameter('m', 'm');
            m.setDifferential('a', 'b-c');
            m.setDifferential('b', 'a+c');
            m.setDifferential('c', 'a*b');
            
            filename = [tempname() '.xml'];
            m.export('sbml', 'filename', filename);
            
            n = synnetgen.odes.Odes();
            n.import('sbml', 'filename', filename);
            
            this.verifyEqual(n.nodes, m.nodes);
            this.verifyEqual(n.parameters, m.parameters);
            this.verifyEqual(n.differentials, m.differentials);
            
            this.verifyEqual(n, m);
        end
    end
end