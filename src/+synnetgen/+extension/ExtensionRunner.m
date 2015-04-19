%Runs extensions of class synnetgen.Extension
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-16
classdef ExtensionRunner < handle
    methods (Static)
        function extensions = list(pkgId)
            %Lists extensions in package pkgId
            
            %find extensions
            validateattributes(pkgId, {'char'}, {'nonempty', 'row'});
            extensions = repmat(struct('id', [], 'description', [], 'class', [], 'inputs', [], 'outputs', []), 0, 1);
            pkg = meta.package.fromName(pkgId);
            if isempty(pkg)
                throw(MException('SynNetGen:InvalidArgument', 'Package does not exist'))
            end
                
            for iClass = 1:numel(pkg.ClassList)
                if any(ismember('synnetgen.extension.Extension', {pkg.ClassList(iClass).SuperclassList.Name}))
                    iProp = find(strcmp('id', {pkg.ClassList(iClass).PropertyList.Name}), 1, 'first');
                    extId = pkg.ClassList(iClass).PropertyList(iProp).DefaultValue;
                    
                    extensions = [
                        extensions
                        synnetgen.extension.ExtensionRunner.get(pkgId, extId)
                        ];
                end
            end
            
            %print
            if nargout > 0
                return;
            end            
            
            maxIdLen = max(cellfun(@numel, {extensions.id}));
            
            fprintf('%s extensions\n', pkgId);
            for iExt = 1:numel(extensions)
                fprintf(['  %' num2str(maxIdLen) 's: %s\n'], extensions(iExt).id, extensions(iExt).description);
            end
        end
        
        function info = get(pkgId, extId)
            %Returns information about extension extId in package pkgId
            
            %find extension
            validateattributes(pkgId, {'char'}, {'nonempty', 'row'});
            validateattributes(extId, {'char'}, {'nonempty', 'row'});
            
            extClass = [];
            pkg = meta.package.fromName(pkgId);
            if isempty(pkg)
                throw(MException('SynNetGen:InvalidArgument', 'Package does not exist'))
            end
            
            for iClass = 1:numel(pkg.ClassList)
                if any(ismember('synnetgen.extension.Extension', {pkg.ClassList(iClass).SuperclassList.Name}))
                    iProp = find(strcmp('id', {pkg.ClassList(iClass).PropertyList.Name}), 1, 'first');
                    if strcmpi(extId, pkg.ClassList(iClass).PropertyList(iProp).DefaultValue)
                        if ~isempty(extClass)
                            throw(MException('SynNetGen:ExtensionIdNotUnique', 'Extension ids must be unique'));
                        end
                        extClass = pkg.ClassList(iClass);
                    end
                end
            end
            
            if isempty(extClass)
                throw(MException('SynNetGen:UnsupportedExtension', 'Unsupported extension'));
            end
            
            %collect information
            iProp = find(strcmp('description', {extClass.PropertyList.Name}), 1, 'first');
            desc = extClass.PropertyList(iProp).DefaultValue;
            
            iProp = find(strcmp('inputs', {extClass.PropertyList.Name}), 1, 'first');
            inputs = extClass.PropertyList(iProp).DefaultValue;
            
            iProp = find(strcmp('outputs', {extClass.PropertyList.Name}), 1, 'first');
            outputs = extClass.PropertyList(iProp).DefaultValue;
            
            info = struct(...
                'id', extId, ...
                'description', desc, ...
                'class', extClass, ...
                'inputs', inputs, ...
                'outputs', outputs);
            
            %print
            if nargout > 0
                return;
            end
            
            maxIdLen = max(cellfun(@numel, [
                fieldnames(info.inputs)
                fieldnames(info.outputs)
                ]));
            
            fprintf('%s\n', info.description);
            fprintf('  Class: %s\n', info.class.Name);
            
            fprintf('  Inputs:\n');
            argIds = fieldnames(info.inputs);
            for iArg = 1:numel(argIds)
                fprintf(['    %' num2str(maxIdLen) 's: %s\n'], argIds{iArg}, info.inputs.(argIds{iArg}));
            end
            
            fprintf('  Outputs:\n');
            argIds = fieldnames(info.outputs);
            for iArg = 1:numel(argIds)
                fprintf(['    %' num2str(maxIdLen) 's: %s\n'], argIds{iArg}, info.outputs.(argIds{iArg}));
            end
        end
        
        function result = run(pkgId, extId, varargin)
            %Runs extension with id extId in package pkgId with
            %arguments varargin{:}.
            
            %find extension
            validateattributes(pkgId, {'char'}, {'nonempty', 'row'});
            validateattributes(extId, {'char'}, {'nonempty', 'row'});
            
            extClass = [];
            pkg = meta.package.fromName(pkgId);
            for iClass = 1:numel(pkg.ClassList)
                if any(ismember('synnetgen.extension.Extension', {pkg.ClassList(iClass).SuperclassList.Name}))
                    iProp = find(strcmp('id', {pkg.ClassList(iClass).PropertyList.Name}), 1, 'first');
                    if strcmpi(extId, pkg.ClassList(iClass).PropertyList(iProp).DefaultValue)
                        if ~isempty(extClass)
                            throw(MException('SynNetGen:ExtensionIdNotUnique', 'Extension ids must be unique'));
                        end
                        extClass = pkg.ClassList(iClass);
                    end
                end
            end
            
            if isempty(extClass)
                throw(MException('SynNetGen:UnsupportedExtension', 'Unsupported extension'));
            end
            
            %run extension
            runFunc = str2func([extClass.Name '.run']);
            result = runFunc(varargin{:});
        end
    end
end