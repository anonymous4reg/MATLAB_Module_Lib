function [window_bound_index] = f_sliding_window_select(arg_first_index, arg_window_width, arg_step, arg_n)
%F_SLIDING_WINDOW_SELECT Summary of this function goes here
%   This func will return a Nx2 matrix, each row represents every window,
%	the two elements represent the left and right edge index of this window
% arg_first_index: the starting index;
% arg_window_width: arg_first_index + arg_window_width - 1 = last_index
% arg_step: arg_first_index + arg_step  = arg_next_first_index
% arg_n: how many windows you want to create, the row of window_bound_index

ans2ret = zeros(arg_n, 2);
ans2ret(1, 1) = arg_first_index;
ans2ret(1, 2) = arg_first_index + arg_window_width - 1;

for w_idx = 2:arg_n
	ans2ret(w_idx, :) = ans2ret(w_idx-1, :) + arg_step;
end

window_bound_index = ans2ret;

end

