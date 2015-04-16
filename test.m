%Tests SynNetGen software
%
%@author  Jonathan Karr, karr@mssm.edu
%@date    2015-04-15
function result = test()

suite = matlab.unittest.TestSuite.fromPackage('synnetgen', 'IncludingSubpackages', true);
runner = matlab.unittest.TestRunner.withNoPlugins();
results = runner.run(suite);
if any([results.Failed])
    throw(MException('SynNetGen:InstallFailure', 'Tests did not pass.'));
end

result = true;