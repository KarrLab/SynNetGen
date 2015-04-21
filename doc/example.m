%Example package usage. Illustrates how to use this package:
%1. Create a random unsigned, undirected graph
%2. Randomize the directions and signs to create a random signed, directed graph
%3. Convert the graph to a random Boolean network
%4. Convert Boolean network to dynamical ODE models
%5. Simulate ODE model
%6. Calculate steady state of ODE model
%7. Print and plot the graphs, network, and ODE models
%8. Export the graphs, network, and ODE models
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-20
function graphs = example(n)
if nargin == 0
    n = 5;
end

%generate undirected, unsigned graph
graph1 = synnetgen.graph.Graph();
graph1.generate('barabasi-albert', 'n', n, 'm', 2);

%make directed
graph2 = graph1.copy();
graph2.setEdges(triu(graph1.edges));
graph2.transform('RandomizeDirections');

%make signed
graph3 = graph2.copy();
graph3.transform('RandomizeSigns');

%convert to boolean network
model4 = graph3.convert('boolnet');
graph4 = model4.convert('graph');

%convert to ODE models
model5 = model4.convert('grn-ode');
model6 = model4.convert('grn-protein-ode');

y5 = 1e-3 * ones(n, 1);
y6 = 1e-3 * ones(2 * n, 1);
k5 = repmat([1; 1; 0.1; 1; 1; 1], n, 1);
k6 = repmat([1; 1; 0.1; 1; 1; 1; 1; 1], n, 1);

graph5 = model5.convert('graph', 'y', y5, 'k', k5);
graph6 = model6.convert('graph', 'y', y6, 'k', k6);

%simulate boolean network
tMax = 10;
result = model4.simulate('tMax', tMax);
figHandle = figure();
plot(gca, 0:tMax, result);
close(figHandle);

%simulate ODE model
tMax = 10;
tStep = 0.1;
result = model5.simulate('tMax', tMax', 'tStep', tStep, 'y0', y5, 'k', k5);
figHandle = figure();
plot(gca, 0:tStep:tMax, result);
close(figHandle);

%calculate ODE steady-state
model7 = synnetgen.odes.Odes();
model7.addNode('a', 'A');
model7.addNode('b', 'B');
model7.addParameter('k', 'K');
model7.addParameter('l', 'L');
model7.setDifferential('a', '-(a-k)/2');
model7.setDifferential('b', '-(b+l)/2');

k = [3; 5];
y0 = rand(2, 1);
ss = model7.calcSteadyState('y0', y0, 'k', k, 'solver', 'ode45');

graph7 = model7.convert('graph', 'y', y0, 'k', k);

%browse through plots
graphs = [
    graph1
    graph2
    graph3
    graph4
    graph5
    graph6
    graph7
    ];
for i = 1:numel(graphs)
    figHandle = graphs(i).plot();
    pause(0.25);
    close(figHandle);
end

%export
graph1.export('dot', 'filename', 'doc/example/model1.dot');
graph1.export('gml', 'filename', 'doc/example/model1.gml');
graph1.export('graphml', 'filename', 'doc/example/model1.xml');
graph1.export('tgf', 'filename', 'doc/example/model1.tgf');

graph2.export('dot', 'filename', 'doc/example/model2.dot');
graph2.export('gml', 'filename', 'doc/example/model2.gml');
graph2.export('graphml', 'filename', 'doc/example/model2.xml');
graph2.export('tgf', 'filename', 'doc/example/model2.tgf');

graph3.export('dot', 'filename', 'doc/example/model3.dot');
graph3.export('gml', 'filename', 'doc/example/model3.gml');
graph3.export('graphml', 'filename', 'doc/example/model3.xml');
graph3.export('tgf', 'filename', 'doc/example/model3.tgf');

model4.export('matlab', 'filename', 'doc/example/model4.m');
model4.export('R-BoolNet', 'filename', 'doc/example/model4.bn');
model4.export('sbml', 'filename', 'doc/example/model4.xml');

model5.export('matlab', 'filename', 'doc/example/model5.m');
model5.export('sbml', 'filename', 'doc/example/model5.xml');

model6.export('matlab', 'filename', 'doc/example/model5.m');
model6.export('sbml', 'filename', 'doc/example/model5.xml');