function beta = getContrastforLooper(cont,colormodvec)

%outputs the coefficients for the "formula" to equate cone contrast
%e.g.  contrast = (beta(3)*colormod^2 beta(2)*colormod + beta(1))*100


%%L-M vs. L+M stimulus

%cont(1) = 0.1588; %L-M contrast
%cont(2) = 0.6131; %L+M contrast

%colormodvec = [5 6];

mic = min(cont);
h = [];
for i = 1:length(cont)
    y(i) = mic/cont(i);  %output is desired gain value
    
    h = [h colormodvec(:).^(i-1)];  %input is colorspace
end


beta = inv(h'*h)*h'*y(:); 

contrasts = h*beta

