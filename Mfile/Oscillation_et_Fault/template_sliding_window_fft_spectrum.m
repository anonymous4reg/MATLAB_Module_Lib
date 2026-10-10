clear; close all; clc

%% ==================== 用户配置区 ====================

% 线路配置: {名称, 母线, U列范围, I列范围, CSV文件名, 起始秒}
%   U列/I列范围 是相对于数据列的（第 1 个数据列 = 1），加载时自动 +2
%   名称、母线仅用于识别提示，不影响计算
line_sel = 8;  % <--- 改此数字即可切换线路

lines = {
    '水榭一线', '甲',  9:11, 49:51, '甲母2026-05-28@16-06-44-07-18.csv', 0;
    '水榭二线', '甲', 13:15, 53:55, '甲母2026-05-28@16-06-44-07-18.csv', 0;
    '水蒿线',   '甲', 17:19, 57:59, '甲母2026-05-28@16-06-44-07-18.csv', 0;
    '水簸线',   '甲', 21:23, 61:63, '甲母2026-05-28@16-06-44-07-18.csv', 0;
    '水令线',   '甲', 33:35, 65:67, '甲母2026-05-28@16-06-44-07-18.csv', 0;
    '水盖线',   '乙',  9:11, 29:31, '乙母2026-05-28@16-06-44-07-44.csv', 0;
    '水驹线',   '乙', 13:15, 33:35, '乙母2026-05-28@16-06-44-07-44.csv', 0;
    '水升线',   '乙', 17:19, 37:39, '乙母2026-05-28@16-06-44-07-44.csv', 0;
    '水班线',   '乙', 21:23, 41:43, '乙母2026-05-28@16-06-44-07-44.csv', 0;
    };



% 从线路配置派生
cfg.root_dir    = '../04-fault_recorder/';           % CSV 所在目录
cfg.file_name   = lines{line_sel, 5};

% 采样频率 (Hz)
cfg.sample_freq = int64(1000);

% 每窗时间长度 (秒)，频率分辨率 = 1/t_span
cfg.t_span = 1;
cfg.window_width = cfg.t_span * cfg.sample_freq;

% 时间截取（起始秒由线路配置决定）
cfg.t_start = lines{line_sel, 6};
cfg.t_end   = 90;

% 通道索引（从线路配置提取，CSV 前两列为时间等元数据，故 +2）
uabc_idx = lines{line_sel, 3} + 2;
iabc_idx = lines{line_sel, 4} + 2;

% 滑动窗参数
%   t_span:     窗长时间 (秒), 频率分辨率 = 1/t_span
%   window_step: 窗每次向前移动的距离 (采样点数)
%   窗的数量由数据长度自动计算，无需手动指定
cfg.window_step  = 100;  % 窗移动步长 (采样点)

% 窗函数类型（用于抑制频谱旁瓣泄漏，瀑布图效果更清晰）
%   'none'(默认/矩形窗) | 'hann' | 'hamming' | 'blackman'
cfg.window_type = 'hann';

% 频率范围
cfg.freq_limit = 100;               % 关注 0:N Hz 频段

% 瀑布图去基波：在瀑布图中屏蔽某频率附近的 bin，避免基波幅值过大淹没谐波
cfg.notch_freq      = 50;   % 要屏蔽的中心频率 (Hz)，设为 [] 则不去除
cfg.notch_halfwidth = 2;    % 屏蔽的半带宽 (Hz)，屏蔽范围 = [freq-halfwidth, freq+halfwidth]

% 绘图：surf 使用哪一相 (1=A, 2=B, 3=C)
cfg.surf_phase = 1;

% 杂项
cfg.font_size = 14;
cfg.verbose   = true;               % 循环中打印进度

% 导出选项：设为 true 时将 figure 和 png 保存到 CSV 所在目录
cfg.export_fig = false;  % 导出 .fig 文件
cfg.export_png = false;  % 导出 .png 文件
cfg.png_dpi   = 300;     % PNG 导出分辨率 (dpi)


%% ==================== 数据加载（CSV → table2array）====================

mat_url = fullfile(cfg.root_dir, cfg.file_name);
raw_matrix = table2array(readtable(mat_url));

