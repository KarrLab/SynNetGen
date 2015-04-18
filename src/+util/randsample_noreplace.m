%Random sampling without replacement of k of n objects with weights w.
%
%@author  http://stackoverflow.com/questions/8205443/weighted-sampling-without-replacement
%@date    2015-04-18
function I = randsample_noreplace(n, k, w)
I = [];
while numel(I) < k
    I = unique([
        I
        randsample(n, k - numel(I), true, w);
        ]);
end