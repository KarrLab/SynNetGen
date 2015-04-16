%Tests ExtensionRunner
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
classdef ExtensionRunnerTest < matlab.unittest.TestCase
    methods (Test)
        function testGetInfo(this)
            %return data
            info = synnetgen.extension.ExtensionRunner.get('synnetgen.graph.exporter', 'dot');
            
            %print
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.exporter', 'dot');
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.exporter', 'gml');
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.exporter', 'graphml');
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.exporter', 'tgf');
            
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.generator', 'barabasi-albert');
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.generator', 'edgar-gilbert');
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.generator', 'erdos-reyni');            
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.generator', 'watts-strogatz');
            
            synnetgen.extension.ExtensionRunner.get('synnetgen.graph.importer', 'tgf');
        end
        
        function testList(this)
            %return data
            info = synnetgen.extension.ExtensionRunner.list('synnetgen.graph.exporter');
            
            %print
            synnetgen.extension.ExtensionRunner.list('synnetgen.graph.exporter');
            synnetgen.extension.ExtensionRunner.list('synnetgen.graph.generator');
            synnetgen.extension.ExtensionRunner.list('synnetgen.graph.importer');
        end
    end
end