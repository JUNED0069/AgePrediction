function varargout = Age_prediction(varargin)
% AGE_PREDICTION MATLAB code for Age_prediction.fig
%      AGE_PREDICTION, by itself, creates a new AGE_PREDICTION or raises the existing
%      singleton*.
%
%      H = AGE_PREDICTION returns the handle to a new AGE_PREDICTION or the handle to
%      the existing singleton*.
%
%      AGE_PREDICTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AGE_PREDICTION.M with the given input arguments.
%
%      AGE_PREDICTION('Property','Value',...) creates a new AGE_PREDICTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Age_prediction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Age_prediction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 26-Oct-2023 12:08:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Age_prediction_OpeningFcn, ...
                   'gui_OutputFcn',  @Age_prediction_OutputFcn, ...
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


% --- Executes just before Age_prediction is made visible.
function Age_prediction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Age_prediction (see VARARGIN)

% Choose default command line output for Age_prediction
handles.output = hObject;
handles.ageText = uicontrol('Style', 'text', 'Position', [10, 10, 400, 20]);
handles.genderText = uicontrol('Style', 'text', 'Position', [10, 40, 400, 20]);
handles.featuresText = uicontrol('Style', 'text', 'Position', [10, 70, 400, 100]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Age_prediction wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ... Your other GUI initialization code ...


% --- Outputs from this function are returned to the command line.
function varargout = Age_prediction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function record_Callback(hObject, ~, handles)

        genderOutputText = handles.textGender;
        set(genderOutputText, 'String', 'Predicted Gender: ');

        text5 = handles.display;
        set(text5, 'String' , 'Speak for 10 seconds!');

        Fs = 4000; Channels = 1; bits = 16;
        r = audiorecorder(Fs, bits, Channels);
        duration = 10; % Adjust the recording duration as needed
        textButtonHandle = handles.text;
        set(textButtonHandle, 'String', 'Recording started');
        recordblocking(r, duration);
        set(textButtonHandle, 'String', 'Recording Stopped');
        X = getaudiodata(r);

        % Save the recorded audio as "audio.wav" and overwrite the file
        audiowrite('audio.wav', X, Fs);

        plot = handles.plot;
        set(plot, 'Enable' , 'on');

function plot_Callback(hObject, eventdata, handles)
    filename ='audio.wav';

    [X, Fs] = audioread(filename);

    % Design an FIR low-pass filter to remove high-frequency noise
    N = 100;              % Adjust the filter order as needed
    Fc = 0.6;             % Adjust the cutoff frequency between 0 and 1

    % Create a low-pass FIR filter
    firCoeffs = fir1(N, Fc, 'low');

    % Apply the FIR filter to the audio signal
    denoisedSignal = filter(firCoeffs, 1, X);

    % Amplify the denoised signal (adjust the amplification factor as needed)
    amplificationFactor = 3.0;  % Adjust this factor to control the level of amplification
    denoisedSignalAmplified = denoisedSignal * amplificationFactor;

    % Save the amplified and denoised audio signal in "audio.wav"
    audiowrite('audio.wav', denoisedSignalAmplified, Fs);

    sound(denoisedSignalAmplified, Fs);

    TimeButton = handles.time;
    state = get(TimeButton, 'Value');
    axesHandle = handles.axes;

    if state
        t = 0:1/Fs:(length(denoisedSignalAmplified)-1)/Fs;
        cla(axesHandle);

        % Plot the amplified denoised signal on the time domain axes
        plot(axesHandle, t, denoisedSignalAmplified, 'LineWidth', 1.5);
        xlabel(axesHandle, 'Time (sec)');
        ylabel(axesHandle, 'Amplitude');
        title(axesHandle, 'Time Domain plot of the amplified denoised signal');
    else
        n = length(denoisedSignalAmplified);
        Y = fft(denoisedSignalAmplified, n);
        F_0 = (-n/2:n/2-1).*(Fs/n);
        Y_0 = fftshift(Y);
        AY_0 = abs(Y_0);
        cla(axesHandle);
        plot(axesHandle, F_0, AY_0, 'LineWidth', 1.5);
        xlabel(axesHandle, 'Frequency (Hz)');
        ylabel(axesHandle, 'Amplitude');
        title(axesHandle, 'Frequency Domain plot of the amplified denoised audio Signal');
    end

    gender = handles.gender;
    set(gender, 'Enable' , 'on');

function gender_Callback(hObject, eventdata, handles)
    % Get the path to the Python script
    pythonScriptPath = 'C:/Users/91930/OneDrive/Documents/DSP/test.py'; % Replace with the actual path to your Python script

    % Call the Python script using the system function and capture the output
    [status, commandOutput] = system(['python ', pythonScriptPath], '-echo');
    
    % Process the commandOutput to determine gender
    if status == 0
        % Python script executed successfully
        disp('Python script executed successfully.');
        
        % Check the commandOutput for gender prediction (assuming 0 or 1)
        if str2double(commandOutput) == 0
            gender = 'Female';
        elseif str2double(commandOutput) == 1
            gender = 'Male';
        else
            gender = 'Unknown';  % Handle unknown cases
        end

        % Display the gender prediction on the GUI
        genderOutputText = handles.textGender;
        set(genderOutputText, 'String', ['Predicted Gender: ' gender]);
    else
        % Python script execution failed
        disp('Python script execution failed.');

        % Display an error message on the GUI
        genderOutputText = handles.textGender;
        set(genderOutputText, 'String', 'Python script execution failed.');
    end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)

        genderOutputText = handles.textGender;
        set(genderOutputText, 'String', 'Predicted Gender: ');

        text5 = handles.display;
        set(text5, 'String' , '');

        gender = handles.gender;
        set(gender, 'Enable' , 'off');

        plot = handles.plot;
        set(plot, 'Enable' , 'off');
    
        axesHandle = handles.axes;
        cla(axesHandle);

        textButtonHandle = handles.text;
        set(textButtonHandle, 'String', 'CLICK ON THE BUTTON BELOW');
    
