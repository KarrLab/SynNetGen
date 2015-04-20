%Base model class
%- Methods
%  - copy
%  - isequal, eq
%  - disp, print, plot
%  - generate: from one of several distributions
%  - import: from one of several file formats
%  - export: to one of several file formats
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef Model < handle
    methods (Static)
        function result = isValidNodeId(id)
            result = ischar(id) && isrow(id) && ~isempty(id) && numel(id) <= 63 && ~isempty(regexpi(id, '^[a-z][a-z0-9_]*$'));
        end
        
        function result = isValidNodeLabel(label)
            result = ischar(label) && isrow(label);
        end
    end
    
    methods (Abstract)
        %clear nodes and edges
        this = clear(this)
        
        %Create copy of model
        that = copy(this)
    end
    
    methods (Abstract)
        %Simulate model
        result = simulate(this, varargin)
    end
    
    methods
        function tf = eq(this, that)
            %Tests if models are equal
            
            tf = isequal(this, that);
        end
    end
    
    methods
        function this = disp(this)
            %Display model in command window
            
            str = this.print();
            for iLine = 1:numel(str)
                fprintf('%s\n', str{iLine});
            end
        end
    end
    
    methods (Abstract)
        %Display model in command window
        str = print(this)
        
        %Generates plot of model
        figHandle = plot(this, varargin)
    end
    
    methods (Abstract)
        %Generates random model using various generators
        result = generate(this, extId, varargin)
        
        %Transforms model using various transforms
        result = transform(this, extId, varargin)
        
        %Converts model using various algorithms
        result = convert(this, extId, varargin)
        
        %Imports model from various file formats
        result = import(this, extId, varargin)
        
        %Exports model to various file formats
        result = export(this, extId, varargin)
    end
end