% 构造时间轴（基于采样率，不从 CSV 第一列读取）
idx_start = cfg.t_start * cfg.sample_freq + 1;
idx_end   = cfg.t_end   * cfg.sample_freq;
assert(idx_start < idx_end && idx_end <= size(raw_matrix, 1), ...
    '时间截取范围超出数据长度。t_end=%d s，数据行数=%d', ...
    cfg.t_end, size(raw_matrix, 1));

data_sel = raw_matrix(idx_start:idx_end, :);
t_axis   = (0 : 1/cfg.sample_freq : (size(data_sel, 1)-1)/cfg.sample_freq)';


%% ==================== 通道提取 ====================

uabc = data_sel(:, uabc_idx);
iabc = data_sel(:, iabc_idx);


%% ==================== 滑动窗生成 ====================

data_len = size(data_sel, 1);
[win_idx_mat, n_windows] = f_sliding_window_generate(...
    1, cfg.window_width, cfg.window_step, data_len);

fprintf('窗宽=%.2f s (%d 点), 步长=%d 点, 共 %d 个窗\n', ...
    cfg.t_span, cfg.window_width, cfg.window_step, n_windows);


%% ==================== 核心计算：滑动窗 FFT → 频谱 ====================
% --------------------------------------------------
%   对每个窗的三相电压、电流做 FFT，存储完整频谱
%   输出: U_mag, U_ang, I_mag, I_ang  (n_windows × n_bins × 3 相)
% --------------------------------------------------

% 频率分辨率 Δf = fs / window_width = 1 / t_span
% 从 freq_limit 推算需要的 bin 数 (含 DC)
delta_f = double(cfg.sample_freq) / double(cfg.window_width);
n_bins = round(cfg.freq_limit / delta_f) + 1;

U_mag = zeros(n_windows, n_bins, 3);
U_ang = zeros(n_windows, n_bins, 3);
I_mag = zeros(n_windows, n_bins, 3);
I_ang = zeros(n_windows, n_bins, 3);
win_center_t = zeros(n_windows, 1);

for win_idx = 1:n_windows

    left  = win_idx_mat(win_idx, 1);
    right = win_idx_mat(win_idx, 2);

    % 窗中心时间
    win_center_t(win_idx) = (left + right) / 2 / cfg.sample_freq + cfg.t_start;

    uabc_win = uabc(left:right, :);
    iabc_win = iabc(left:right, :);

    % FFT on 3-phase voltage & current (带窗函数)
    for ph = 1:3
        [fa, um, ua] = f_fft_simple(uabc_win(:, ph), cfg.sample_freq, cfg.window_width, cfg.window_type);
        [~,  im, ia] = f_fft_simple(iabc_win(:, ph), cfg.sample_freq, cfg.window_width, cfg.window_type);

        U_mag(win_idx, :, ph) = um(1:n_bins)';
        U_ang(win_idx, :, ph) = ua(1:n_bins)';
        I_mag(win_idx, :, ph) = im(1:n_bins)';
        I_ang(win_idx, :, ph) = ia(1:n_bins)';
    end

    if cfg.verbose
        fprintf('win=%d/%d\n', win_idx, n_windows);
    end
end

% 频率轴（所有窗相同，取最后一个窗的 fa）
freq_ax = fa(1:n_bins);

disp('计算完成。');


%% ==================== 可视化 ====================
% --------------------------------------------------
%   1. 3D surf: 幅值谱 & 相位谱（指定相）
%   2. 频谱瀑布图: 三相电压 & 三相电流
% --------------------------------------------------

% 导出文件名前缀（日期+时间+线路名，类别由各图自行拼接）
if cfg.export_fig || cfg.export_png
    export_ts = datestr(now, 'yyyymmdd_HHMM');
    export_line = lines{line_sel, 1};
end

LEFT_POSITION = 5;
BOTTOM_POSITION = 1;
WIDTH_NUM = 24;
HEIGHT_NUM = 12;
POSITION_SET = [LEFT_POSITION, BOTTOM_POSITION, WIDTH_NUM, HEIGHT_NUM];

% 瀑布图需要更多纵向空间以分辨细频率间隔
WATERFALL_HEIGHT = 28;
WATERFALL_POS = [LEFT_POSITION, BOTTOM_POSITION, WIDTH_NUM, WATERFALL_HEIGHT];

ph = cfg.surf_phase;
phase_labels = {'A', 'B', 'C'};

% 构造网格
[X, Y] = meshgrid(win_center_t, freq_ax);

