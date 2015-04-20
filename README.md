# SynNetGen
MATLAB toolbox for creating random dynamical models, Boolean networks, and graphs. The toolbox is highly extensible such that additional methods can easily be added to provide additional ways of generating dynamical models from Boolean networks, as well as additional ways to transform all three types of models.

## Installation

### Requirements

Package                                                                    | Tested version | Required for
-------------------------------------------------------------------------- | -------------- | --------------------------
[MATLAB](http://www.mathworks.com/products/matlab)                         | 2014a          | **Core functionality**
[MATLAB-SimBiology Toolbox](http://www.mathworks.com/products/simbiology)  | 2014a          | Export models to SBML
[MATLAB-Symbolic Math Toolbox](http://www.mathworks.com/products/symbolic) | 2014a          | Test equality of ODE models
[GraphViz](http://graphviz.org)                                            | 2.36.0         | Plotting
[libSBML-MATLAB](http://sbml.org/Software/libSBML)                         | 5.11.4         | SBML import/export

### Setup
1. Installed required software
2. Clone repository

    ```Shell
    git clone https://github.com/jonrkarr/SynNetGen.git
    ```
3. Change to /path/to/SynNetGen
4. Open MALTAB
5. Run installer

    ```matlab
    install();
    ```
    
## Getting started

The following example illustrates how to use this package:

1. Create a random unsigned, undirected graph
2. Randomize the directions and signs to create a random signed, directed graph
3. Convert the graph to a random Boolean network
4. Convert Boolean network to dynamical ODE model
5. Print and plot the graphs and network
6. Export the graphs and network

```matlab
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

%convert to ODE model
model5 = model4.convert('grn-ode');
model6 = model4.convert('grn-protein-ode');

%simulate boolean network and ODE models
tMax = 10;
vals = model4.simulate('y0', false(size(model4.nodes)), 'tMax', tMax);
plot(0:tMax, vals);

tMax = 10;
tStep = 0.1;
vals = model5.simulate('y0', ones(size(model5.nodes)), 'k', ones(size(model5.parameters)), 'tMax', tMax, 'tStep', tStep);
plot(0:tStep:tMax, vals);

tMax = 10;
tStep = 0.1;
vals = model6.simulate('y0', ones(size(model6.nodes)), 'k', ones(size(model6.parameters)), 'tMax', tMax, 'tStep', tStep);
plot(0:tStep:tMax, vals);

%print and plot
model3.display();
model3.plot();

model4.display();
model4.plot();

model5.display();
model5.plot();

model6.display();
model6.plot();

%export
model3.export('tgf', 'model3.tgf');
model4.export('R-BoolNet', 'model4.bn');
model5.export('sbml', 'model5.xml');
```

## Documentation

### Overview
The package provides three model classes: Graph, BoolNet, and Odes to represent graphs, Boolean networks, and orindary differential (ODE) models. Each class provides methods for:
* `setNodesAndEdges`, `setNodesAndRules`, `setNodesAndDifferentials`: Adding and setting node and edges/rules/differentials
* `generate`: Generating random models
* `transform`: Transforming models (e.g. randomize edge signs of a graph)
* `convert`: Converting among all three types of models
* `simulate`: Simulating the model
* `display`, `print`, `plot`: Displaying, printing, plotting
* `import`, `export`: Importing, exporting

See the API docs for more information about each function.

### Generators
Generator       | Parameters | Type 
--------------- | ---------- | -----
Barabasi-Albert | n, m       | Graph
Edgar-Gilbert   | n, p       | Graph
Erdos-Reyni     | n, m       | Graph
Watts-Strogatz  | n, p, k    | Graph

### File formats
Format    | Extension | Graph    | BoolNet  | ODEs     | Import   | Export
-------   | --------- | :------: | :------: | :------: | :------: | :------:
Dot       | dot       | &#x2713; |          |          |          | &#x2713;
GML       | gml       | &#x2713; |          |          |          | &#x2713; 
GraphML   | xml       | &#x2713; |          |          |          | &#x2713;
MATLAB    | m         |          | &#x2713; | &#x2713; |          | &#x2713;
R BoolNet | bn        |          | &#x2713; |          | &#x2713; | &#x2713;
SBML      | xml       |          | &#x2713; | &#x2713; | &#x2713; | &#x2713;
TGF       | tgf       | &#x2713; |          |          | &#x2713; | &#x2713;

Note: Boolean networks exported to SBML have "NOT" operators replaced with "-" because SimBiology doesn't support NOT.

### API docs
After installing the toolbox, open `/path/to/SynNetGen/doc/m2html/index.html` in your web browser to view the API docs.

## About SynNetGen

### Development team
SynNetGen was developed at the [Icahn School of Medicine at Mount Sinai](http://mssm.edu) by:
* [Jonathan Karr](http://research.mssm.edu/karr)
* [Rui Chang](http://research.mssm.edu/changlab)

### Third party software included in release
* [graphviz4matlab](https://github.com/graphviz4matlab/graphviz4matlab): revision 8cbc3eaa757b2fdcb10fc10af87ee7bd8ea1d6f2
* [M2HTML](http://www.artefact.tk/software/matlab/m2html): version 1.5
* [RBN Toolbox](http://www.teuscher-research.ch/rbntoolbox): version 2.0

### License
SynNetGen is licensed under The MIT License. See [license](LICENSE) for further information.

### Questions? Comments?
Please contact the development team.