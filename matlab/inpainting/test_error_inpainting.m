clear all
close all
addpath('../src/AddTextToImage');
addpath('../src/ipsum');
% Image names : 
%       ./src/lena.gif
%       ./src/baboon.gif
% Loading the image.
[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);
colormap(cmap)
image(A_orig);

%% Create some distorsion.

distorsion='text';
mask = zeros(size(A));

switch distorsion
    case 'random'
        p = 0.9;
        mask = rand(size(A));
        mask(mask<p)=1;
        mask(mask~=1)=0;
    case 'block'
        n = 16;
        for i=1:7
            for j=1:7
                mask(64*i-n:64*i,64*j-n:64*j) =1;
            end
        end
    case 'text'
        text = ones(size(A));
        ipsum = matlab_ipsum;
        mask = ones(size(A));
        [h,w] =size(A);
        i=1;
        while (30*i<h)
            text = AddTextToImage(text,ipsum(1+40*(i-1):40*i),[30*(i-1),10]);
            text(text~=1)=0;
            mask = mask.*text;
            i=i+1;
        end
        text(text~=1)=0;
        mask = 1-text;
end 

A_dist = A.*(1-mask);

%image(A_dist)

%% Plotting image + distorsion
close all
colormap(cmap)
image(A_dist);

%% %% inpainting 

mode = 'per';       % 'per' or 'sym'
maxit = 50;
thres = {'soft','hard'};     % 'soft', 'hard' or 'smooth'
wname = {'db5'};    % Type of wavelet: bior4.4,haar,db1,db2
delta = 10.^linspace(-2,4,30); % delta's
Nb_levels = 10;     % Nb of resolution levels.


[paintings,rel_err,err_damaged] = err_plot_inpainting(mode, thres, maxit, delta, wname, ...
                        Nb_levels, A, A_dist, mask);

%% plot

% make plot
legendInfo = cell(length(thres),1);
counter = 1;
figure
hold on
%set(gca,'YScale','log');
set(gca,'XScale','log');
for i = 1:length(wname)
    for j = 1:length(thres)
        plot(delta, rel_err(:,j,i),'LineWidth',1.5)
        legendInfo(counter) = strcat(wname{i}, ', ', thres(j), ', n=' ,num2str(Nb_levels));
        counter = counter + 1;
    end
end
%plot(delta(1), err_noise,'*','MarkerSize',5)
xlabel('threshold parameter \delta', 'Fontsize', 18);
ylabel('relative error (Frobenius)', 'Fontsize', 18);
title('norm(A\_inpainted - A\_orig) / norm(A\_orig)')
%axis([0 xmax ymin 1])
set(gca,'FontSize',15)
legend(legendInfo, 'Location','southwest','Fontsize', 18)
hold off

%% 

% colormap(cmap)
% image(A_dist);
% 
% colormap(cmap)
% image(paintings(:,:,15,1,1));
% 
% colormap(cmap)
% image(paintings(:,:,15,2,1));