% ---- 图1: 3D surf 幅值谱 ----
figure;
surf(X, Y, squeeze(U_mag(:, :, ph))', 'EdgeColor', 'none');
shading interp;
xlabel('时间 (s)', 'FontSize', cfg.font_size);
ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
zlabel('幅值', 'FontSize', cfg.font_size);
title(sprintf('%s - 电压幅值谱 (%s相) — 滑动窗 FFT', lines{line_sel, 1}, phase_labels{ph}), ...
    'FontSize', cfg.font_size);
colorbar;
view(3);
set(gcf, 'unit', 'centimeters', 'position', POSITION_SET);

% if cfg.export_fig
%     savefig(gcf, fullfile(cfg.root_dir, [export_ts '_U_mag_surf_' export_line '.fig']));
% end
% if cfg.export_png
%     saveas(gcf, fullfile(cfg.root_dir, [export_ts '_U_mag_surf_' export_line '.png']));
% end

% ---- 图2: 3D surf 相位谱 ----
figure;
surf(X, Y, rad2deg(squeeze(U_ang(:, :, ph)))', 'EdgeColor', 'none');
shading interp;
xlabel('时间 (s)', 'FontSize', cfg.font_size);
ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
zlabel('相位 (°)', 'FontSize', cfg.font_size);
title(sprintf('%s - 电压相位谱 (%s相) — 滑动窗 FFT', lines{line_sel, 1}, phase_labels{ph}), ...
    'FontSize', cfg.font_size);
colorbar;
view(3);
set(gcf, 'unit', 'centimeters', 'position', POSITION_SET);

% if cfg.export_fig
%     savefig(gcf, fullfile(cfg.root_dir, [export_ts '_U_ang_surf_' export_line '.fig']));
% end
% if cfg.export_png
%     saveas(gcf, fullfile(cfg.root_dir, [export_ts '_U_ang_surf_' export_line '.png']));
% end

% 瀑布图去基波：构造频率屏蔽掩码
if ~isempty(cfg.notch_freq)
    notch_mask = (freq_ax >= cfg.notch_freq - cfg.notch_halfwidth) ...
               & (freq_ax <= cfg.notch_freq + cfg.notch_halfwidth);
else
    notch_mask = false(size(freq_ax));
end

% ---- 图3: 三相电压频谱瀑布图 ----
figure;
for ph = 1:3
    subplot(3, 1, ph);
    data_plot = squeeze(U_mag(:, :, ph))';
    data_plot(notch_mask, :) = NaN;
    imagesc(win_center_t, freq_ax, data_plot);
    set(gca, 'YDir', 'normal');
    xlabel('时间 (s)', 'FontSize', cfg.font_size);
    ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
    title(sprintf('%s - 三相电压频谱瀑布图 — %s相', lines{line_sel, 1}, phase_labels{ph}), ...
        'FontSize', cfg.font_size);
    colorbar;
    colormap('jet');
end
set(gcf, 'unit', 'centimeters', 'position', WATERFALL_POS);

% if cfg.export_fig
%     savefig(gcf, fullfile(cfg.root_dir, [export_ts '_U_waterfall_' export_line '.fig']));
% end
% if cfg.export_png
%     saveas(gcf, fullfile(cfg.root_dir, [export_ts '_U_waterfall_' export_line '.png']));
% end

% ---- 图4: 三相电流频谱瀑布图 ----
figure;
for ph = 1:3
    subplot(3, 1, ph);
    data_plot = squeeze(I_mag(:, :, ph))';
    data_plot(notch_mask, :) = NaN;
    imagesc(win_center_t, freq_ax, data_plot);
    set(gca, 'YDir', 'normal');
    xlabel('时间 (s)', 'FontSize', cfg.font_size);
    ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
    title(sprintf('%s - 三相电流频谱瀑布图 — %s相', lines{line_sel, 1}, phase_labels{ph}), ...
        'FontSize', cfg.font_size);
    colorbar;
    colormap('jet');
end
set(gcf, 'unit', 'centimeters', 'position', WATERFALL_POS);

if cfg.export_fig
    savefig(gcf, fullfile(cfg.root_dir, [export_ts '_I_waterfall_' export_line '.fig']));
end
if cfg.export_png
    print(gcf, fullfile(cfg.root_dir, [export_ts '_I_waterfall_' export_line '.png']), ...
        '-dpng', ['-r' num2str(cfg.png_dpi)]);
end

disp('绘图完成。');
