clear;close all;clc



%% User define zone
% 1. Where is your "xxx.mat" file?
MatUrl = 'D:\Travail\RE\HIL\[Routine] 沽源振荡\20240331_沽源振荡_豆柳沟\02-HIL测试\test02.mat';
% 2. Which frequency do yo want to analyze? e.g. [15, 50, 85], must be a vector
WHICH_FREQ = [9];
% 3. Your data sampling frequency? 
SAMPLE_FREQ = int64(1/50e-6);
% 4. The length of the data you want to feed into fft() function. e.g. 1 is ok for most scenarios.
%    frequency resolution would be 1Hz, length=10 for 0.1Hz resolution ans so on.
T_SPAN = 1; % sec
% 5. Where the data would be sliced. your data may contain 10sec, if you just want to feed the 10th
% second into fft(), set T_START = 9. Of course, your data should have that length.
T_START = 0; % assuming that 0sec is the begining of your data
T_END = 60; % the end of your data 
% 6. Uabc Iabc channel specification.
	%% User added code [begin]
		IdxOffset = 1;
		Meas1 = [1:3] + IdxOffset;
		Meas2 = Meas1 + 11*1;
		Meas3 = Meas1 + 11*2;
		Meas4 = Meas1 + 11*3;
		Meas5 = Meas1 + 11*4;
		Meas6 = Meas1 + 11*5;
		WindowWidth = T_SPAN * SAMPLE_FREQ;
WindowAmount = 100;
	%% User added code [end]

	T_AXIS_IDX = 1;
	UABC_IDX_CELL = {Meas1};
	IABC_IDX_CELL = {Meas1+3};
	UABC_RATIO = {1, 1};
	IABC_RATIO = {1, 1};
% Window length
% 7. Miscollaneous
FONT_SIZE = 14;




%% Precalculation: dimension check
assert(length(UABC_IDX_CELL) == length(IABC_IDX_CELL), ...
	"UABC_IDX_CELL and IABC_IDX_CELL length must be consistent!")

%% Function body: calculation starts here
data_imported = transpose(importdata(MatUrl));
t_axis = data_imported(:, T_AXIS_IDX);
t_axis = t_axis - t_axis(1);

t_start_idx = T_START * SAMPLE_FREQ + 1;
t_end_idx = T_END * SAMPLE_FREQ;

% Slice data by row according to T_START and T_END
t_selected = t_axis(t_start_idx:t_end_idx, :);
data_selected = data_imported(t_start_idx:t_end_idx, :);
[data_row, data_col] = size(data_selected);

% Slice data by column according to UABC_IDX_CELL and IABC_IDX_CELL cell
uabc_cell = {};  iabc_cell = {};
SigCellLen = length(UABC_IDX_CELL);
for sig_idx = 1:SigCellLen
	uabc_cell = [uabc_cell, data_selected(:, UABC_IDX_CELL{sig_idx})];
	iabc_cell = [iabc_cell, data_selected(:, IABC_IDX_CELL{sig_idx})];
end

% Sliding window index generation
window_index = f_sliding_window_select_by_length(1, WindowWidth, data_row, WindowAmount);
[WindowLen, ~] = size(window_index);

% Calculate impedance
AnsVector = zeros(WindowLen, SigCellLen+1);
for sig_idx = 1:SigCellLen
	for win_idx = 1:WindowLen
		tmp_uabc = uabc_cell{sig_idx};
		tmp_iabc = iabc_cell{sig_idx};
		tmp_uabc = tmp_uabc(window_index(win_idx, 1):window_index(win_idx, 2), :);
		tmp_iabc = tmp_iabc(window_index(win_idx, 1):window_index(win_idx, 2), :);
		tmp_tab = f_fft_get_sequence_impedance([tmp_uabc, tmp_iabc], ...
			SAMPLE_FREQ, T_SPAN, WHICH_FREQ, false, false);
		AnsVector(win_idx, 1) = win_idx;
        AnsVector(win_idx, sig_idx+1) = tmp_tab{1, 9};  % change the idx here to extract the i-th item in ans_tab
        fprintf("sig=%i-window=%i/%i\r\n", sig_idx, win_idx, WindowLen);
		% break
	end
	% break
end

figure
subplot(2, 1, 1)
plot(real(AnsVector(:, 1)), 20*log10(abs(AnsVector(:, 2))))

subplot(2, 1, 2)
plot(real(AnsVector(:, 1)), f_phase_round_180(rad2deg(angle((AnsVector(:, 2))))))






% figure
% subplot(2, 1, 1)
% plot(t_selected, tmp_uabc)
% ylabel('Uabc (kV)')
% xlabel('t (s)')
% grid on
% set(gca, 'xlim', [10, 11])
% f_set_fontface(gca, 'TimesNewRomanSimsun')
% set(gca, 'fontsize', FONT_SIZE)
% 
% subplot(2, 1, 2)
% % plot(freq_ax, mag_ax(:, 1)/max(mag_ax(:, 1)))
% plot(t_selected, tmp_iabc)
% % set(gca, 'ylim', [-0.1, 1.1])
% grid on
% ylabel('Iabc (kA)')
% xlabel('t (s)')
% set(gca, 'xlim', [10, 11])
% f_set_fontface(gca, 'TimesNewRomanSimsun')
% set(gca, 'fontsize', FONT_SIZE)
% f_set_fig_size(gcf, [5, 5], [15, 4])


