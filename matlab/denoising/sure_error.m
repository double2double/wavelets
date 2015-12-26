function rel_err = sure_error(mode, thres, delta, wname, Nb_levels, sigma, A_noise,plotYN)

% The original picture A_orig is contaminated with noise. The resulting
% noised picture is A_noise. With different denoising techniques A_noise is
% filtered to hopefully a better picture A_denoised. A plot is made of the
% relative Frobenius norm 'norm(A\_denoised - A\_orig) / norm(A\_orig)'
% versus the threshold parameter delta.

% INPUTS:
%   - mode: 'per' or 'sym'
%   - thres: a cell array with different kinds of thresholding techniques.
%            e.g. {'soft','hard'} or {'soft','smooth','hard'}
%   - delta: a vector containing thresholding parameters delta
%            e.g. 10.^linspace(-2,1,30)
%   - wname: a cell array with different kinds of wavelets
%            e.g. {'haar','db4','db6','db10'}
%   - Nb_levels: (integer) the number of levels in wavelet transform
%   -A_orig: the original picture without any noise added (double matrix format)
%   -A_noise: the noisy picture that we will try to denoise (double matrix format)
%   -plotYN: (optional) If set to one, the function will generate plots.
%
% OUTPUTS:
%   - a figure is created of the relative error vs delta parameter
%   - rel_err: a tensor containing all the erros (not usefull)

if ~exist('plotYN','var')
  plotYN=0;
end

if plotYN
    dwtmode(mode);    % Boundary conditions: 'sym','per'
else
    dwtmode(mode,'nodisp');
end

% Creating different treshold functions
SoftThresh  = @(x,T) x.*max( 0, 1-T./max(abs(x),1e-10) );
HardThresh  = @(x,T) x .* (abs(x) >= T);
SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;
snr_image   = @(A,An) -20*log10( norm(A - An,'fro') / norm(A)); 
% init relative error 
rel_err = zeros(length(delta),length(thres),length(wname));



% for wname, ...
%   for kind, ...
%       for delta, ...

for i = 1:length(wname) % iterate over all kinds of wavelets
    
    % wavelet transform
    [C_orig,S] = wavedec2(A_noise,Nb_levels,wname{i});
    
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
        
        % iterate over threshold parameters
        for k = 1:length(delta)
            % the first wavelet transform is moved outside for loop
            % thresholding
            C_thres = threshold(C_orig,delta(k));
            % inverse wavelet transform
            [A] = waverec2(C_thres,S,wname{i});
            % relative error between denoised and original signal
            N  = numel(A(:));
            N1 = sum(abs(C_thres)>delta);
            rel_err(k,j,i) = 1/N*(norm(A(:)-A_noise(:))^2)+200*sigma*N1/N-sigma;
        end
    end
end

if (plotYN)
    % make plot
    legendInfo = cell(length(thres),1);
    counter = 1;
    figure
    hold on
    
    for i = 1:length(wname)
        for j = 1:length(thres)
            plot(delta, rel_err(:,j,i),'LineWidth',1.5)
            legendInfo(counter) = strcat(wname{i}, ', ', thres(j), ', n=' ,num2str(Nb_levels));
            counter = counter + 1;
        end
    end
    plot(delta(1), err_noise,'LineWidth',1.5)
    xlabel('threshold parameter \delta', 'Fontsize', 18);
    ylabel('relative error (Frobenius)', 'Fontsize', 18);
    title('norm(A\_denoised - A\_orig) / norm(A\_orig)')
    
    set(gca,'FontSize',15)
    legend(legendInfo, 'Location','northeast','Fontsize', 20)
    hold off
end


