function saveOnlineAnalysis

global F1 GUIhandles

if get(GUIhandles.main.analysisFlag,'value')

    f1m = F1;

    animal = get(findobj('Tag','animaltxt'),'String');
    unit   = get(findobj('Tag','unittxt'),'String');
    expt   = get(findobj('Tag','expttxt'),'String');
    datadir= get(findobj('Tag','datatxt'),'String');
    tag    = get(findobj('Tag','tagtxt'),'String');

    %dd = [datadir '\' lower(animal) '\' animal '_u' unit '_' expt];
    dd = [datadir '\' lower(animal) ];

    fname = sprintf('%s\\%s_u%s_%s',dd,animal,unit,expt);
    %fname = [fname  '_' sprintf('%03d',trial)];
    save(fname,'F1')

%     A = get(GUIhandles.main.animal,'string');
% %    A = 'A71';
%     U = get(GUIhandles.main.unitcb,'string');
% %    U ='000';
%     E = get(GUIhandles.main.exptcb,'string');
% %    E= '001';
%     UE = [U '_' E];
% %    path = 'C:\neurodata\Processed Data\';
%     path='C:\Users\Ingie\Documents\ISI_Data\ProcessedData\';
%     filename = strcat(path,A,'_',UE);
%     %save(filename,'F1')
%     uisave('f1m',filename)

end