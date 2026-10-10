function [t_rms, ans_rms] = f_slide_rms(data, data_sample_rate, rms_sample_rate)
	%% RMS calc, input data must be column-wise matrix or column vector
	% this func is under development, cause it's result is not consistent to RMS module's output
	if nargin < 3
		rms_sample_rate = 50;  % default 20ms
	end
	% w = 2*pi*fundamental_freq;
	% t = ((1:(data_sample_rate/rms_sample_rate)) - 1) / data_sample_rate;
    % t = t';
	% data_col = size(data, 2); % get column
	% %% if 3ph, lag = 120 deg, otherwise, no lag
	% if data_col == 3
	% 	data_head = initial_value * [sin(w*t), sin(w*t - 2*pi/3), sin(w*t + 2*pi/3)];
	% else
	% 	data_head = [];
	% 	for idx = 1:data_col
	% 		data_head = [initial_value * sin(w*t), data_head];
	% 	end
	% end
	% data = [data_head; data];
	window_size = data_sample_rate / rms_sample_rate; % 窗口大小为 20 ms
	num_samples = size(data, 1); % 数据总样本数
	num_windows = floor(num_samples - window_size - 1); % 窗口数
	


	% 初始化 ans_rms 变量，存储 RMS 值
	ans_rms = zeros(num_windows, 3);

	% 计算每个窗口的 RMS 值
	for i = 1:num_windows
	    start_index = i;
	    end_index = i + window_size;
	    window_data = data(start_index:end_index, :);
	    
	    % 计算 ua、ub、uc 的 RMS 值
	    ans_rms(i, :) = rms(window_data, 1);
	end
	t_rms = (0:length(ans_rms)-1)' / (data_sample_rate);

end