function varargout = imager(varargin)
% IMAGER M-file for imager.fig
%      IMAGER, by itself, creates a new IMAGER or raises the existing
%      singleton*.
%
%      H = IMAGER returns the handle to a new IMAGER or the handle to
%      the existing singleton*.
%
%      IMAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGER.M with the given input arguments.
%
%      IMAGER('Property','Value',...) creates a new IMAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before imager_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to imager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help imager

% Last Modified by GUIDE v2.5 15-Dec-2005 12:19:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imager_OpeningFcn, ...
    'gui_OutputFcn',  @imager_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before imager is made visible.
function imager_OpeningFcn(hObject, eventdata, handles, varargin)

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imager (see VARARGIN)

%% Create

global IMGSIZE FPS;

FPS = 10;  %% frames per second

%%  serial communication...

delete(instrfind);  %% Delete them ALL!!!!

% The smarthome X10 link

% sx10 = serial('COM27','Tag','x10');
% fopen(sx10);
% handles.sx10 = sx10;

% smarthome('camera',1);
% smarthome('motor',1);
% 
% disp('Please wait ...  Powering up the camera and motor.');
% pause(10);

%%serial link for the camera
delete(instrfind ('Tag','clser'));  %% just in case it crashed
scl = serial('COM3','Tag','clser','Terminator','CR',...
    'DataTerminalReady','on','RequestToSend','on','bytesavailablefcnmode','byte');
fopen(scl);
handles.scl = scl;

%%sit = serial('COM2','Tag','ilser','Terminator','CR','DataTerminalReady',...
%%    'off','RequestToSend','off');

%% This now uses the internet RTS-8 serial server (port0)

%%%illuminator serial 
sit = serial('COM5','Tag','ilser','Terminator','CR','DataTerminalReady',...
    'off','RequestToSend','off');
fopen(sit);
handles.sit = sit;


%% Set camera mode

y = clsend('sem 7');
y = clsend(sprintf('ssf %d',round(FPS)));
y = clsend('sbm 2 2');

%% Set up the parallel port output

global parport;

%% Originally we used the parallel port...
%
parport = digitalio('parallel','LPT1');
set(parport,'Tag','plp');
addline(parport,0,0,'out');

%%

%% ...but now we are using the NI-PCI-6014

% 
% parport = digitalio('nidaq',1);
% set(parport,'Tag','plp');
% addline(parport,0,'out');
% 
putvalue(parport,0);  %% make sure it is zero to begin with

%%% But now we are using the audio output!!!!

handles.blip = audioplayer(10*sin(linspace(0,2*pi,32)),30000);

%% Rename

handles.milapp  = handles.activex25;
handles.mildig  = handles.activex24;
handles.mildisp = handles.activex23;
handles.milimg  = handles.activex26;
handles.milsys  = handles.activex27;

handles.milsys.Allocate;  %% Allocate Mil system

%% I can't get the interrupt to work!

% params = zeros(1,3,'uint64');
% params(1) = 128;
% params(2) = 128;
% params(3) = 0;
%
% set(get(get(handles.milsys,'UserBits'),'Item',8),'InterruptEnabled',1)
% set(get(get(handles.milsys,'UserBits'),'Item',8),'Mode',1);
% set(get(get(handles.milsys,'UserBits'),'Item',8),'InterruptEnabled',1);
%
% invoke(handles.milsys.UserBits,'SetModeMask',params(1),para ms(3));           %% change mode to 'input'
% invoke(handles.milsys.UserBits,'SetInterruptModeMask',params(1),params(2));  %% edge falling
% invoke(handles.milsys.UserBits,'EnableInterruptMask',params(1),params(2))
% ;   %% enable interrupt
% handles.milsys.set('UserBitChangedEvent',1);  %% Allow calls to the event handler

handles.mildisp.set('OwnerSystem',handles.milsys,...
    'DisplayType','dispActiveMILWindow');
handles.mildisp.Allocate

handles.mildig.set('OwnerSystem',handles.milsys,'GrabFrameEndEvent',0,...
    'GrabFrameStartEvent',0,'GrabStartEvent',0,'GrabEndEvent',0,...
    'GrabMode','digAsynchronousQueue');

% From mil.h
% #define M_ARM_CONTINUOUS                              9L
% #define M_ARM_MONOSHOT                                10L
% #define M_ARM_RESET                                   11L
% #define M_EDGE_RISING                                 12L
% #define M_EDGE_FALLING                                13L
% #define M_HARDWARE_PORT4                              31L
% #define M_HARDWARE_PORT5                              32L
% #define M_HARDWARE_PORT6                              33L
% #define M_HARDWARE_PORT7                              34L
% #define M_HARDWARE_PORT8                              35L
% #define M_HARDWARE_PORT9                              36L


%%handles.mildig.registerevent(@dighandler);  %% event handler for all digitizer events...
%%This was too slow!

