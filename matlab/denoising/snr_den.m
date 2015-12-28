function snr = snr_den(X,X_orig,N,wname,thresHold)

y = den_wst2(X,N,wname,thresHold);
snr_image   = @(A,An) -20*log10( norm(A - An,'fro') / norm(A)); 
snr=snr_image(X_orig,y);


end