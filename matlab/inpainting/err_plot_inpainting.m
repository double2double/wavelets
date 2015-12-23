function [paintings,rel_err,err_damaged] = err_plot_inpainting(mode, thres, maxit, delta, wname, ...
                        Nb_levels, A_orig, A_dist, mask)

% The clear picture A_orig is damaged. The resulting 
% noised picture is A_dist. With different inpainting techniques A_dist is
% painted to hopefully a better picture A_painted. A plot is made of the
% relative Frobenius norm 'norm(A\_painted - A\_orig) / norm(A\_orig)'
% versus the threshold parameter delta.

% INPUTS:
%   - mode: 'per' or 'sym'
%   - thres: a cell array with different kinds of thresholding techniques.
%            e.g. {'soft','hard'} or {'soft','smooth','hard'}
%   - maxit: the number of iterations
%   - delta: a vector containing thresholding parameters delta
%            e.g. 10.^linspace(-2,1,30)
%   - wname: a cell array with different kinds of wavelets
%            e.g. {'haar','db4','db6','db10'}
%   - Nb_levels: (integer) the number of levels in wavelet transform
%   -A_orig: the original picture without any noise added (double matrix format)
%   -A_noise: the noisy picture that we will try to denoise (double matrix format)
%   -mask: corrresponding mask
%
% OUTPUTS:
%   - a figure is created of the relative error vs delta parameter
%   - paintings: 5D tensor with all the painted pictures
%   - rel_err: 3D tensor with dimensions length(delta) x length(thres) x length(wname)
%   - err_damaged: error of damaged picture


dwtmode(mode);    % Boundary conditions: 'sym','per'

% Creating different treshold functions
SoftThresh  = @(x,T) x.*max( 0, 1-T./max(abs(x),1e-10) );
HardThresh  = @(x,T) x .* (abs(x) >= T);
SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;

% init relative error
rel_err = zeros(length(delta),length(thres),length(wname));
% init paintings tensor
paintings = zeros(size(A_orig,1),size(A_orig,2), ...
                    length(delta), length(thres), length(wname));
% frobenius norm of original picture
A_orig_norm = norm(A_orig,'fro');
% relative error of damaged picture
err_damaged =  norm(A_orig - A_dist,'fro') / A_orig_norm; 

% for wname, ...
%   for kind, ...
%       for delta, ...

tic

for i = 1:length(wname) % iterate over all kinds of wavelets
    
    for j = 1:length(thres) % iterate over all kinds of thresholding methods
        
        % define threshold function
        switch thres{j}
            case 'soft'
                threshold = @(C,delta) SoftThresh(C,delta);
            case 'hard'
                threshold = @(C,delta) HardThresh(C,delta);
            case 'smooth'
                threshold = @(C,delta) SmootThresh(C,delta);
            otherwise
                error('thresholding kind unknown')
        end
        
        B_n = A_dist;
        % iterate over threshold parameters
        for k = 1:length(delta)
            for n=1:maxit
                %disp(n);
                [C,S] = wavedec2(B_n,Nb_levels,wname{i});
                C = threshold(C,delta(k));
                B_np1 = (1-mask).*A_dist+mask.*waverec2(C,S,wname{i});
                B_n=B_np1;
                %colormap(cmap)
                %image(B_np1);
                %pause(0.000001)
            end
            toc
            disp(strcat('i=',num2str(i),' j=',num2str(j),' k=',num2str(k)))
            % relative error between inpainted and original signal
            rel_err(k,j,i) = norm(A_orig - B_n,'fro') / A_orig_norm;
            paintings(:,:,k,j,i) = B_n;
        end
    end
end




