%http://stackoverflow.com/questions/8205443/weighted-sampling-without-replacement
function I = randsample_noreplace(n, k, w)
I = [];
while numel(I) < k
    I = unique([
        I
        randsample(n, k - numel(I), true, w);
        ]);
end