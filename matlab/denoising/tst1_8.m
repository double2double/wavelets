clear
% Example
s = double(imread('../src/lena.gif'));
x = s + 20*randn(size(s));
T = 35;
J=4;
wname='haar';
y = denS2D(x,T,J,wname)
imagesc(y)
colormap(gray)
axis image
