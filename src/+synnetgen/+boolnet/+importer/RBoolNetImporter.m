%Imprts network from R BoolNet format
%(http://cran.r-project.org/package=BoolNet).
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef RBoolNetImporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'R-BoolNet'
        description = 'R BoolNet importer'
        inputs = struct(...            
            'filename', 'File name' ...
            )
        outputs = struct (...
            'boolnet', 'Boolean network'...
            )
    end
    
    methods (Static)
        function boolnet = run(boolnet, varargin)
            %% parse arguments
            validateattributes(boolnet, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
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
            
            line = fgetl(fid);
            line = strsplit(line, ',');
            if numel(line) ~= 2 || ~strcmp(line{1}, 'targets') || ~strcmp(util.trim(line{2}), 'factors')
                throw(MException('SynNgetGen:InvalidFile', 'File not in R BoolNet format: invalid header'))
            end
            
            nodes = repmat(struct('id', [], 'label', []), 0, 1);
            rules = cell(0, 1);
            while ~feof(fid)
                line = fgetl(fid);                
                if isempty(line)
                    throw(MException('SynNgetGen:InvalidFile', 'File not in R BoolNet format: lines cannot be empty'))
                end
                
                if line(1) == '#'
                    continue;
                end
                
                idRule = strsplit(line, ',');
                if numel(idRule) ~= 2
                    throw(MException('SynNgetGen:InvalidFile', 'File not in R BoolNet format: invalid rule'))
                end
                
                nodes = [nodes
                    struct('id', idRule{1}, 'label', idRule{1})
                    ];
                rules = [
                    rules
                    util.trim(idRule(2))
                    ];
            end
            fclose(fid);
            
            boolnet.setNodesAndRules(nodes, rules);
        end
    end
end