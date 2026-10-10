clear; close all; clc

%% ==================== 用户配置区 ====================

% 1. CSV 文件
cfg.root_dir  = '../data/';           % CSV 所在目录
cfg.file_name = 'xxx.csv';            % CSV 文件名

% 2. 采样频率 (Hz)
cfg.sample_freq = 1000;

% 3. 每窗时间长度 (秒)，频率分辨率 = 1/t_span
cfg.t_span = 1;
cfg.window_width = cfg.t_span * cfg.sample_freq;  % 窗宽（采样点数）

% 4. 时间截取范围 (秒)
cfg.t_start = 0;
cfg.t_end   = 60;

% 5. 通道索引（CSV 前两列为元数据，数据列从第 3 列开始）
%    下面填的索引是相对于数据列的（第 1 个数据列 = 1），加载时会自动 +2
%    每组为 3 列 (abc)，例如 {[1:3]} 表示 U 在数据列 1-3，I 在数据列 4-6
cfg.uabc_idx_cell = {[1:3]};
cfg.iabc_idx_cell = {[1:3] + 3};

% 6. 滑动窗参数
%     window_step: 窗每次向前移动的距离 (采样点数)
%     窗的数量由数据长度自动计算，无需手动指定
cfg.window_step  = 100;  % 窗移动步长 (采样点)

% 7. 频率设定（按需二选一，另一个留空 []）
cfg.which_freq  = [44, 50, 56];   % 指定关注频率的向量
cfg.freq_limit  = [];             % 关注 1:N Hz 全频段

% 8. 杂项
cfg.font_size = 14;
cfg.verbose   = true;             % 循环中打印进度


%% ==================== 数据加载（CSV → table2array）====================

mat_url = fullfile(cfg.root_dir, cfg.file_name);
raw_matrix = table2array(readtable(mat_url));

% CSV 前两列为时间等元数据，数据列需 +2
DATA_COL_OFFSET = 2;

% 构造时间轴（基于采样率，不从 CSV 第一列读取）
idx_start = cfg.t_start * cfg.sample_freq + 1;
idx_end   = cfg.t_end   * cfg.sample_freq;
assert(idx_start < idx_end && idx_end <= size(raw_matrix, 1), ...
    '时间截取范围超出数据长度。t_end=%d s，数据行数=%d', ...
    cfg.t_end, size(raw_matrix, 1));

data_sel = raw_matrix(idx_start:idx_end, :);
t_axis   = (0 : 1/cfg.sample_freq : (size(data_sel, 1)-1)/cfg.sample_freq)';


%% ==================== 通道提取 ====================

assert(length(cfg.uabc_idx_cell) == length(cfg.iabc_idx_cell), ...
    'uabc_idx_cell 与 iabc_idx_cell 长度必须一致');

n_signals = length(cfg.uabc_idx_cell);
uabc_cell = cell(1, n_signals);
iabc_cell = cell(1, n_signals);

for k = 1:n_signals
    uabc_cell{k} = data_sel(:, cfg.uabc_idx_cell{k} + DATA_COL_OFFSET);
    iabc_cell{k} = data_sel(:, cfg.iabc_idx_cell{k} + DATA_COL_OFFSET);
end


%% ==================== 滑动窗生成 ====================

data_len = size(data_sel, 1);
[win_idx_mat, n_windows] = f_sliding_window_generate(...
    1, cfg.window_width, cfg.window_step, data_len);

fprintf('窗宽=%.2f s (%d 点), 步长=%d 点, 共 %d 个窗\n', ...
    cfg.t_span, cfg.window_width, cfg.window_step, n_windows);


%% ==================== 核心计算 ====================
% --------------------------------------------------
%   这里是你放置不同计算逻辑的位置
%   输入：uabc_win (1窗×3列), iabc_win (1窗×3列)
%   输出：你定义的结果矩阵
% --------------------------------------------------

% --- 结果预分配（按需修改） ---
% 示例：每窗存一行结果
result = [];  % TODO: 改成你需要的形状

for sig_idx = 1:n_signals
    for win_idx = 1:n_windows

        left  = win_idx_mat(win_idx, 1);
        right = win_idx_mat(win_idx, 2);

        uabc_win = uabc_cell{sig_idx}(left:right, :);
        iabc_win = iabc_cell{sig_idx}(left:right, :);

        % ==========================================
        %  核心计算在此 —— 调用你的 fft/阻抗函数
        % ==========================================
        % 例如：
        %   tmp_tab = f_gen_fft_tab(uabc_win, iabc_win, cfg.which_freq, cfg.sample_freq, 'off');
        % 或：
        %   [freq_ax, mag_ax, ph_ax, cmp_ax] = f_fft_simple(iabc_win, cfg.sample_freq, cfg.sample_freq);

        % TODO: result(win_idx, ...) = 你的计算结果

        if cfg.verbose
            fprintf('sig=%d/%d  win=%d/%d\n', sig_idx, n_signals, win_idx, n_windows);
        end
    end
end

disp('计算完成。结果存储在变量 result 中。');


%% ==================== 可视化 ====================
% --------------------------------------------------
%   这里是你放置不同绘图逻辑的位置
% --------------------------------------------------

% TODO: 根据 result 内容画图
