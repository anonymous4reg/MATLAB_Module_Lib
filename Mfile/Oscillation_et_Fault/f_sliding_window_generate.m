function [window_bound_index, n_windows] = f_sliding_window_generate(...
    arg_start_idx, arg_window_width, arg_step, arg_data_len)
% F_SLIDING_WINDOW_GENERATE 依据步长自动生成滑动窗索引
%
%   给定起始索引、窗宽、步长（采样点数）和数据总长度，自动计算能容纳的
%   最大窗数，返回 N×2 的窗边界索引矩阵 [left, right]。
%
%   arg_start_idx    - 第一个窗的起始索引（采样点编号，从 1 开始）
%   arg_window_width - 窗宽（采样点数）
%   arg_step         - 窗每次向前移动的步长（采样点数），≥ 1
%   arg_data_len     - 数据段总长度（采样点数）
%
%   window_bound_index - N×2 矩阵，每行 [左边界, 右边界]（采样点索引）
%   n_windows          - 窗的总数 N
%
%   计算公式:
%     N = floor((data_len - start_idx + 1 - window_width) / step) + 1
%
%   See also F_SLIDING_WINDOW_SELECT, F_SLIDING_WINDOW_SELECT_BY_LENGTH.

    arguments
        arg_start_idx    (1,1) {mustBeInteger, mustBePositive}
        arg_window_width (1,1) {mustBeInteger, mustBePositive}
        arg_step         (1,1) {mustBeInteger, mustBePositive}
        arg_data_len     (1,1) {mustBeInteger, mustBePositive}
    end

    assert(arg_window_width <= arg_data_len, ...
        '窗宽 (%d 点) 不能大于数据总长度 (%d 点)。', ...
        arg_window_width, arg_data_len);

    assert(arg_start_idx <= arg_data_len, ...
        '起始索引 (%d) 不能大于数据长度 (%d)。', ...
        arg_start_idx, arg_data_len);

    assert(arg_start_idx + arg_window_width - 1 <= arg_data_len, ...
        '第一个窗的结束索引 (%d) 已超出数据范围 (%d)。请减小窗宽或调整起始索引。', ...
        arg_start_idx + arg_window_width - 1, arg_data_len);

    n_windows = floor((arg_data_len - arg_start_idx + 1 - arg_window_width) / arg_step) + 1;

    assert(n_windows >= 1, ...
        '无法生成任何窗。数据长度=%d, 起始=%d, 窗宽=%d, 步长=%d。', ...
        arg_data_len, arg_start_idx, arg_window_width, arg_step);

    window_bound_index = zeros(n_windows, 2);
    window_bound_index(1, 1) = arg_start_idx;
    window_bound_index(1, 2) = arg_start_idx + arg_window_width - 1;

    for w_idx = 2:n_windows
        window_bound_index(w_idx, :) = window_bound_index(w_idx - 1, :) + arg_step;
    end

    fprintf('滑动窗生成完成: 窗宽=%d 点, 步长=%d 点, 窗数=%d\n', ...
        arg_window_width, arg_step, n_windows);
end
