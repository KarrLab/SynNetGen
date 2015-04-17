%Exports graph in Dot Graph Format
%(http://www.graphviz.org/Documentation.php). 
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef DotExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'dot'
        description = 'Dot (GraphViz) graph exporter'
        inputs = struct(...
            'filename', 'File name' ...
            )
        outputs = struct (...
            'status', 'Indicates success (True/False)' ...
            )
    end
    
    methods (Static)
        function status = run(graph, varargin)
            %parse arguments
            ip = inputParser;
            ip.addParameter('filename', []);
            ip.parse(varargin{:});
            filename = ip.Results.filename;
            
            if isempty(graph)
                throw(MException('SynNetGen:InvalidArgument', 'graph must be defined'));
            end
            if isempty(filename)
                throw(MException('SynNetGen:InvalidArgument', 'filename must be defined'));
            end
            
            %export
            fid = fopen(filename, 'w+');
            if fid == -1
                throw(MException('SynNetGen:UnableToOpenFile', 'Unable to open file %s', filename));
            end
            
            fprintf(fid, 'digraph G {\n');
            
            for iNode = 1:numel(graph.nodes)
                fprintf(fid, '  "%s" ["%s"];\n', ...
                    strrep(graph.nodes(iNode).id, '"', '\"'), ...
                    strrep(graph.nodes(iNode).label, '"', '\"'));
            end
            
            [iFrom, iTo] = find(graph.edges);
            for iEdge = 1:numel(iFrom)
                if graph.edges(iFrom(iEdge), iTo(iEdge)) == 1
                    arrowhead  = 'normal';
                else
                    arrowhead  = 'tee';
                end
                fprintf(fid, '  "%s" -> "%s" [arrowhead=%s];\n', ...
                    strrep(graph.nodes(iFrom(iEdge)).id, '"', '\"'), ...
                    strrep(graph.nodes(iTo(iEdge)).id, '"', '\"'), ...
                    arrowhead);
            end
            
            fprintf(fid, '}\n');
            fclose(fid);
            
            status = true;
        end
    end
end