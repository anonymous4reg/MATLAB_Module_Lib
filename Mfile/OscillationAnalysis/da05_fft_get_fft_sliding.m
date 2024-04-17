clear;close all;clc



%% User define zone
% 1. Where is your "xxx.mat" file?
MatUrl = 'D:\Travail\RE\HIL\[Routine] 沽源振荡\20240331_沽源振荡_豆柳沟\02-HIL测试\record_4-按风速功率表启机.mat';
% 2. Which frequency do yo want to analyze? e.g. [15, 50, 85], must be a vector
FREQ_LIMIT = 100;
% 3. Your data sampling frequency? 
SAMPLE_FREQ = int64(1/50e-6);
% 4. The length of the data you want to feed into fft() function. e.g. 1 is ok for most scenarios.
%    frequency resolution would be 1Hz, length=10 for 0.1Hz resolution ans so on.
T_SPAN = 1; % sec
% 5. Where the data would be sliced. your data may contain 10sec, if you just want to feed the 10th
% second into fft(), set T_START = 9. Of course, your data should have that length.
T_START = 0; % assuming that 0sec is the begining of your data
T_END = 180; % the end of your data 
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
AnsVector = zeros(WindowLen, FREQ_LIMIT+1);
for sig_idx = 1:SigCellLen
	for win_idx = 1:WindowLen
		tmp_uabc = uabc_cell{sig_idx};
		tmp_iabc = iabc_cell{sig_idx};
		tmp_uabc = tmp_uabc(window_index(win_idx, 1):window_index(win_idx, 2), :);
		tmp_iabc = tmp_iabc(window_index(win_idx, 1):window_index(win_idx, 2), :);

		[freq_ax mag_ax ph_ax cmp_ax] = f_fft_simple(tmp_iabc, SAMPLE_FREQ, SAMPLE_FREQ);
        %% Special process begin
        cmp_ax(51, :) = zeros(1, 3);
        % cmp_ax = cmp_ax / abs(cmp_ax(51, :));
        %% Special process end
		AnsVector(win_idx, 1) = win_idx;
        AnsVector(win_idx, 2:(FREQ_LIMIT+1)) = cmp_ax(1:(FREQ_LIMIT), 1)';  % change the idx here to extract the i-th item in ans_tab
        fprintf("sig=%i-window=%i/%i\r\n", sig_idx, win_idx, WindowLen);
		% break
	end
	% break
end

% figure
% subplot(2, 1, 1)
% plot(real(AnsVector(:, 1)), 20*log10(abs(AnsVector(:, 2))))

% subplot(2, 1, 2)
% plot(real(AnsVector(:, 1)), f_phase_round_180(rad2deg(angle((AnsVector(:, 2))))))


% 提取滑动窗的序号（x轴）  
x = AnsVector(:, 1);  
% 提取FFT的频率索引（y轴），注意频率是从1到M-1，因为MATLAB中FFT结果通常从0开始索引，但这里我们不考虑DC分量（第0个频率）  
y = 0:(size(AnsVector, 2) - 2);  % 假设我们不使用第一列（序号）  
% 提取FFT结果的幅值（z轴），排除第一列（序号）  
z_mag = abs(AnsVector(:, 2:end));  % 计算FFT结果的幅值（绝对值）  
z_ang = f_phase_round_180(rad2deg(angle((AnsVector(:, 2:end)))));  % 计算FFT结果的幅值（绝对值）  
% 由于surf和mesh函数需要矩阵形式的x和y，我们需要将它们转换为网格形式  
[X, Y] = meshgrid(x, y);  
% 绘制3D图  
figure;  
surf(X, Y, z_mag', 'EdgeColor', 'none');  % 使用surf绘制3D曲面图，并设置边缘颜色为无  
shading interp;  % 使曲面更加平滑  
% 设置坐标轴标签和标题  
xlabel('滑动窗序号');  
ylabel('FFT频率');  
zlabel('FFT幅值');  
title('FFT幅值3D图');  
% 可选：调整视角以便更好地查看图形  
view(3);  % 设置3D视角为3维

figure;  
surf(X, Y, z_ang', 'EdgeColor', 'none');  % 使用surf绘制3D曲面图，并设置边缘颜色为无  
shading interp;  % 使曲面更加平滑  
% 设置坐标轴标签和标题  
xlabel('滑动窗序号');  
ylabel('FFT频率');  
zlabel('FFT相角');  
title('FFT相角3D图');  
% 可选：调整视角以便更好地查看图形  
view(3);  % 设置3D视角为3维


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


