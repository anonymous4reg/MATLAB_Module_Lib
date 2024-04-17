clear;close all;clc

%% User define zone
% 1. Where is your "xxx.mat" file?
MatUrl = 'D:\Travail\RE\HIL\20220302_沽源安控校核\03-调试过程记录\NR_PSS_Data\20240312-Test04-500kV-01-注入8Hz振荡-30MW-无衰减\only_AO.mat';
% 2. Which frequency do yo want to analyze? e.g. [15, 50, 85], must be a vector
WHICH_FREQ = [15];
% 3. Your data sampling frequency? 
SAMPLE_FREQ = int64(1/50e-5);
% 4. The length of the data you want to feed into fft() function. e.g. 1 is ok for most scenarios.
%    frequency resolution would be 1Hz, length=10 for 0.1Hz resolution ans so on.
T_SPAN = 1; % sec
% 5. Where the data would be sliced. your data may contain 10sec, if you just want to feed the 10th
% second into fft(), set T_START = 9. Of course, your data should have that length.
T_START = 10; % assuming that 0sec is the begining of your data
% 6. Specify where your data is located.
				IdxOffset = 1+5;
				Meas1 = [1:3] + IdxOffset;
				Meas2 = Meas1 + 11*1;
				Meas3 = Meas1 + 11*2;
				Meas4 = Meas1 + 11*3;
				Meas5 = Meas1 + 11*4;
				Meas6 = Meas1 + 11*5;

UabcIdx = [1:3];
IabcIdx = UabcIdx+3;


FONT_SIZE = 14;
%% Important variables calculation before the main body of code
T_SELECT_INDEX = [T_START*SAMPLE_FREQ+1:(T_START+T_SPAN)*SAMPLE_FREQ];


% RawData = transpose(importdata(MatUrl));
data_imported = importdata(MatUrl);
t = data_imported.t;
tmp_uabc = data_imported.AO1(:, 1:3)*20/100*500;
tmp_iabc = data_imported.AO2(:, 1:3)*8;
RawData = [tmp_uabc, tmp_iabc];

figure
subplot(2, 1, 1)
plot(t, tmp_uabc)
ylabel('Uabc (kV)')
xlabel('t (s)')
grid on
set(gca, 'xlim', [10, 11])
f_set_fontface(gca, 'TimesNewRomanSimsun')
set(gca, 'fontsize', FONT_SIZE)

subplot(2, 1, 2)
% plot(freq_ax, mag_ax(:, 1)/max(mag_ax(:, 1)))
plot(t, tmp_iabc)
% set(gca, 'ylim', [-0.1, 1.1])
grid on
ylabel('Iabc (kA)')
xlabel('t (s)')
set(gca, 'xlim', [10, 11])
f_set_fontface(gca, 'TimesNewRomanSimsun')
set(gca, 'fontsize', FONT_SIZE)
f_set_fig_size(gcf, [5, 5], [15, 4])


RawData = RawData(T_SELECT_INDEX, :);
Uabc = RawData(:, UabcIdx);
Iabc = RawData(:, IabcIdx);
ans_tab = f_fft_get_sequence_impedance([Uabc, Iabc], SAMPLE_FREQ, T_SPAN, WHICH_FREQ, true, false);
