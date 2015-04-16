%Extension base class
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-16
classdef Extension < handle
    properties (Abstract, Constant)
        id
        description
        inputs
        outputs
    end
    
    methods (Abstract, Static)
        result = run(varargin)
    end
end