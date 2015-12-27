function y = den_wst2(X,N,wname,thresHold)
swc = swt2(X,N,wname);
y = iswt2(thresHold(swc),wname);
end