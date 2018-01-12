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
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imager_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help imager

% Last Modified by GUIDE v2.5 15-Jul-2004 09:18:17

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

handles.milapp  = handles.activex6;
handles.mildig  = handles.activex7;
handles.mildisp = handles.activex8;
handles.milimg  = handles.activex9;
handles.milsys  = handles.activex10;

% handles.milapp  = actxcontrol('MIL.Application',[0 0 1 1]);
% handles.milsys  = actxcontrol('MIL.System',[0 0 1 1]);
% handles.mildisp = actxcontrol('MIL.Display',[10 10 400 400]);
% handles.mildig  = actxcontrol('MIL.Digitizer',[0 0 1 1]);
% handles.milimg  = actxcontrol('MIL.Image',[0 0 1 1]);


%% Allocate

handles.milsys.Allocate;

handles.mildisp.set('OwnerSystem',handles.milsys,'DisplayType','dispActiveMILWindow');
handles.mildisp.Allocate

handles.mildig.set('OwnerSystem',handles.milsys,'GrabEndEvent',1);
handles.mildig.Allocate;
%% event handler for all digitizer events...
%%handles.mildig.registerevent(@dighandler);

handles.milimg.set('CanGrab',1,'CanDisplay',1,'CanProcess',0, ...
    'SizeX',1024,'SizeY',1024,'DataDepth',16,'NumberOfBands',1,'OwnerSystem',handles.milsys);

handles.milimg.Allocate;

handles.mildig.set('Image',handles.milimg);
handles.mildisp.set('Image',handles.milimg,'ViewMode','dispBitShift','ViewBitShift',4);

% 
% %% now the serial communication...
% 
% delete(instrfind ('Tag','clser'));  %% just in case it crashed
% scl = serial('COM3','Tag','clser','Terminator','CR','DataTerminalReady','off','RequestToSend','off');
% fopen(scl);
% handles.scl = scl;

%% Now construct a timer

handles.timer = timer;
set(handles.timer,'Period',0.5,'BusyMode','queue','ExecutionMode','fixedSpacing','TimerFcn',@timerhandler)

%% Now the data directory, file name, and time tag

handles.datadir = 'c:\imager_data\xx0'
handles.unit = 'u000_000';
handles.time_tag = 0;

%% Now the udp object

delete(instrfind('Tag','imagerudp'));
handles.udp = udp('','LocalPort',2020,'Tag','imagerudp');  %% listen on 2020
set(handles.udp,'BytesAvailableFcnCount',2,'BytesAvailableFcn',@udpcb);
fopen(handles.udp);

global imagerhandles;

imagerhandles = handles;  %% we need this for the timerfcn callback
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
handles.mildisp.Pan(-px,py);

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
handles.mildisp.Pan(-px,py);


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
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in histbox.
function histbox_Callback(hObject, eventdata, handles)
% hObject    handle to histbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of histbox


% --------------------------------------------------------------------
function activex7_GrabEnd(hObject, eventdata, handles)
% hObject    handle to activex7 (see GCBO)
% eventdata  structure with parameters passed to COM event listerner
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function dighandler(varargin)
% hObject    handle to activex7 (see GCBO)
% eventdata  structure with parameters passed to COM event listerner
% handles    structure with handles and user data (see GUIDATA)

global imagerhandles;
invoke(imagerhandles.milapp.Timer,'Read')



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



% --------------------------------------------------------------------
function activex7_GrabFrameEnd(hObject, eventdata, handles)
% hObject    handle to activex7 (see GCBO)
% eventdata  structure with parameters passed to COM event listerner
% handles    structure with handles and user data (see GUIDATA)


function timerhandler(varargin)

global imagerhandles;

%% get the temperature...

y = clsend('vt');

idx = findstr(y,'Celsius');
t1 = y(idx(1)-5:idx(1)-2);
t2 = y(idx(2)-5:idx(2)-2);

h = imagerhandles;
h.mildig.Grab;

set(h.temptxt,'String',sprintf('Digitizer: %sC  Sensor: %sC',t1,t2));

if(get(h.histbox,'Value'))          %% Analyze?

    jetmap = jet;
    jetmap(end-2:end,:) = 1;
    colormap(jetmap);
    axes(h.jetaxis); cla;
    zz = zeros(1024,1024,'uint16');
    h.mildig.GrabWait(3);
    % from mil.h
    % #define M_GRAB_NEXT_FRAME                             1L
    % #define M_GRAB_NEXT_FIELD                             2L
    % #define M_GRAB_END                                    3L

    img = h.milimg.Get(zz,262144,-1,0,0,1024,1024);
    %     img = bitshift(img,-6);
    %     image(img');
    image(double(img)'/4096*64);
    axis ij;
    axis off;

    axes(h.cmapaxes);
    cla;
    colormap(jetmap);
    image(1:64);
    axis off;

    axes(h.histaxes); cla;
    hist(img(:),32:64:4096);
    box off;
    set(gca,'ytick',[],'xtick',[0:1024:4096],'xlim',[0 4096])
    
   %% set(h.focustxt,'String',sprintf('Focus: %.2f',100*focval(img)));
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


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

s = get(hObject,'String');
cmd = s(end,:);  %% get last line
tic
y = clsend(cmd);
toc
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
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%% Focus value function

function y = focval(q)

f = fftshift(abs(fft2(double(q(1:4:end,1:4:end))))).^2;  %% power spectrum
[xx,yy] = meshgrid(-127:128,-127:128);
mask = (xx.^2+yy.^2)>20^2;
y = sum(sum((mask.*f)))./sum(sum(f));


% --------------------------------------------------------------------
function datadir_Callback(hObject, eventdata, handles)
% hObject    handle to datadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global imagerhandles;
dir = uigetdir('c:\imager_data\','Select data directory');
if(dir~=0)
    imagerhandles.datadir = dir;
end
  

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
        stop(handles.timer);
        handles.mildig.Halt;
        %% disable hardware trigger
    case 2,     %grab cont
        stop(handles.timer);
        %% disable hardware trigger
        handles.mildig.GrabContinuous;
    case 3,
        handles.mildig.Halt;
        %% disable hardware trigger
        start(handles.timer);
    case 4,
        handles.mildig.Halt;       
        stop(handles.timer);
        %% enable hardware trigger
end


function udpcb(varargin)

global imagerhandles;

imagerhandles.udp.RemoteHost = imagerhandles.udp.DatagramAddress;
imagerhandles.udp.RemotePort = imagerhandles.udp.DatagramPort;

cmd = fscanf(imagerhandles.udp)

%% parse command here...


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