%% triggering - I will start/stop sampling async mode.
%% The parallel port will spit out pulses sampled by Cerebus
%% set(handles.mildig,'TriggerSource',35,'TriggerMode',13,'TriggerEnabled',0);
%% handles.mildig.set('UserInFormat','digTTL');


%%%% MY code...
handles.mildig.set('Format','C:\imager\2x2bin_dlr.dcf');  %Set the binning to 2x2
y = clsend('sbm 2 2');
%set(handles.binning,'enable','off')

handles.mildig.Allocate;

IMGSIZE = handles.mildig.get('SizeX');  %% get the size


handles.milimg.set('CanGrab',1,'CanDisplay',1,'CanProcess',0, ...
    'SizeX',IMGSIZE,'SizeY',IMGSIZE,'DataDepth',16,'NumberOfBands',1, ...
    'OwnerSystem',handles.milsys);

handles.milimg.Allocate;

handles.mildig.set('Image',handles.milimg);
handles.mildisp.set('Image',handles.milimg,'ViewMode',...
    'dispBitShift','ViewBitShift',4);

%% the buffers...

global NBUF;

NBUF = 2;  %%  buffer...

for(i=1:NBUF)
    handles.buf{i} = actxcontrol('MIL.Image',[0 0 1 1]);
    handles.buf{i}.set('CanGrab',1,'CanDisplay',0,'CanProcess',0, ...
        'SizeX',IMGSIZE,'SizeY',IMGSIZE,'DataDepth',16,'NumberOfBands',1, ...
        'FileFormat','imRaw','OwnerSystem',handles.milsys);
    
        %% The child images

        
        handles.child{i} = actxcontrol('MIL.Image',[0 0 1 1]);
      
        set(handles.child{i},'ParentImage',handles.buf{i},'AutomaticAllocation',1);
        set(handles.child{i}.ChildRegion,'OffsetX',256);
        set(handles.child{i}.ChildRegion,'OffsetY',256);
        set(handles.child{i}.ChildRegion,'SizeX',128);
        set(handles.child{i}.ChildRegion,'SizeY',128);

        handles.buf{i}.Allocate;
        %%handles.child{i}.Allocate;
end

%% Now construct a timer

handles.timer = timer;
set(handles.timer,'Period',0.5,'BusyMode','drop','ExecutionMode',...
    'fixedSpacing','TimerFcn',@timerhandler)

%% Now the data directory, file name, and time tag

handles.datatxt = 'c:\imager_data\xx0';
handles.unit = 'u000_000';
handles.time_tag = 0;


%% Now the udp object
global handles

Masterport = 'COM4';
port = instrfind('Port',Masterport);
if length(port) > 0 
    fclose(port)
    delete(port)
    clear port
end
handles.masterlink = serial(Masterport);
handles.masterlink.BytesAvailableFcnMode = 'Terminator';
handles.masterlink.Terminator = 'CR';
fopen(handles.masterlink);
handles.masterlink.BytesAvailableFcn = @udpcb;



% delete(instrfind('Tag','imagerudp'));
% handles.udp = udp('','LocalPort',2020,'Tag','imagerudp');  %% listen on 2020
% set(handles.udp,'BytesAvailableFcnCount',2,'BytesAvailableFcn',@udpcb);
% fopen(handles.udp);

global imagerhandles;

imagerhandles = handles;  %% we need this for the timerfcn callback
imagerhandles.roi = [256 256];
imagerhandles.roisize = 100;

imagerhandles.hwroi = [256 256];  %% Center of the image data region of interest (assumes 2x2 binning)
imagerhandles.hwroisize = 128;

% Choose default command line output for imager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imager wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = imager_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Grab.
function Grab_Callback(hObject, eventdata, handles)
% hObject    handle to Grab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Grab


if(get(hObject,'Value'))
    start(handles.timer);
    %%handles.mildig.GrabContinuous;
else
    %%handles.mildig.Halt;
    stop(handles.timer);
end


% --- Executes on slider movement.
function pany_Callback(hObject, eventdata, handles)
% hObject    handle to pany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

px = get(handles.panx,'Value');
py = get(handles.pany,'Value');
handles.mildisp.Pan(px,-py);

% --- Executes during object creation, after setting all properties.
function pany_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function panx_Callback(hObject, eventdata, handles)
% hObject    handle to panx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

px = get(handles.panx,'Value');
py = get(handles.pany,'Value');
handles.mildisp.Pan(px,-py);


% --- Executes during object creation, after setting all properties.
function panx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',...
        get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function zoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',...
        get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

contents = get(hObject,'String');
z = str2num(contents{get(hObject,'Value')});
handles.mildisp.ZoomX = z;
handles.mildisp.ZoomY = z;

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',...
        get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in histbox.
function histbox_Callback(hObject, eventdata, handles)
% hObject    handle to histbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of histbox


%% We are not using this handler any more...

function dighandler(varargin)
global imagerhandles nframes T;

imagerhandles.mildig.Image = imagerhandles.buf{bitand(nframes,1)+1};  %% switch buffer
T(nframes+1)=invoke(imagerhandles.milapp.Timer,'Read')
nframes = nframes+1
if(nframes>20)
    imagerhandles.mildig.Halt;
    imagerhandles.mildig.set('GrabFrameEndEvent',0);
