function shutterCntrl(cond)

Nparams = length(looperInfo.conds{cond}.symbol);
for i = 1:Nparams    
    psymbol = looperInfo.conds{cond}.symbol{i};
    if strcmp(psymbol,'Leye_bit')    	
        pval = looperInfo.conds{cond}.val{i};
    else
        strcmp
    end
end