function [flag dd] = checkforOverwrite

animal = get(findobj('Tag','animaltxt'),'String');
unit   = get(findobj('Tag','unittxt'),'String');
expt   = get(findobj('Tag','expttxt'),'String');
datadir= get(findobj('Tag','datatxt'),'String');

dd = [datadir '\' lower(animal) ];
disp([ 'Folder for data: ' dd ] )

flag = 0;

if(exist(dd))
    disp('Directory exists!!!  Make sure you are not overwritting old data!  Please check current animal, unit and expt values.  I will now abort this sampling request.')
    flag = 1;
end
