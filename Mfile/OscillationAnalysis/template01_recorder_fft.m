%% Description
% This file is a template for analyzing FFT spectrum with given data from
% the Fault recorder. You should first export csv from the Fault recorder,
% then feed it in to this program.
% Load CSV --> Select target column --> Plot result

close all; clear; clc
%% Global variables define
% File location
RootDir = 'Your data directory\';
FileName = 'Your CSV data file name.csv';
FileUrl = strcat(RootDir, FileName);
% If your target data is at [3, 4, 5] column, set it in (1:3)+2 form
% (1:3) is relative address, 2 is the bias factor.
TargetColumnIndex = (1:3) + 2;  
% !! Warning: Sample rate must be consistent with your CSV data
% Input the Sample rate of your CSV data
FS = int64(5000);  % Unit(Hz), e.g: 5000 for 5kHz

% Plot parameters
XaxisLimit = [0, 300];
YaxisLimit = [0, 400];
FONT_SIZE = 14;
LINEWIDTH = 1.3;
WIDTH_HEIGHT = [1.5, 5.8];
FigSaveFormat = {'fig', 'png'};
FigSaveResolution = 300;

%% Load CSV file
% !! Your data must be in column-wise format
raw_data = table2array(readtable(FileUrl));
target_data = raw_data(:, TargetColumnIndex);
[~, target_data_col] = size(target_data);
assert(target_data_col == 3, 'Your target data must be nx3 matrix, like a Uabc or Iabc')

%% FFT processing in Sequence domain, Positive/Negative/Zero sequence
[freq_ax, mag_ax, ang_ax, complex_ax] = f_3ph_fft_pn0(target_data, ...
	FS, FS);
figure
subplot(2, 1, 1)
plot(freq_ax, mag_ax(:, 1), 'linewidth', LINEWIDTH)
ylabel('Voltage (kA)')
xlabel('Frequency (Hz)')
grid on
set(gca, 'xlim', XaxisLimit)
% set(gca, 'ylim', YaxisLimit)
tmp_axis = axis;
f_set_fontface(gca, 'times new roman')
% f_savefig(RootDir, 'target_result', FigSaveFormat, FigSaveResolution)