end



% --- Executes on button press in autoscale.
function autoscale_Callback(hObject, eventdata, handles)
% hObject    handle to autoscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoscale

if(get(hObject,'Value'))
    handles.mildisp.set('ViewMode','dispAutoScale')
else
    handles.mildisp.set('ViewMode','dispBitShift','ViewBitShift',4);
end


function timerhandler(varargin)

global imagerhandles IMGSIZE;

%% get the temperature...

y = clsend('vt');

if(length(y)>10)
    idx = findstr(y,'Celsius');
    t1 = y(idx(1)-5:idx(1)-2);
    t2 = y(idx(2)-5:idx(2)-2);
else 
    t1 = 0;
    t2 = 0;
end

h = imagerhandles;
h.mildig.Grab;

set(h.temptxt,'String',sprintf('Digitizer: %sC  Sensor: %sC',t1,t2));

if(get(h.histbox,'Value'))          %% Analyze?

    jetmap = jet;
    jetmap(end-2:end,:) = 1;
    colormap(jetmap);
    axes(h.jetaxis); cla;
    zz = zeros(IMGSIZE,IMGSIZE,'uint16');
    h.mildig.GrabWait(3);  %% wait...

    % from mil.h
    % #define M_GRAB_NEXT_FRAME                             1L
    % #define M_GRAB_NEXT_FIELD                             2L
    % #define M_GRAB_END                                    3L

    xmin = max(1,ceil(h.roi(1)-h.roisize/2));
    xmax = min(IMGSIZE,floor(h.roi(1)+h.roisize/2));
    ymin = max(1,ceil(h.roi(2)-h.roisize/2));
    ymax = min(IMGSIZE,floor(h.roi(2)+h.roisize/2));
        
    [xx,yy] = meshgrid(xmin:xmax,ymin:ymax);
    I = sub2ind([IMGSIZE IMGSIZE],xx(:),yy(:));
        
    imagerhandles.roiI = I;
    
    img = h.milimg.Get(zz,IMGSIZE^2,-1,0,0,IMGSIZE,IMGSIZE);
    image(double(img)'/4096*64);
    axis ij;
    hold on;
    plot([xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'k-','linewidth',2);
    
    %% Now the image ROI
    

    xmin = max(1,ceil(h.hwroi(1)-h.hwroisize/2));
    xmax = min(IMGSIZE,floor(h.hwroi(1)+h.hwroisize/2));
    ymin = max(1,ceil(h.hwroi(2)-h.hwroisize/2));
    ymax = min(IMGSIZE,floor(h.hwroi(2)+h.hwroisize/2));
            
    plot([xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'c:','linewidth',2);
    
    hold off;
    axis off;

    axes(h.cmapaxes);
    cla;
    colormap(jetmap);
    image(1:64);
    axis off;

    axes(h.histaxes); cla;
    hist(img(I),32:64:4096);
    box off;
    set(gca,'ytick',[],'xtick',[0:1024:4096],'xlim',[0 4096],'fontsize',8);
    
    set(h.focustxt,'String',sprintf('Focus: %.2f',100*focval(img)));

end


%% send to camera over serial com

function y = clsend(str)
scl = instrfind('Tag','clser');
if(~isempty(scl))
    fprintf(scl,'%s\n',str);
    pause(0.05);
    N = get(scl,'BytesAvailable');
    y = [];
    while(N>0)
        y = [y char(fread(scl,N,'char')')];
        pause(0.05);
        N = get(scl,'BytesAvailable');
    end
else
    y = '\n Error>> No message from camera!\n';
end


function y = itsend(str)
sit = instrfind('Tag','ilser');
if(~isempty(sit))
    fwrite(sit,[str 13]);
    pause(0.05);
    N = get(sit,'BytesAvailable');
    if(N>0)
        y = fgetl(sit);
    end
else
    y = '\n Error>> No message from camera!\n';
end

function r = parsepr(y)

tail = y;
[head,tail] = strtok(tail,[10 13]);
r.quality = head;
[head,tail] = strtok(tail,[10 13]);
r.ii = head;
k = 1;
while(length(tail)>0)
    [head,tail] = strtok(tail,[10 13]);
    r.meas{k} = sscanf(head,'%f,%f');
    k = k+1;
end



function y = prmeasure;
spr = instrfind('Tag','prser');
if(~isempty(spr))
    fwrite(spr,['M5' 13]);
    N = get(spr,'BytesAvailable');
    while(spr.BytesAvailable<1734)    %% wait for measurement to end
    end
    y = char(fread(spr,spr.BytesAvailable))';
else
    warning('Problem measuring spectrum with PR instrument');
    y = 'Problem';
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

s = get(hObject,'String');
cmd = s(end,:);  %% get last line
y = clsend(cmd);
s = str2mat(cmd,y);
set(hObject,'String',s);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',...
        get(0,'defaultUicontrolBackgroundColor'));
end


%% Focus value function

function y = focval(q)

global IMGSIZE imagerhandles

x = double(q(imagerhandles.roiI));

y = std(x)/mean(x);  %% coefficient of variation

% 
% delta = round(IMGSIZE/256);
% f = fftshift(abs(fft2(double(q(1:delta:end,1:delta:end))))).^2;  %% power spectrum
% [xx,yy] = meshgrid(-127:128,-127:128);
% mask = (xx.^2+yy.^2)>20^2;
% y = sum(sum((mask.*f)))./sum(sum(f));

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

idx = get(hObject,'Value');
switch(idx)
    case 1,     % stopped
        handles.mildig.Halt;
        stop(handles.timer);
        handles.mildig.set('GrabEndEvent',0,'GrabStartEvent',0);
        handles.mildig.Image = handles.milimg;  %% restore image
        %%set(handles.mildig,'TriggerEnabled',0); %% disable hardware trigger
    case 2,     %grab cont
        handles.mildig.Image = handles.milimg;  %% restore image
        stop(handles.timer);
        handles.mildig.set('GrabEndEvent',0,'GrabStartEvent',0);
        %%set(handles.mildig,'TriggerEnabled',0); %% disable hardware trigger
        handles.mildig.GrabContinuous;
    case 3,    %% adjust illumination
        handles.mildig.Image = handles.milimg;  %% restore image
        handles.mildig.Halt;
        handles.mildig.set('GrabEndEvent',0,'GrabStartEvent',0);
        %%set(handles.mildig,'TriggerEnabled',0); %% disable hardware trigger
        start(handles.timer);
    case 4,
        handles.mildig.Halt;
        stop(handles.timer);
        handles.mildig.set('GrabEndEvent',0,'GrabStartEvent',0);
        handles.milimg.Load('tv.raw',0);
        %%set(handles.mildig,'TriggerEnabled',0); %% disable hardware trigger
end



function udpcb(varargin)

global imagerhandles h;

n = get(imagerhandles.masterlink,'BytesAvailable');
if n > 0
    cmd = char(fread(imagerhandles.masterlink,n));
else
    return
end
cmd = cmd(1:end-1)';  %Get rid of the terminator

% imagerhandles.udp.RemoteHost = imagerhandles.udp.DatagramAddress;
% imagerhandles.udp.RemotePort = imagerhandles.udp.DatagramPort;
% cmd=fscanf(imagerhandles.udp);

switch(cmd(1))
    case 'A'  %% animal
        set(findobj('Tag','animaltxt'),'String',deblank(cmd(3:end)));
        deblank(cmd(3:end))

    case 'E' %% expt      
        set(findobj('Tag','expttxt'),...
            'String',num2str(deblank(cmd(3:end))));

    case 'U'  %% unit
        set(findobj('Tag','unittxt'),...
            'String',num2str(deblank(cmd(3:end))));

%     case 'T'  %% time tag
%         set(findobj('Tag','tagtxt'),...
%             'String',deblank(sprintf('%03d',str2num(cmd(3:end)))));

    case 'M'  %% set mode
        m = str2num(cmd(3:end-1));

    case 'I'  %% total_time
        set(findobj('Tag','timetxt'),'String',deblank(cmd(3:end)));
        preallocateTensor
        fwrite(imagerhandles.masterlink, 'stop')

    case 'S'  %% start sampling...
        
        trial = str2num(cmd(3:end))

        global nframes maxframes ...
            T imagerhandles fname running NBUF parport;

        if(running)
            'Oooops'
        end

        animal = get(findobj('Tag','animaltxt'),'String');
        unit   = get(findobj('Tag','unittxt'),'String');
        expt   = get(findobj('Tag','expttxt'),'String');
        datadir= get(findobj('Tag','datatxt'),'String');
        tag    = get(findobj('Tag','tagtxt'),'String');

        dd = [datadir '\' lower(animal) '\u' unit '_' expt];
        
        if trial == 0
            if(~exist(dd))
                proceed = 1;
                mkdir(dd);
            else
                proceed = 0;
                warndlg('Directory exists!!!  Make sure you are not overwritting old data!  Please check current animal, unit and expt values.  I will now abort this sampling request.','!!! Warning !!!')
            end
        else
            proceed = 1;
        end

        if(proceed)
            
            fname = sprintf('%s\\u%s_%s',dd,unit,expt);
            fname = [fname  '_' sprintf('%03d',trial)]
            
            nframes = 1;

            h = imagerhandles;
            h.mildig.set('GrabFrameEndEvent',0,'GrabEndEvent',...
                0,'GrabStartEvent',0);
            
            set(1,'Name','imager :: Sampling ::');
            drawnow;
            %h.mildig.Image = h.buf{1};

            
            running = 1;

            h = GrabSaveLoop(h,fname,parport);
            fwrite(imagerhandles.masterlink, 'stop') %Let Master know that it is done acq and saving

            set(1,'Name','imager');
            drawnow;
            running = 0;

        end

    case '@'
        global running;
        running = 0;  %% end of stimulus...  stop!
end


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to datatxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datatxt as text
%        str2double(get(hObject,'String')) returns contents of datatxt as a double


% --- Executes during object creation, after setting all properties.
function datatxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datatxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function unittxt_Callback(hObject, eventdata, handles)
% hObject    handle to unittxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of unittxt as text
%        str2double(get(hObject,'String')) returns contents of unittxt as a double


% --- Executes during object creation, after setting all properties.
function unittxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unittxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tagtxt_Callback(hObject, eventdata, handles)
% hObject    handle to tagtxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tagtxt as text
%        str2double(get(hObject,'String')) returns contents of tagtxt as a double


% --- Executes during object creation, after setting all properties.
function tagtxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tagtxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imagerhandles;
dir = uigetdir('','Select data directory');
if(dir~=0)
    imagerhandles.datadir = dir;
    set(findobj('Tag','datatxt'),'String',dir);
end




function expttxt_Callback(hObject, eventdata, handles)
% hObject    handle to expttxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of expttxt as text
%        str2double(get(hObject,'String')) returns contents of expttxt as a double


% --- Executes during object creation, after setting all properties.
function expttxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to expttxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





function animaltxt_Callback(hObject, eventdata, handles)
% hObject    handle to animaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animaltxt as text
%        str2double(get(hObject,'String')) returns contents of animaltxt as a double


% --- Executes during object creation, after setting all properties.
function animaltxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animaltxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function timetxt_Callback(hObject, eventdata, handles)
% hObject    handle to timetxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timetxt as text
%        str2double(get(hObject,'String')) returns contents of timetxt as a double


% --- Executes during object creation, after setting all properties.
function timetxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timetxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function cltext_Callback(hObject, eventdata, handles)
% hObject    handle to cltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cltext as text
%        str2double(get(hObject,'String')) returns contents of cltext as a double

y = clsend(get(hObject,'String'));
set(handles.clreply,'String',y);

% --- Executes during object creation, after setting all properties.
function cltext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% % --------------------------------------------------------------------
% function activex7_GrabFrameEnd(hObject, eventdata, handles)
% % hObject    handle to activex7 (see GCBO)
% % eventdata  structure with parameters passed to COM event listerner
% % handles    structure with handles and user data (see GUIDATA)
% 
% global imagerhandles nframes T maxframes fname running;
% 
% T(nframes)=invoke(imagerhandles.milapp.Timer,'Read');
% imagerhandles.mildig.Image = imagerhandles.buf{bitand(nframes,1)+1};  %% switch buffer
% nframes = nframes+1;
% % %%imagerhandles.buf{bitand(nframes,1)+1}.Save([fname '_' sprintf('%06d',nframes-1) '.raw']);
% % if(nframes>maxframes)
% %     imagerhandles.mildig.Halt;
% %     imagerhandles.mildig.set('GrabFrameEndEvent',0,'GrabEndEvent',0,'GrabStartEvent',0);
% %     set(SEMA,'Visible','off');
% %     running = 0;
% % end
% 
% % imagerhandles.mildig.Image = imagerhandles.buf{bitand(nframes,1)+1};  %% switch buffer
% % T(nframes)=invoke(imagerhandles.milapp.Timer,'Read');
% % nframes = nframes+1;
% %
% % if(nframes>maxframes)
% %     imagerhandles.mildig.Halt;
% %     imagerhandles.mildig.set('GrabFrameEndEvent',0,'GrabFrameStartEvent',0);
% %     imagerhandles.mildig.Image = imagerhandles.milimg;  %% restore image
% %end
% 
% 
% % --------------------------------------------------------------------
% function activex7_GrabFrameStart(hObject, eventdata, handles)
% % hObject    handle to activex7 (see GCBO)
% % eventdata  structure with parameters passed to COM event listerner
% % handles    structure with handles and user data (see GUIDATA)
% global imagerhandles nframes T maxframes;
% disp('GrabFrameStart')
% 
% 
% % --------------------------------------------------------------------
% function activex7_GrabStart(hObject, eventdata, handles)
% % hObject    handle to activex7 (see GCBO)
% % eventdata  structure with parameters passed to COM event listerner
% % handles    structure with handles and user data (see GUIDATA)
% 
% global imagerhandles nframes T maxframes;
% disp('GrabStart');
% 
% 
% % --------------------------------------------------------------------
% function activex7_GrabEnd(hObject, eventdata, handles)
% % hObject    handle to activex7 (see GCBO)
% % eventdata  structure with parameters passed to COM event listerner
% % handles    structure with handles and user data (see GUIDATA)
% 
% %%global imagerhandles nframes T maxframes fname running NBUF;
% % global imagerhandles T nframes;
% % T(nframes)=invoke(imagerhandles.milapp.Timer,'Read');
% 
% global parport;
% 
% putvalue(parport,1);
% putvalue(parport,0);
% 
% %
% % T(nframes)=invoke(imagerhandles.milapp.Timer,'Read');
% % imagerhandles.mildig.Image = imagerhandles.buf{bitand(nframes,1)+1};  %% switch buffer
% % nframes = nframes+1;
% % imagerhandles.buf{bitand(nframes,1)+1}.Save([fname '_' sprintf('%06d',nframes-1) '.raw']);
% 
% % if(nframes<=maxframes)
% %     imagerhandles.mildig.Grab;  %% trigger next grab
% % else
% %     imagerhandles.mildig.set('GrabEndEvent',0,'GrabStartEvent',0);
% %     T = T-T(1);  %% remove absolute time
% %     save([fname '_T.mat'],'T');   %% save the start times
% %     set(findobj('Tag','samplingtxt'),'Visible','off');
% %     running = 0;
% % end
% %
% % %% Stream to disk
% % imagerhandles.buf{bitand(nframes,1)+1}.Save([fname '_' sprintf('%06d',nframes-1) '.raw']);
% 

% --- Executes on selection change in streampop.
function streampop_Callback(hObject, eventdata, handles)
% hObject    handle to streampop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns streampop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from streampop


% --- Executes during object creation, after setting all properties.
function streampop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to streampop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in memorybox.
function memorybox_Callback(hObject, eventdata, handles)
% hObject    handle to memorybox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function framerate_Callback(hObject, eventdata, handles)
% hObject    handle to framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framerate as text
%        str2double(get(hObject,'String')) returns contents of framerate as a double

global FPS

FPS = str2num(get(hObject,'String'));
y = clsend(sprintf('ssf %d',round(FPS)));


% --- Executes during object creation, after setting all properties.
function framerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on selection change in binning.
function binning_Callback(hObject, eventdata, handles)
% hObject    handle to binning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns binning contents as cell array
%        contents{get(hObject,'Value')} returns selected item from binning

global IMGSIZE;

idx = get(hObject,'Value');

set(1,'Name','imager :: PLEASE WAIT! ::'); drawnow;

handles.mildig.Free;

switch(idx)
    case 1,     % 1x1
        handles.mildig.set('Format','C:\imager\1x1bin_dlr.dcf');
        y = clsend('sbm 1 1');
    case 2,     % 2x2
        handles.mildig.set('Format','C:\imager\2x2bin_dlr.dcf');
        y = clsend('sbm 2 2');
    case 3,     % 4x4
        handles.mildig.set('Format','C:\imager\4x4bin_dlr.dcf');
        y = clsend('sbm 4 4');
    case 4,     % 8x8
        handles.mildig.set('Format','C:\imager\8x8bin_dlr.dcf');
        y = clsend('sbm 8 8');
end

handles.mildig.Allocate;  %% allocate
IMGSIZE = handles.mildig.get('SizeX')  %% get the new size

handles.milimg.Free;  %% Free the image and change its size
handles.milimg.set('CanGrab',1,'CanDisplay',1,'CanProcess',0, ...
    'SizeX',IMGSIZE,'SizeY',IMGSIZE,'DataDepth',16,'NumberOfBands',1, ...
    'OwnerSystem',handles.milsys);

handles.milimg.Allocate; %% allocate again...

handles.mildig.set('Image',handles.milimg);
handles.mildisp.set('Image',handles.milimg,'ViewMode','dispBitShift','ViewBitShift',4);

%% Now the buffers...

global NBUF;

for(i=1:NBUF)
    handles.buf{i}.Free;  %% Free the buffer... and change its size
    handles.buf{i}.set('CanGrab',1,'CanDisplay',0,'CanProcess',0, ...
        'SizeX',IMGSIZE,'SizeY',IMGSIZE,'DataDepth',16,'NumberOfBands',1, ...
        'FileFormat','imRaw','OwnerSystem',handles.milsys);
    handles.buf{i}.Allocate;  %% re-allocate
end

set(1,'Name','imager'); drawnow;


% --- Executes during object creation, after setting all properties.
function binning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in adjustlight.
function adjustlight_Callback(hObject, eventdata, handles)
% hObject    handle to adjustlight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Increase light so that histogram within ROI just reaches saturation
%% Focus
%% repeat the above 2-3 times...


% --- Executes on selection change in panelcontrol.
function panelcontrol_Callback(hObject, eventdata, handles)
% hObject    handle to panelcontrol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns panelcontrol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from panelcontrol

switch(get(hObject,'value'))
    case 1
%         
%         setvis(handles.panel1,'on');
%         setvis(handles.panel2,'off');
%         setvis(handles.panel3,'off');
%         setvis(handles.Radiometer,'off');
% %         
% This used to work in R14 SP2 and then stopped working in R14 SP3 that's
% why I wrote the setvis() workaround above...

        set(handles.panel1,'Visible','on');
        set(handles.panel2,'Visible','off');
        set(handles.panel3,'Visible','off');
        set(handles.Radiometer,'Visible','off');
    case 2
%         
%         setvis(handles.panel1,'off');
%         setvis(handles.panel2,'on');
%         setvis(handles.panel3,'off');
%         setvis(handles.Radiometer,'off');
%         
        set(handles.panel1,'Visible','off');
        set(handles.panel2,'Visible','on');
        set(handles.panel3,'Visible','off');
        set(handles.Radiometer,'Visible','off');
    case 3
%         setvis(handles.panel1,'off');
%         setvis(handles.panel2,'off');
%         setvis(handles.panel3,'on');
%         setvis(handles.Radiometer,'off'); 
%         
        set(handles.panel1,'Visible','off');
        set(handles.panel2,'Visible','off');
        set(handles.panel3,'Visible','on');
        set(handles.Radiometer,'Visible','off');
    case 4
        
%         setvis(handles.panel1,'off');
%         setvis(handles.panel2,'off');
%         setvis(handles.panel3,'off');
%         setvis(handles.Radiometer,'on');
        
        set(handles.panel1,'Visible','off');
        set(handles.panel2,'Visible','off');
        set(handles.panel3,'Visible','off');
        set(handles.Radiometer,'Visible','on');
end

% --- Executes during object creation, after setting all properties.
function panelcontrol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panelcontrol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on slider movement.
function setlight_Callback(hObject, eventdata, handles)
% hObject    handle to setlight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = round(get(hObject,'Value'));
itsend(sprintf('DAC=%03d',val));



% --- Executes during object creation, after setting all properties.
function setlight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setlight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in itpower.
function itpower_Callback(hObject, eventdata, handles)
% hObject    handle to itpower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of itpower

val = get(hObject,'Value');
itsend(['SSR=' num2str(val)]);


% --- Executes on button press in ttlpulse.
function ttlpulse_Callback(hObject, eventdata, handles)
% hObject    handle to ttlpulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global parport imagerhandles;

putvalue(parport,1); 
putvalue(parport,0);

%%playblocking(imagerhandles.blip);  %% an audio blip that serves as a sync pulse...



function itime_Callback(hObject, eventdata, handles)
% hObject    handle to itime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of itime as text
%        str2double(get(hObject,'String')) returns contents of itime as a double


% --- Executes during object creation, after setting all properties.
function itime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in prinit.
function prinit_Callback(hObject, eventdata, handles)
% hObject    handle to prinit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

spr = instrfind('Tag','prser');
if(~isempty(spr))
    val = round(str2num(get(findobj('Tag','itime'),'String'))*100);
    fwrite(spr,[sprintf('S,,,,,%d,1,1',val) 13]);
    pause(0.5);
    N = get(spr,'BytesAvailable');
    y = char(fread(spr,spr.BytesAvailable))';
else
    warning('Problem initializing the PR instrument');
    y = 'Problem';
end
y



% --- Executes on button press in prmeasure.
function prmeasure_Callback(hObject, eventdata, handles)
% hObject    handle to prmeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

y = prmeasure;


% --- Executes on button press in grabimage.
function grabimage_Callback(hObject, eventdata, handles)
% hObject    handle to grabimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imagerhandles IMGSIZE;

img = zeros(IMGSIZE,IMGSIZE,'uint16');
zz  = zeros(IMGSIZE,IMGSIZE,'uint16');
img = imagerhandles.milimg.Get(zz,IMGSIZE^2,-1,0,0,IMGSIZE,IMGSIZE)';  %% grab last one

grab.img = img;       %% image
grab.clock = clock;   %% time stamp
figure(10);
imagesc(grab.img),axis off, colormap gray; truesize
r = questdlg('Do you want to save it?','Single Grab','Yes','No','Yes');
if(strcmp(r,'Yes'))
    
    grab.comment = inputdlg('Please enter description:','Image Grab',1,{'No description'},'on');

    animal = get(findobj('Tag','animaltxt'),'String');
    unit   = get(findobj('Tag','unittxt'),'String');
    expt   = get(findobj('Tag','expttxt'),'String');
    datadir= get(findobj('Tag','datatxt'),'String');
    tag    = get(findobj('Tag','tagtxt'),'String');

    dd = [datadir '\' lower(animal) '\grabs\'];
    if(~exist(dd))
        mkdir(dd);
    end
    fname = [dd 'grab_' lower(get(imagerhandles.animaltxt,'String')) '_' ...
        get(imagerhandles.unittxt,'String') '_' ...
        get(imagerhandles.expttxt,'String') '_' ...
        datestr(now)];
    fname = strrep(fname,' ','_');
    fname = strrep(fname,':','_');
    fname = strrep(fname,'-','_');
    fname = [fname '.mat'];
    fname(2) = ':';
    save(fname,'grab');
end
delete(10);
        
        


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global running;

running = 0;


% --- Executes on mouse press over axes background.
function jetaxis_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to jetaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in roibutton.
function roibutton_Callback(hObject, eventdata, handles)
% hObject    handle to roibutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imagerhandles IMGSIZE;

h = imagerhandles;

stop(h.timer);

% 
% val = get(h.histbox,'Value');
% set(h.histbox,'Value',0);
% drawnow;

axes(h.cmapaxes);

%imagerhandles.roi = ginput_imager(1);
imagerhandles.roi = ginput(1);

start(h.timer);

%%set(h.histbox,'Value',val);





% --- Executes during object creation, after setting all properties.
function zaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function zaxis_Callback(hObject, eventdata, handles)
% hObject    handle to zaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global imagerhandles;

val = round(get(hObject,'Value'));  %% z-axis position
%%stop(imagerhandles.timer);
zaxis_absolute(val);             %% move to this absolute value
%%start(imagerhandles.timer);



function roisize_Callback(hObject, eventdata, handles)
% hObject    handle to roisize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roisize as text
%        str2double(get(hObject,'String')) returns contents of roisize as a
%        double

global imagerhandles IMGSIZE;

imagerhandles.roisize = round(str2double(get(hObject,'String')));

% 
% h = imagerhandles;
% 
% tmr_sts = h.timer.running;
% stop(tmr_sts);
% 
% xmin = max(1,ceil(h.roi(1)-h.roisize/2));
% xmax = min(IMGSIZE,floor(h.roi(1)+h.roisize/2));
% ymin = max(1,ceil(h.roi(2)-h.roisize/2));
% ymax = min(IMGSIZE,floor(h.roi(2)+h.roisize/2));
% 
% [xx,yy] = meshgrid(xmin:xmax,ymin:ymax);
% I = sub2ind([IMGSIZE IMGSIZE],xx(:),yy(:));
% 
% imagerhandles.roiI = I;
% 
% if(strcmp(tmr_sts,'on'))
%     start(h.timer);
% end

% --- Executes during object creation, after setting all properties.
function roisize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roisize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function zaxis_absolute(pos)

global imagerhandles;

sza = imagerhandles.sza;
fwrite(sza,[sprintf('4 LA %d',pos) 13 10]);  %% Set absolute position
fwrite(sza,['4 M' 13 10]);  %% Move

%% Now wait for end of movement...

%     fwrite(sza,['4 ST' 13 10]);  %% Status?
%     pause(0.2);
%     q = fread(sza,sza.BytesAvailable,'char');
%     while(q(11)==57)
%         fwrite(sza,['4 ST' 13 10]);  %% Status?
%         pause(0.2);
%         q = fread(sza,sza.BytesAvailable,'char');
%     end


% --- Executes on button press in zaxenable.
function zaxenable_Callback(hObject, eventdata, handles)
% hObject    handle to zaxenable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zaxenable

global imagerhandles;

sza = imagerhandles.sza;

if(get(hObject,'Value'))
    fwrite(sza,['4 EN' 13 10]);  %% enable
else
    fwrite(sza,['4 DIS' 13 10]); %% disable
end


function smarthome(dev,action)

s = instrfind('Tag','x10');

switch(dev)
    case 'camera'
        id = '46';
    case 'motor'
        id = '4E';
    otherwise
        warning('No such X10 device')
        return;
end

switch(action)
    case 1
        code = '45';
    case 0
        code = '47';
    otherwise
        warning('No such X10 action');
        return;
end

fwrite(s,hex2dec({'02' '63' id '4C' code '41'}),'char');

if(s.BytesAvailable > 0)
    fread(s,s.BytesAvailable);
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8

smarthome('camera',get(hObject,'Value'));


% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu9


% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function setvis(handle,state)

list = allchild(handle);
for(j=1:length(list))
    set(list(j),'Visible',state);
end
set(handle,'Visible',state);





% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imagerhandles IMGSIZE;

h = imagerhandles;

stop(h.timer);

axes(h.cmapaxes);
imagerhandles.hwroi = ginput_imager(1);
imagerhandles.hwroisize = str2num(get(h.hwroisizetxt,'String'));
update_hwroi;

start(h.timer);





function hwroisizetxt_Callback(hObject, eventdata, handles)
% hObject    handle to hwroisizetxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hwroisizetxt as text
%        str2double(get(hObject,'String')) returns contents of hwroisizetxt as a double


global imagerhandles IMGSIZE;

h = imagerhandles;

stop(h.timer);

axes(h.cmapaxes);
imagerhandles.hwroisize = str2num(get(h.hwroisizetxt,'String'));
update_hwroi;

start(h.timer);


% --- Executes during object creation, after setting all properties.
function hwroisizetxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hwroisizetxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update_hwroi

global imagerhandles IMGSIZE;

for(i=1:2)
    set(imagerhandles.child{i}.ChildRegion,'OffsetX',round(imagerhandles.hwroi(1) - imagerhandles.hwroisize/2));
    set(imagerhandles.child{i}.ChildRegion,'OffsetY',round(imagerhandles.hwroi(2) - imagerhandles.hwroisize/2));
    set(imagerhandles.child{i}.ChildRegion,'SizeX',imagerhandles.hwroisize);
    set(imagerhandles.child{i}.ChildRegion,'SizeY',imagerhandles.hwroisize);
end



