# SynNetGen

## Installation

### Requirements

Package                                            | Tested version | Optional
-------------------------------------------------- | -------------- | ------------------
[MATLAB](http://www.mathworks.com/products/matlab) | 2014a          | 
[GraphViz](http://graphviz.org)                    | 2.36.0         | Plotting
[libSBML-MATLAB](http://sbml.org/Software/libSBML) | 5.11.4         | SBML import/export

### Setup
1. Installed required software
2. Clone repository

    ```
    git clone https://github.com/jonrkarr/SynNetGen.git
    ```
3. Change to /path/to/SynNetGen
4. Open MALTAB
5. Run installer

    ```
    install();
    ```
    
## Getting started

The following example illustrates how to:

1. Create a random unsigned, undirected graph
2. Randomize the directions and signs to create a random signed, directed graph
3. Convert the graph to a random Boolean network
4. Print and plot the graphs and network
5. Export the grapsh and network

```
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
vals = model4.simulate('x0', zeros(size(model4.nodes)), 'tMax', tMax);
plot(0:tMax, vals);

%print and plot
model3.display();
model3.plot();

model4.display();
model4.plot();

%export
model3.export('tgf', 'model3.tgf');
model4.export('R-BoolNet', 'model4.bn');
```

## Documentation

### Generators
Generator       | Parameters | Type 
--------------- | ---------- | -----
Barabasi-Albert | n, m       | Graph
Edgar-Gilbert   | n, p       | Graph
Erdos-Reyni     | n, m       | Graph
Watts-Strogatz  | n, p, k    | Graph

### File formats
Format    | Extension | Type    | Import | Export
-------   | --------- | ------- | ------ | ------ 
Dot       | dot       | Graph   |        | X 
GML       | gml       | Graph   |        | X 
GraphML   | xml       | Graph   |        | X 
MATLAB    | m         | BoolNet |        | X
R BoolNet | bn        | BoolNet | X      | X
SBML      | xml       |         |        |
TGF       | tgf       | Graph   | X      | X 

## About SynNetGen

### Development team
SynNetGen was developed at the Mount Sinai School of Medicine by:
* [Jonathan Karr](http://research.mssm.edu/karr)
* [Rui Chang](http://research.mssm.edu/changlab)

### Third party software included in release
* [graphviz4matlab](https://github.com/graphviz4matlab/graphviz4matlab)
* [M2HTML](http://www.artefact.tk/software/matlab/m2html)
* [RBN Toolbox](http://www.teuscher-research.ch/rbntoolbox)

### License
SynNetGen is licensed under The MIT License. See [license](LICENSE) for further information.

### Questions? Comments?
Please contact the development team.