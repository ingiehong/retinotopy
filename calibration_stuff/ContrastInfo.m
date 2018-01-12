%10 DEGREE CONE FUNDAMENTALS (9/12/10)
%Null Luminance & S ("L+M direction"):  Magnitude of L to M contrast ratio
%made to equal that in the L-M isoluminant case
dLMS = [1 .9 0];  gain = [.5122 1.0 -.1390]; LMScont = [.7376 .7483 0.0]; Totalcont = 1.0508;

%Null Luminance & S ("L-M direction"):  
dLMS = [1 -.9 0];  gain = [1.0 -.3365 -.0049]; LMScont = [.1079 -.1096 0.0]; Totalcont = 0.1538;

%Null Luminance ("S + (L-M)  direction"):  
dLMS = [1 -.9 .55];  gain = [1.0 -.3629 .1338]; LMScont = [.1051 -.1067 0.1091]; Totalcont = 0.1798;

%Null Luminance (" S - (L-M)  direction"):  
dLMS = [-1 .9 .55];  gain = [-1.0 .3086 .1311]; LMScont = [-.1110 .1126 .1152]; Totalcont = 0.1956;

%"L isolation"  %use nullfuncs of lms
dLMS = [1 0 0];  gain = [1 -.1772 -.0143];  LMScont = [.1957 0 0]; Totalcont = 0.1957;

%"M isolation"  %use nullfuncs of lms
dLMS = [0 1 0];  gain = [-1 .5214 -.0273];  LMScont = [0 .2292 0]; Totalcont = 0.2292;

%"S isolation"  %use nullfuncs of lms
dLMS = [0 0 1];  gain = [.2050 -.2738 1.0];  LMScont = [0 0 .8222]; Totalcont = 0.8222;
%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%10 DEGREE CONE FUNDAMENTALS (7/9/10)
%Null Luminance & S ("L+M direction"):  Magnitude of L to M contrast ratio
%made to equal that in the L-M isoluminant case
dLMS = [1 .9 0];  gain = [.5084 1.0 -.1237]; LMScont = [.7387 .7513 0.0]; Totalcont = 1.0536;

%Null Luminance & S ("L-M direction"):  
dLMS = [1 -.9 0];  gain = [1.0 -.3394 -.0102]; LMScont = [.1089 -.1126 0.0]; Totalcont = 0.1567;

%"L isolation"  %use nullfuncs of lms
dLMS = [1 0 0];  gain = [1 -.1774 -.0076];  LMScont = [.2052 0 0]; Totalcont = 0.2052;

%"M isolation"  %use nullfuncs of lms
dLMS = [0 1 0];  gain = [-1 .5278 -.0309];  LMScont = [0 .2432 0]; Totalcont = 0.2432;

%"S isolation"  %use nullfuncs of lms
dLMS = [0 0 1];  gain = [.2106 -.2724 1.0];  LMScont = [0 0 .8584]; Totalcont = 0.8584;


%%%These were not updated because we weren't using them
%Null Luminance ("S + (L-M)  direction"):  
dLMS = [1 -.9 .55];  gain = [1.0 -.3629 .1338]; LMScont = [.1051 -.1067 0.1091]; Totalcont = 0.1798;

%Null Luminance (" S - (L-M)  direction"):  
dLMS = [-1 .9 .55];  gain = [-1.0 .3086 .1311]; LMScont = [-.1110 .1126 .1152]; Totalcont = 0.1956;

%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
