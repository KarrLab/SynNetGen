%Example package usage. Illustrates how to use this package:
%1. Create a random unsigned, undirected graph
%2. Randomize the directions and signs to create a random signed, directed graph
%3. Convert the graph to a random Boolean network
%4. Convert Boolean network to dynamical ODE model
%5. Print and plot the graphs and network
%6. Export the graphs and network
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-20
function example()
%desired network size
n = 5;

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
this.verifyEqual(graph5.edges, graph4.edges - eye(n));
this.verifyEqual(graph6.edges(1:n, 1:n), -eye(n))
this.verifyEqual(graph6.edges(n+1:end, n+1:end), -eye(n))
this.verifyEqual(graph6.edges(1:n, 1:n) + graph6.edges(n+1:end, 1:n), graph5.edges);
this.verifyEqual(graph6.edges(1:n, n+1:end), eye(n));

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
steadyState = model5.calcSteadyState('y0', y5, 'k', k5);

%browse through plots
graphs = [
    graph1
    graph2
    graph3
    graph4
    graph5
    graph6
    ];
for i = 1:numel(graphs)
    figHandle = graphs(i).plot();
    pause(0.25);
    close(figHandle);
end

%export
graph3.export('tgf', 'model3.tgf');
model4.export('R-BoolNet', 'model4.bn');
model5.export('sbml', 'model5.xml');
model6.export('matlab', 'model5.m');