
f = ['UDT.txt'];
fid = fopen(f,'r');
L = [];

l = fgetl(fid);
while(l ~= -1)
    s = sscanf(l,'%f');
    L = [L;s'];
    %l = fgetl(fid); %% emtpy line
    l = fgetl(fid);
end

L = [L; L(end)];


dom = 380:2:780;

figure,plot(dom,L)