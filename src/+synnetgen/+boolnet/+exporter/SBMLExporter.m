%Exports network to SBML using qual package
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-18
classdef SBMLExporter < synnetgen.extension.Extension
    properties (Constant)
        id = 'sbml'
        description = 'SBML exporter'
        inputs = struct(...            
            'filename', 'File name' ...
            )
        outputs = struct (...
            'boolnet', 'Boolean network'...
            )
    end
    
    methods (Static)
        function status = run(boolnet, varargin)
            %% parse arguments
            validateattributes(boolnet, {'synnetgen.boolnet.BoolNet'}, {'scalar'});
            
            ip = inputParser;
            ip.addParameter('filename', []);
            ip.parse(varargin{:});
            filename = ip.Results.filename;
            
            if isempty(filename)
                throw(MException('SynNetGen:InvalidArgument', 'filename must be defined'));
            end
            
            %% export
            model = struct();
            model.typecode = 'SBML_MODEL';
            model.metaid = '';
            model.notes = '';
            model.annotation = '';            
            model.SBML_level = 3;
            model.SBML_version = 1;
            model.name = '';
            model.id = 'G';
            model.timeUnits = '';
            model.substanceUnits = '';
            model.volumeUnits = '';
            model.areaUnits = '';
            model.lengthUnits = '';
            model.extentUnits = '';
            model.conversionFactor = '';
            model.sboTerm = -1;
            model.functionDefinition = [];
            model.unitDefinition = [];
            model.species = [];
            model.parameter = [];
            model.initialAssignment = [];
            model.rule = [];
            model.constraint = [];
            model.reaction = [];
            model.event = [];
            model.time_symbol = [];
            model.delay_symbol = [];
            model.avogadro_symbol = [];
            model.namespaces = [
                struct('prefix', '', 'uri', 'http://www.sbml.org/sbml/level3/version1/core')
                struct('prefix', 'qual', 'uri', 'http://www.sbml.org/sbml/level3/version1/qual/version1')
                ];
            
            defaultComp = struct();
            defaultComp.typecode = 'SBML_COMPARTMENT';
            defaultComp.metaid = '';
            defaultComp.notes = '';
            defaultComp.annotation = '';
            defaultComp.sboTerm = -1;
            defaultComp.name = '';
            defaultComp.id = 'default';
            defaultComp.spatialDimensions = NaN;
            defaultComp.size = NaN;
            defaultComp.units = '';
            defaultComp.constant = 1;
            defaultComp.isSetSize = 0;
            defaultComp.isSetSpatialDimensions = 0;
            defaultComp.level = 3;
            defaultComp.version = 1;
            model.compartment = defaultComp;
            
            model.qualitativeSpecies = [];
            model.transition = [];
            for iNode = 1:numel(boolnet.nodes)
                %node
                qual = struct(...
                    'typecode', 'SBML_QUAL', ...
                    'compartment', defaultComp, ...
                    'constant', false, ...
                    'id', boolnet.nodes(iNode).id, ...
                    'name', boolnet.nodes(iNode).label, ...
                    'maxLevel', 1 ...
                    );
                model.qualitativeSpecies = [
                    model.qualitativeSpecies
                    qual
                    ];
                
                %rule
                transition = struct();
                transition.typecode, 'SBML_QUAL_TRANSITION';
                transition.id = sprintf('rule_%s', boolnet.nodes(iNode).id);
                transition.name = '';
                
                transition.input = [];
                [~, edges] = boolnet.getTruthTable(boolnet.nodes(iNode).id);
                iFrom = find(edges);
                for j = 1:numel(iFrom)
                    input = struct(...
                        'typecode', 'SBML_QUAL_INPUT', ...
                        'qualitativeSpecies', boolnet.nodes(iFrom(j)).id, ...
                        'transitionEffect', 'none');
                    transition.input = [
                        transition.input
                        input
                        ];
                end
                
                transition.output = struct(...
                    'typecode', 'SBML_QUAL_OUTPUT', ...
                    'qualitativeSpecies', boolnet.nodes(iNode).id, ...
                    'transitionEffect', 'assignmentLevel');
                
                transition.functionTerm = [
                    struct(...
                        'typecode', 'SBML_QUAL_FUNCTIONTERM', ...
                        'resultLevel', 1, ...
                        'math', boolnet.rules{iNode} ...
                        )
                    struct(...
                        'typcode', 'SBML_QUAL_DEFAULTTERM', ...
                        'resultLevel', 0 ...
                        )
                    ];
                
                model.transition = [
                    model.transition
                    transition
                    ];
            end
            
            OutputSBML(model, filename);
            
            status = true;
        end
    end
end