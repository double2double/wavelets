function y = den_image(A_n,Nb_levels,wname,thresHold,w_mode,redundant)
% Function for denoising of images using a wavelet transformation.
% INPUTS:
%   - A_n: Noisy image
%   - Nb_levels: (integer) the number of levels in wavelet transform
%   - wname: a cell array with different kinds of wavelets
%            e.g. {'haar','db4','db6','db10'}
%   - threshold: A function of one that can take a matrix and return the
%   threshold values of the matrix. eg @(X) softThreshold(X,1);
%   - w_mode: 'per' or 'sym'
%   - redundant: (optional) If set to one the redundant transformation will
%   be used.
%
% OUTPUTS:
%   - y: The denoised image.

dwtmode(w_mode,'nodisp');
if (~exist('redundant','var'))
    redundant=0;
end
if (~redundant)
    [a,b]=wavedec2(A_n,Nb_levels,wname);
    a_T = thresHold(a);
    y = waverec2(a_T,b,wname);
else
    swc = swt2(A_n,Nb_levels,wname);
    y = iswt2(thresHold(swc),wname);
end
end