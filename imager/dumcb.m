function dumcb(obj,event)

global handles

n=get(handles.masterlink,'BytesAvailable')
if n > 0
    inString = fread(handles.masterlink,n);
    inString = char(inString');
else
    return
end

inString

inString = inString(1:end-1); 