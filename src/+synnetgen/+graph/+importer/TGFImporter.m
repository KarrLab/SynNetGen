%Imports graph in Trivial Graph Format (TGF;
%http://en.wikipedia.org/wiki/Trivial_Graph_Format). Edge label is used to
%encode sign. Doesn't support node labels.
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef TGFImporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'tgf'
        description = 'Trivial Graph Format graph importer'
        inputs = struct(...            
            'filename', 'File name' ...
            )
        outputs = struct (...
            'graph', 'Graph'...
            )
    end
    
    methods (Static)
        function graph = run(varargin)
            %% parse arguments
            ip = inputParser;
            ip.addParameter('filename', []);
            ip.parse(varargin{:});
            filename = ip.Results.filename;
            
            if isempty(filename)
                throw(MException('SynNetGen:InvalidArgument', 'filename must be defined'));
            end
            
            %% import
            fid = fopen(filename, 'r');
            if fid == -1
                throw(MException('SynNetGen:UnableToOpenFile', 'Unable to open file %s', filename));
            end
            
            graph = synnetgen.graph.Graph();
            
            %nodes
            iNode = 0;
            endNodes = false;
            while ~feof(fid)
                iNode = iNode + 1;
                
                line = fgetl(fid);
                if strcmp('#', line)
                    endNodes = true;
                    break;
                else
                    result = regexp(line, '^(?<number>\d+) (?<name>.+)$', 'names');
                    if ~isempty(result) && iNode == str2double(result.number)
                        graph.addNode(result.name, result.name);
                    else
                        throw(MException('SynNetGen:InvalidFile', 'File doesn''t match TGF format'))
                    end
                end
            end
            
            if ~endNodes
                throw(MException('SynNetGen:InvalidFile', 'File doesn''t match TGF format'))
            end
            
            while ~feof(fid)
                line = fgetl(fid);
                result = regexp(line, '^(?<iFrom>\d+) (?<iTo>\d+) (?<sign>[\+\-])$', 'names');
                iFrom = str2double(result.iFrom);
                iTo = str2double(result.iTo);
                if strcmp(result.sign, '+')
                    sign = 1;
                else
                    sign = -1;
                end
                graph.addEdge(graph.nodes(iFrom).name, graph.nodes(iTo).name, sign);
            end
            
            fclose(fid);
        end
    end
end