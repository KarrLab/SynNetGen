# SynNetGen

## Installation

### Requirements
* MATLAB >= 2014a
* GraphViz >= 2.36.0

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

## Documentation

### Generators
* Graphs
  * Barabasi-Albert (n, m)
  * Edgar-Gilbert (n, p)
  * Erdos-Reyni (n, m)
  * Watts-Strogatz (n, p, k)

### File formats
Format  | Extension | Type  | Input | Output
------- | --------- | ----- | ----- | ------ 
Dot     | dot       | Graph |       | X 
GML     | gml       | Graph |       | X 
GraphML | xml       | Graph |       | X 
TGF     | tgf       | Graph | X     | X 

## About SynNetGen

### Development team
SynNetGen was developed at the Mount Sinai School of Medicine by:
* [Jonathan Karr](http://research.mssm.edu/karr)
* [Rui Chang](http://research.mssm.edu/changlab)

### Third party software included in release
* [graphviz4matlab](https://github.com/graphviz4matlab/graphviz4matlab)
* [M2HTML](http://www.artefact.tk/software/matlab/m2html)

### License
SynNetGen is licensed under The MIT License. See [license](LICENSE) for further information.

### Questions? Comments?
Please contact the development team.