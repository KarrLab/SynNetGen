%Exports graph in GraphML format.
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef GraphMLExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'graphml'
        description = 'GraphML graph exporter'
        inputs = struct(...
            'graph', 'Graph', ...
            'filename', 'File name' ...
            )
        outputs = struct (...
            'status', 'Indicates success (True/False)' ...
            )
    end
    
    methods (Static)
        function status = run(varargin)
            %parse arguments
            ip = inputParser;
            ip.addParameter('graph', []);
            ip.addParameter('filename', []);
            ip.parse(varargin{:});
            graph = ip.Results.graph;
            filename = ip.Results.filename;
            
            if isempty(graph)
                throw(MException('SynNetGen:InvalidArgument', 'graph must be defined'));
            end
            if isempty(filename)
                throw(MException('SynNetGen:InvalidArgument', 'filename must be defined'));
            end
            
            %export
            doc = com.mathworks.xml.XMLUtils.createDocument('graphml');
            root = doc.getDocumentElement;
            root.setAttribute('xmlns', 'http://graphml.graphdrawing.org/xmlns');
            root.setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
            root.setAttribute('xsi:schemaLocation', 'http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd');
            
            labelKey = doc.createElement('key');
            labelKey.setAttribute('id', 'label');
            labelKey.setAttribute('for', 'node');
            labelKey.setAttribute('attr.name', 'label');
            labelKey.setAttribute('attr.type', 'string');
            root.appendChild(labelKey);
            
            signKey = doc.createElement('key');
            signKey.setAttribute('id', 'sign');
            signKey.setAttribute('for', 'edge');
            signKey.setAttribute('attr.name', 'sign');
            signKey.setAttribute('attr.type', 'int');
            root.appendChild(signKey);
            
            graphXML = doc.createElement('graph');
            graphXML.setAttribute('id', 'G');
            graphXML.setAttribute('edgedefault', 'directed');
            root.appendChild(graphXML);
            
            for iNode = 1:numel(graph.nodes)
                nodeXML = doc.createElement('node');
                nodeXML.setAttribute('id', graph.nodes(iNode).name);
                graphXML.appendChild(nodeXML);
                
                label = doc.createElement('data');
                label.setAttribute('key', 'label');
                nodeXML.appendChild(label);
                
                label.appendChild(doc.createTextNode(graph.nodes(iNode).label));
            end
            
            [iFrom, iTo] = find(graph.edges);
            for iEdge = 1:numel(iFrom)
                edgeXML = doc.createElement('edge');
                edgeXML.setAttribute('id', sprintf('edge-%d', iEdge));
                edgeXML.setAttribute('source', graph.nodes(iFrom(iEdge)).name);
                edgeXML.setAttribute('target', graph.nodes(iTo(iEdge)).name);
                graphXML.appendChild(edgeXML);
                
                sign = doc.createElement('data');
                sign.setAttribute('key', 'sign');
                edgeXML.appendChild(sign);
                
                sign.appendChild(doc.createTextNode(num2str(graph.edges(iFrom(iEdge), iTo(iEdge)))));
            end
            
            xmlwrite(filename, doc);
            
            status = true;
        end
    end
end