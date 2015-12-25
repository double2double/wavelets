%% Wavelets image denoising

%%%%%%%%% START TASK 1.4 %%%%%%%%%%%%%%%
clear
close all
% Image names : 
%       ../src/lena.gif
%       ../src/baboon.gif

[A_orig,cmap] =imread('../src/lena.gif');

sigma = 0.3;

A = double(A_orig);

A_mean = mean(A(:));
A = A-A_mean;
A_var = var(A(:));
A = (A./sqrt(A_var));
rng(1);
An = A + sigma.*randn(size(A));

rb={'rbio1.1', 'rbio1.3',  'rbio1.5','rbio2.2', 'rbio2.4',  'rbio2.6', 'rbio2.8','rbio3.1', 'rbio3.3',  'rbio3.5', 'rbio3.7','rbio3.9', 'rbio4.4','rbio5.5', 'rbio6.' };
br = {'bior1.1', 'bior1.3' , 'bior1.5','bior2.2', 'bior2.4' , 'bior2.6', 'bior2.8','bior3.1', 'bior3.3' , 'bior3.5', 'bior3.7','bior3.9', 'bior4.4' , 'bior5.5', 'bior6.8'};
db={'db2','db3','db4','db5','db6','db7','db8','db9','db10','db11','db12','db13','db14','db15','db16','db17','db18','db19','db20','db21','db22','db23','db24','db25','db26','db27','db28','db29','db30','db31','db32','db33','db34','db35','db36','db37','db38','db39','db40','db41','db42','db43','db44','db45'};
sym={'sym2','sym3','sym4','sym5','sym6','sym7','sym8','sym9','sym10','sym11','sym12','sym13','sym14','sym15','sym16','sym17','sym18','sym19','sym20','sym21','sym22','sym23','sym24','sym25','sym26','sym27','sym28','sym29','sym30','sym31','sym32','sym33','sym34','sym35','sym36','sym37','sym38','sym39','sym40','sym41','sym42','sym43','sym44','sym45'};
cf = {'coif1', 'coif2','coif3','coif4','coif5'};
dm = {'dmey','haar'};
all = {'rbio1.1', 'rbio1.3',  'rbio1.5','rbio2.2', 'rbio2.4',  'rbio2.6', 'rbio2.8','rbio3.1', 'rbio3.3',  'rbio3.5', 'rbio3.7','rbio3.9', 'rbio4.4','rbio5.5', 'rbio6.8','bior1.1', 'bior1.3' , 'bior1.5','bior2.2', 'bior2.4' , 'bior2.6', 'bior2.8','bior3.1', 'bior3.3' , 'bior3.5', 'bior3.7','bior3.9', 'bior4.4' , 'bior5.5','bior6.8','db2','db3','db4','db5','db6','db7','db8','db9','db10','db11','db12','db13','db14','db15','db16','db17','db18','db19','db20','db21','db22','db23','db24','db25','db26','db27','db28','db29','db30','db31','db32','db33','db34','db35','db36','db37','db38','db39','db40','db41','db42','db43','db44','db45','sym2','sym3','sym4','sym5','sym6','sym7','sym8','sym9','sym10','sym11','sym12','sym13','sym14','sym15','sym16','sym17','sym18','sym19','sym20','sym21','sym22','sym23','sym24','sym25','sym26','sym27','sym28','sym29','sym30','sym31','sym32','sym33','sym34','sym35','sym36','sym37','sym38','sym39','sym40','sym41','sym42','sym43','sym44','sym45','coif1', 'coif2','coif3','coif4','coif5','dmey','haar'};

%%
for wname_cell={'bior6.8'}
    
    close all
    wname = char(wname_cell);
    n = 18;
    [C,L] = wavedec2(An,n,wname);
    
    SoftThresh  = @(x,T) x.*max( 0, 1-T./max(abs(x),1e-10) );
    HardThresh  = @(x,T) x .* (abs(x) >= T);
    SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;
    snr_image = @(A,An) 20*log10(norm(A(:))/norm(A(:)-An(:)));

    allThr = linspace(0,2,40);

    allSnr=zeros(3,numel(allThr));

    for i=1:3
        thresH=i;
        for j=1:numel(allThr)
            T=allThr(j);
        switch thresH
            case 1
                threshold = @(C)SoftThresh(C,T);
            case 2
                threshold = @(C)HardThresh(C,T);
            case 3
                threshold = @(C)SmootThresh(C,T);
            otherwise
                error('thresholding kind unknown')
        end
            
            C_tres = threshold(C);
            [A_den] = waverec2(C_tres,L,wname);

            snr = snr_image(A,A_den);
            allSnr(i,j)=snr;
            disp(i);
        end
    end

fig1 = figure('position',[1000 1000 300 200]);
box on
for thresH=1:3
    hold on
    plot(allThr,allSnr(thresH,:))
end
snr = snr_image(A,An);
plot([0,allThr(end)],[snr,snr],'k--');

xlabel('Threshold','interpreter','Latex');
ylabel('Snr','interpreter','Latex');
h=title(['SNR voor ruisreductie met \textit{',wname,'} wavelet'],'interpreter','Latex');
legend('soft','hard','smooth','Ruisig','Location','northeast');

name=['plot/snr_image_',wname,'_',num2str(sigma*100),'.eps'];

exportfig(fig1,name,... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');

% Plot best restul
[x,y]= max(allSnr');
[~,x] = max(x);
y=y(x);

disp(max(allSnr(:)));
disp(allSnr(x,y));
switch x
    case 1
        threshold = @(C)SoftThresh(C,allThr(y));
    case 2
        threshold = @(C)HardThresh(C,allThr(y));
    case 3
        threshold = @(C)SmootThresh(C,allThr(y));
    otherwise
        error('thresholding kind unknown')
end

C_tres = threshold(C);
[A_den] = waverec2(C_tres,L,wname);

A_denIm = uint8(A_den*sqrt(A_var)+A_mean);
A_nIm = uint8(An*sqrt(A_var)+A_mean);

colormap(cmap);
imwrite(A_denIm,['./plot/lenaDen_',wname,'.png']);
colormap(cmap);
imwrite(A_nIm,['./plot/lenaNoise_',wname,'.png']);

end
%%%%%%%%% END TASK 1.4 %%%%%%%%%%%%%%%

%%








