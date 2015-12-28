function [ B_np1,snr ] = inpainting_fun(A_dist,mask,Nb_levels,threshold,cost,wname,w_mode, maxit,redundant)

% Implementation of the inpainting algorithme based on a wavelet
% transformation.
% INPUTS:
%   - A_dist: Distorted image.
%   - mask: binary matrix that represent the missing pixels with a one.
%   - Nb_levels: (integer) the number of levels in wavelet transform
%   - threshold: A function of one that can take a matrix and return the
%   threshold values of the matrix. eg @(X) softThreshold(X,1);
%   - cost: Costfunction to rate the quality of the image.
%   - w_mode: 'per' or 'sym'
%   - wname: a cell array with different kinds of wavelets
%            e.g. {'haar','db4','db6','db10'}
%   - maxit: maximum itterations of the algorithm
%   - redundant: (optional) If set to one the redundant transformation will
%   be used.
%
% OUTPUTS:
%   - B_np1: The last matrix of the inpainting itteration
%   - snr: The value of the cost function for the last itteration.

dwtmode(w_mode,'nodisp');
if (~exist('redundant','var'))
    redundant=0;
end
% Define the correct transformations.
if (~redundant)
    PsiS = @(f) wavedec2(f,Nb_levels,wname);
    Psi = @(C,S) waverec2(C,S,wname);
else
    PsiS = @(f) deal(swt2(f,Nb_levels,wname),0);
    Psi = @(C,S) iswt2(SWC,wname);
end
B_n=A_dist;
B_np1=B_n;
snr=0;
for n=1:maxit
    disp(n);
    [C,S] = PsiS(B_n);
    C = threshold(C);
    B_np1 = (1-mask).*A_dist+mask.*Psi(C,S);
    B_n=B_np1;
    snr = cost(B_n);
end
end
