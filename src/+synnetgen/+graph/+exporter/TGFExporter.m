%Exports graph in Trivial Graph Format (TGF;
%http://en.wikipedia.org/wiki/Trivial_Graph_Format). Edge label is used to
%encode sign. Doesn't support node labels.
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef TGFExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'tgf'
        description = 'Trivial Graph Format graph exporter'
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
            
            for iNode = 1:numel(graph.nodes)
                fprintf(fid, '%d %s\n', iNode, graph.nodes(iNode).id);
            end
            
            fprintf(fid, '#\n');
            
            [iFrom, iTo] = find(graph.edges);
            for iEdge = 1:numel(iFrom)
                if graph.edges(iFrom(iEdge), iTo(iEdge)) == 1
                    sign = '+';
                else
                    sign = '-';
                end
                fprintf(fid, '%d %d %s\n', iFrom(iEdge), iTo(iEdge), sign);
            end
            
            fclose(fid);
            
            status = true;
        end
    end
end