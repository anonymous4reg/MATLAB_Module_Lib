function [window_bound_index] = ...
	f_sliding_window_select_by_length(...
		arg_first_index, ...
		arg_window_width, ...
		arg_data_length, arg_window_amount)
% F_SLIDING_WINDOW_SELECT_BY_LENGTH Summary of this function goes here
%   This func will return a Nx2 matrix, each row represents every window,
%	the two elements represent the left and right edge index of this window
% This function calculates window step automatically, and provides dummy check. 
% If your input window amount is larger than the amount of your data can provide, 
% window amount will be reduced automatically

% arg_first_index: the starting index;
% arg_window_width: arg_first_index + arg_window_width - 1 = last_index
% arg_data_length: arg_first_index + arg_step  = arg_window_amountext_first_index
% arg_window_amount: how many windows you want to create, the row of window_bound_index

assert(arg_window_width <= arg_data_length, ...
	"Length of window must be smaller than that of the whole data! Check your _arg_window_width_ and _arg_data_length_")
assert(arg_first_index <= arg_data_length, ...
	"The first index must be smaller than the length of whole data!");
assert(arg_window_amount <= arg_data_length, ...
	"The amount of windows must be smaller than the length of whole data!");
assert((arg_first_index + arg_window_width) <= arg_data_length, ...
	"arg_first_index + arg_window_width > arg_data_length, one window will out of the data!");

step_float = (arg_data_length - arg_first_index + 1 - arg_window_width) / arg_window_amount;
step_int = floor(step_float);
window_n = arg_window_amount;
window_step = step_int;

if (step_int < 1)
	fprintf("Step < 1 according to given _arg_window_amount_. Reduce _arg_window_amount_ automatically...\r\n")
	est_n = arg_window_amount;
	slack_flag = 0;
	while (est_n > 1)
		est_n = est_n - 1;
		est_step_int = floor((arg_data_length - arg_first_index) / est_n);
		if (est_step_int >= 1)
			fprintf("Minimum step found! Step = %i, Window amount = %i\r\n", ...
				est_step_int, est_n)
			slack_flag = 1;
			break
		end
	end
	if slack_flag == 1
		window_n = est_n;
		window_step = est_step_int;
	else
		assert(slack_flag == 1, "Automatic _arg_window_amount_ reduction failed. Step too small according to your _arg_window_amount_\r\n");
	end
end

fprintf("Window Step = %i, Window Amount = %i\r\n", window_step, window_n)
ans2ret = int64(zeros(window_n, 2));
ans2ret(1, 1) = arg_first_index;
ans2ret(1, 2) = arg_first_index + arg_window_width - 1;

for w_idx = 2:window_n
	ans2ret(w_idx, :) = ans2ret(w_idx-1, :) + window_step;
end


window_bound_index = ans2ret;

end

