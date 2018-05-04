function saveOnlineAnalysis

global F1 GUIhandles

if get(GUIhandles.main.analysisFlag,'value')

    f1m = F1;

    A = get(GUIhandles.main.animal,'string');
%    A = 'A71';
    U = get(GUIhandles.main.unitcb,'string');
%    U ='000';
    E = get(GUIhandles.main.exptcb,'string');
%    E= '001';
    UE = [U '_' E];
%    path = 'C:\neurodata\Processed Data\';
    path='C:\Users\Ingie\Documents\ISI_Data\ProcessedData\';
    filename = strcat(path,A,'_',UE);
    %save(filename,'F1')
    uisave('f1m',filename)

end