%% template_sliding_window_runner_power_flow.m  —  滑动窗 DFT 功率流 / 谐波阻抗分析
% version 2.0  revised by Yamin, 2026-06-11
%
% 功能：
%   1. 多文件、多线路批处理，列名自动匹配（与 da02_fft_get_imp_batch.m 一致）
%   2. 滑动窗 DFT 功率流分析，支持多种窗函数（kaiser/hann/hamming/blackman/none）
%   3. 可选自动寻峰 + 频带功率积分（ENBW 校正），抗频率偏移
%   4. 谐波阻抗计算：直角坐标 (R, X) + 极坐标 (|Z|, ∠Z)
%   5. 每条线路输出：总览图 + 谐波功率图 + 谐波阻抗图 → PNG 保存
%   6. 多线路汇总对比表
%
% 依赖外部文件：tight_subplot.m（总览图需要）
%   参考: check(1).m, da01_fft_get_imp_universal.m, da02_fft_get_imp_batch.m

clear; close all; clc;

% 获取脚本所在目录
SCRIPT_DIR = fileparts(mfilename('fullpath'));
if isempty(SCRIPT_DIR), SCRIPT_DIR = pwd; end

%% ==================== 用户配置区 ====================

RootDir = '../04-fault_recorder/';

% ----- 文件与线路配置 -----
% Files(iFile).path:       CSV 文件名（相对于 RootDir）
% Files(iFile).line_names: 该文件中要分析的线路名称（需与 CSV 列名中的线路名匹配）
% Files(iFile).t_start:    (可选) 该文件的数据起始秒数，默认取全局 cfg.t_start
Files(1).path = '甲母2026-05-28@16-06-44-07-18.csv';
Files(1).line_names = {'2212水谢一线', '2213水谢二线', '2214水蒿线', '2215水簸线', '2216水令线'};
Files(1).t_start = 0;
Files(2).path = '乙母2026-05-28@16-06-44-07-44.csv';
Files(2).line_names = {'2220水盖线', '2221水驹线', '2222水升线', '2219水班线'};
Files(2).t_start = 0;

% ----- 窗函数设置 -----
cfg.window_type    = 'kaiser';    % 'kaiser' | 'hann' | 'hamming' | 'blackman' | 'none'
cfg.kaiser_beta    = 8;          % 凯泽窗 β，仅 window_type='kaiser' 时生效

% ----- 频率设定 -----
cfg.which_freq     = [37.9, 50, 62.1];   % 关注频率向量 (Hz)
cfg.fine_freq_step = 0.1;                % 精细频谱频率步长 (Hz)

% ----- 频带功率积分与自动寻峰（所有窗函数通用）-----
cfg.use_band_power  = true;      % 频带功率积分（抗频率偏移，结果更稳定）
cfg.use_auto_peak   = true;      % 自动在参考频率附近搜索正序电流峰值
cfg.freq_tol        = 0.5;       % 自动寻峰搜索容差 (Hz)
cfg.band_half_width = 0.5;       % 频带功率积分半宽 (Hz)

% ----- 公共分析参数 -----
cfg.sample_freq = int64(1000);   % 采样率 (Hz)
cfg.t_span      = 10;            % 每窗时间长度 (秒)
cfg.window_step = 100;            % 窗移动步长 (采样点)
cfg.t_start     = 0;             % 默认数据起始偏移 (秒)，可被 Files(iFile).t_start 覆盖
cfg.t_duration  = 90;            % 分析时长 (秒)，[] 表示到文件末尾

% ----- 图片输出设置 -----
cfg.output_folder   = '../04-fault_recorder/output_pflow/';  % 图片保存目录
cfg.save_overview   = true;      % 保存每条线路的总览大图 (tight_subplot)
cfg.save_harmonic   = true;      % 保存谐波功率 + 谐波阻抗独立图
cfg.save_fig        = true;      % 同时保存 .fig 文件（MATLAB 图形格式）
cfg.png_dpi         = 300;       % PNG 导出分辨率

% ----- 显示与导出 -----
cfg.font_size = 10;
cfg.verbose   = true;
cfg.save_xlsx = true;            % 保存汇总表为 xlsx

%% ==================== 初始化 ====================

% 创建输出文件夹
outputFull = fullfile(SCRIPT_DIR, cfg.output_folder);
if ~exist(outputFull, 'dir')
    mkdir(outputFull);
end

% 频率配置
if isempty(cfg.which_freq)
    error('cfg.which_freq 不能为空，请指定关注的频率向量');
end
n_freq = length(cfg.which_freq);

% 汇总表列索引：
%   1:线路名称             2:次同步频率_Hz         3:次同步电流_基波%
%   4:次同步电压_基波%      5:次同步阻抗实部_ohm     6:次同步阻抗虚部_ohm
%   7:次同步阻抗幅值_ohm    8:次同步阻抗相角_deg     9:超同步频率_Hz
%  10:超同步电流_基波%     11:超同步电压_基波%      12:超同步阻抗实部_ohm
%  13:超同步阻抗虚部_ohm   14:超同步阻抗幅值_ohm    15:超同步阻抗相角_deg
%  16:基波P_W（单点）      17:基波Q_var（单点）     18:总实时有功_W
%  19:次同步频带P_W        20:次同步频带Q_var       21:基波频带P_W
%  22:基波频带Q_var        23:超同步频带P_W         24:超同步频带Q_var
AllSummary = {};

fprintf('输出目录: %s\n', outputFull);
fprintf('窗函数: %s, β=%d\n', cfg.window_type, cfg.kaiser_beta);
fprintf('频率: [%s] Hz\n', num2str(cfg.which_freq, '%.1f '));

%% ==================== 主循环：文件 × 线路 ====================

for iFile = 1:length(Files)
    MatUrl = fullfile(RootDir, Files(iFile).path);
    LINE_NAMES = Files(iFile).line_names;

    % 确定该文件的起始偏移
    t_start_file = cfg.t_start;
    if isfield(Files(iFile), 't_start')
        t_start_file = Files(iFile).t_start;
    end

    % 确定分析的样本范围
    idx_start = t_start_file * double(cfg.sample_freq) + 1;
    if isempty(cfg.t_duration)
        % 到文件末尾
        idx_end = inf;  % 后面根据实际数据长度裁剪
    else
        idx_end = (t_start_file + cfg.t_duration) * double(cfg.sample_freq);
    end

    fprintf('\n');
    fprintf('####################################################################\n');
    fprintf('处理文件：%s  (起始偏移 %d 秒, 时长 %s 秒)\n', ...
        Files(iFile).path, t_start_file, ...
        iif(isempty(cfg.t_duration), '到末尾', num2str(cfg.t_duration)));
    fprintf('包含线路：%s\n', strjoin(LINE_NAMES, ', '));
    fprintf('####################################################################\n');

    % ---- 读 CSV，获取列名 ----
    RawData = table2array(readtable(MatUrl, 'PreserveVariableNames', true));
    TblMeta = readtable(MatUrl, 'PreserveVariableNames', true, 'ReadVariableNames', true);
    colNames = TblMeta.Properties.VariableNames;
    colNamesClean = cellfun(@(x) strrep(x, ' ', ''), colNames, 'UniformOutput', false);

    % 裁剪 idx_end
    if idx_end > size(RawData, 1)
        idx_end = size(RawData, 1);
    end
    if idx_start >= idx_end
        error('时间截取范围无效: t_start=%d, 数据行数=%d', t_start_file, size(RawData, 1));
    end

    % 列名匹配辅助函数（与 da02_fft_get_imp_batch.m 一致）
    findColIdx = @(lineName, quantity) find(contains(colNamesClean, ...
        [strrep(lineName, ' ', ''), quantity]), 1);

    for iLine = 1:length(LINE_NAMES)
        line = LINE_NAMES{iLine};

        fprintf('\n========================================\n');
        fprintf('分析线路：%s  (文件: %s)\n', line, Files(iFile).path);
        fprintf('========================================\n');

        % ========== 1. 列名匹配 ==========
        cols.Ua = findColIdx(line, 'Ua');
        cols.Ub = findColIdx(line, 'Ub');
        cols.Uc = findColIdx(line, 'Uc');
        cols.Ia = findColIdx(line, 'Ia');
        cols.Ib = findColIdx(line, 'Ib');
        cols.Ic = findColIdx(line, 'Ic');

        colVals = struct2array(cols);
        if any(colVals == 0)
            missing = fieldnames(cols);
            missing = missing(colVals == 0);
            warning('线路 %s 缺少列: %s，跳过', line, strjoin(missing, ', '));
            continue;
        end

        % ========== 2. 数据提取 ==========
        USabc = double(RawData(idx_start:idx_end, [cols.Ua, cols.Ub, cols.Uc]));
        ISabc = double(RawData(idx_start:idx_end, [cols.Ia, cols.Ib, cols.Ic]));

        % 实时总有功功率（瞬时 u·i 均值）
        P_real_time = mean(sum(USabc .* ISabc, 2));
        fprintf('实时总有功功率 = %.4f W\n', P_real_time);

        % ========== 3. 滑动窗生成 ==========
        data_len = size(USabc, 1);
        win_width = cfg.t_span * double(cfg.sample_freq);
        [win_idx_mat, n_windows] = f_sliding_window_generate(...
            1, win_width, cfg.window_step, data_len);

        fprintf('窗宽=%.2f s (%d 点), 步长=%d 点, 共 %d 个窗\n', ...
            cfg.t_span, win_width, cfg.window_step, n_windows);

        % ========== 4. 结果预分配 ==========
        win_center_t = zeros(n_windows, 1);
        P_mat   = zeros(n_windows, n_freq);
        Q_mat   = zeros(n_windows, n_freq);
        Up_mat  = zeros(n_windows, n_freq);
        Ip_mat  = zeros(n_windows, n_freq);
        Uabc_mat = zeros(n_windows, n_freq, 3);
        Iabc_mat = zeros(n_windows, n_freq, 3);
        R_mat   = zeros(n_windows, n_freq);
        X_mat   = zeros(n_windows, n_freq);
        Zmag_mat = zeros(n_windows, n_freq);
        Zang_mat = zeros(n_windows, n_freq);

        % ========== 5. 核心计算：滑动窗 DFT ==========
        for win_idx = 1:n_windows

            left  = win_idx_mat(win_idx, 1);
            right = win_idx_mat(win_idx, 2);

            win_center_t(win_idx) = (left + right) / 2 / double(cfg.sample_freq) + t_start_file;

            uabc_win = USabc(left:right, :);
            iabc_win = ISabc(left:right, :);

            % ----- 生成窗函数 -----
            N_win = size(uabc_win, 1);
            switch cfg.window_type
                case 'kaiser'
                    w = kaiser(N_win, cfg.kaiser_beta);
                case 'hann'
                    w = hann(N_win);
                case 'hamming'
                    w = hamming(N_win);
                case 'blackman'
                    w = blackman(N_win);
                case 'none'
                    w = ones(N_win, 1);
                otherwise
                    error('未知窗函数类型: %s', cfg.window_type);
            end
            win_corr = 2 / sum(w);
            ENBW = N_win * sum(w.^2) / (sum(w))^2;

            for f_idx = 1:n_freq
                f_ref = cfg.which_freq(f_idx);
                need_sweep = cfg.use_auto_peak || cfg.use_band_power;

                if need_sweep
                    % ----- 精细频率扫描 -----
                    if cfg.use_auto_peak && cfg.use_band_power
                        sweep_half = cfg.freq_tol + cfg.band_half_width;
                    elseif cfg.use_auto_peak
                        sweep_half = cfg.freq_tol;
                    else
                        sweep_half = cfg.band_half_width;
                    end
                    f_sweep = (f_ref - sweep_half : cfg.fine_freq_step : f_ref + sweep_half)';
                    n_sweep = length(f_sweep);

                    I1_sweep = zeros(n_sweep, 1);
                    P1_sweep = zeros(n_sweep, 1);
                    Q1_sweep = zeros(n_sweep, 1);

                    for k = 1:n_sweep
                        fk = f_sweep(k);
                        Ua_k = get_complex_at_freq_windowed(uabc_win(:,1), fk, cfg.sample_freq, w, win_corr);
                        Ub_k = get_complex_at_freq_windowed(uabc_win(:,2), fk, cfg.sample_freq, w, win_corr);
                        Uc_k = get_complex_at_freq_windowed(uabc_win(:,3), fk, cfg.sample_freq, w, win_corr);
                        Ia_k = get_complex_at_freq_windowed(iabc_win(:,1), fk, cfg.sample_freq, w, win_corr);
                        Ib_k = get_complex_at_freq_windowed(iabc_win(:,2), fk, cfg.sample_freq, w, win_corr);
                        Ic_k = get_complex_at_freq_windowed(iabc_win(:,3), fk, cfg.sample_freq, w, win_corr);

                        u_seq_k = f_seqconv([Ua_k; Ub_k; Uc_k]);
                        i_seq_k = f_seqconv([Ia_k; Ib_k; Ic_k]);
                        Up_k = u_seq_k(1);
                        Ip_k = i_seq_k(1);

                        I1_sweep(k) = abs(Ip_k);
                        theta_k = angle(Up_k) - angle(Ip_k);
                        P1_sweep(k) = 1.5 * abs(Up_k) * abs(Ip_k) * cos(theta_k);
                        Q1_sweep(k) = 1.5 * abs(Up_k) * abs(Ip_k) * sin(theta_k);
                    end

                    % 自动寻峰 / 手动确定频带中心
                    if cfg.use_auto_peak
                        [~, idx_peak] = max(I1_sweep);
                        f_center = f_sweep(idx_peak);
                    else
                        f_center = f_ref;
                    end

                    % 频带功率积分（ENBW 校正）或单频点功率
                    if cfg.use_band_power
                        band_lo = f_center - cfg.band_half_width;
                        band_hi = f_center + cfg.band_half_width;
                        idx_band = (f_sweep >= band_lo) & (f_sweep <= band_hi);
                        if any(idx_band)
                            Pp = sum(P1_sweep(idx_band)) / ENBW;
                            Qp = sum(Q1_sweep(idx_band)) / ENBW;
                        else
                            Pp = 0;  Qp = 0;
                        end
                    else
                        [~, idx_ctr] = min(abs(f_sweep - f_center));
                        Pp = P1_sweep(idx_ctr);
                        Qp = Q1_sweep(idx_ctr);
                    end

                    % 提取 f_center 处的复幅值
                    Ua_c = get_complex_at_freq_windowed(uabc_win(:,1), f_center, cfg.sample_freq, w, win_corr);
                    Ub_c = get_complex_at_freq_windowed(uabc_win(:,2), f_center, cfg.sample_freq, w, win_corr);
                    Uc_c = get_complex_at_freq_windowed(uabc_win(:,3), f_center, cfg.sample_freq, w, win_corr);
                    Ia_c = get_complex_at_freq_windowed(iabc_win(:,1), f_center, cfg.sample_freq, w, win_corr);
                    Ib_c = get_complex_at_freq_windowed(iabc_win(:,2), f_center, cfg.sample_freq, w, win_corr);
                    Ic_c = get_complex_at_freq_windowed(iabc_win(:,3), f_center, cfg.sample_freq, w, win_corr);
                    u_seq_c = f_seqconv([Ua_c; Ub_c; Uc_c]);
                    i_seq_c = f_seqconv([Ia_c; Ib_c; Ic_c]);
                    Up_mag = abs(u_seq_c(1));
                    Ip_mag = abs(i_seq_c(1));
                    Zp = u_seq_c(1) / i_seq_c(1);
                    Uabc_mag = [abs(Ua_c), abs(Ub_c), abs(Uc_c)];
                    Iabc_mag = [abs(Ia_c), abs(Ib_c), abs(Ic_c)];

                else
                    % ----- 简单模式：单频点提取 -----
                    f_center = f_ref;

                    Ua_c = get_complex_at_freq_windowed(uabc_win(:,1), f_center, cfg.sample_freq, w, win_corr);
                    Ub_c = get_complex_at_freq_windowed(uabc_win(:,2), f_center, cfg.sample_freq, w, win_corr);
                    Uc_c = get_complex_at_freq_windowed(uabc_win(:,3), f_center, cfg.sample_freq, w, win_corr);
                    Ia_c = get_complex_at_freq_windowed(iabc_win(:,1), f_center, cfg.sample_freq, w, win_corr);
                    Ib_c = get_complex_at_freq_windowed(iabc_win(:,2), f_center, cfg.sample_freq, w, win_corr);
                    Ic_c = get_complex_at_freq_windowed(iabc_win(:,3), f_center, cfg.sample_freq, w, win_corr);

                    u_seq_c = f_seqconv([Ua_c; Ub_c; Uc_c]);
                    i_seq_c = f_seqconv([Ia_c; Ib_c; Ic_c]);
                    Up = u_seq_c(1);
                    Ip = i_seq_c(1);
                    Up_mag = abs(Up);
                    Ip_mag = abs(Ip);
                    Zp = Up / Ip;
                    theta = angle(Up) - angle(Ip);
                    Pp = 1.5 * Up_mag * Ip_mag * cos(theta);
                    Qp = 1.5 * Up_mag * Ip_mag * sin(theta);
                    Uabc_mag = [abs(Ua_c), abs(Ub_c), abs(Uc_c)];
                    Iabc_mag = [abs(Ia_c), abs(Ib_c), abs(Ic_c)];
                end

                % 存储结果
                P_mat(win_idx, f_idx)   = Pp;
                Q_mat(win_idx, f_idx)   = Qp;
                Up_mat(win_idx, f_idx)  = Up_mag;
                Ip_mat(win_idx, f_idx)  = Ip_mag;
                Uabc_mat(win_idx, f_idx, :) = Uabc_mag;
                Iabc_mat(win_idx, f_idx, :) = Iabc_mag;
                R_mat(win_idx, f_idx)   = real(Zp);
                X_mat(win_idx, f_idx)   = imag(Zp);
                Zmag_mat(win_idx, f_idx) = abs(Zp);
                Zang_mat(win_idx, f_idx) = angle(Zp) * 180/pi;
            end

            if cfg.verbose
                fprintf('  [%s] win=%d/%d\n', line, win_idx, n_windows);
            end
        end

        disp('计算完成。');

        % ========== 6. 计算汇总统计量（均值）==========
        % 确定次同步 (<50Hz)、基波 (50Hz)、超同步 (>50Hz) 的列索引
        f_low_list  = find(cfg.which_freq < 50);
        f_high_list = find(cfg.which_freq > 50);
        idx_base = find(cfg.which_freq == 50, 1);
        if isempty(idx_base)
            idx_base = find(cfg.which_freq >= 49 & cfg.which_freq <= 51, 1);
        end

        % 用第一个次同步/超同步频率作为代表（汇总表每线路一行）
        if isempty(f_low_list)
            idx_low = 1;  % fallback: 取第一个频率
        else
            idx_low = f_low_list(1);
        end
        if isempty(f_high_list)
            idx_high = n_freq;  % fallback: 取最后一个频率
        else
            idx_high = f_high_list(1);
        end
        if isempty(idx_base)
            idx_base = 1;
        end

        % 均值统计
        low_freq_val  = cfg.which_freq(idx_low);
        high_freq_val = cfg.which_freq(idx_high);

        Ip_low_mean  = mean(Ip_mat(:, idx_low));
        Up_low_mean  = mean(Up_mat(:, idx_low));
        Ip_base_mean = mean(Ip_mat(:, idx_base));
        Up_base_mean = mean(Up_mat(:, idx_base));
        Ip_high_mean = mean(Ip_mat(:, idx_high));
        Up_high_mean = mean(Up_mat(:, idx_high));

        low_I_pct  = (Ip_low_mean  / Ip_base_mean) * 100;
        low_U_pct  = (Up_low_mean  / Up_base_mean) * 100;
        high_I_pct = (Ip_high_mean / Ip_base_mean) * 100;
        high_U_pct = (Up_high_mean / Up_base_mean) * 100;

        R_low_mean  = mean(R_mat(:, idx_low));
        X_low_mean  = mean(X_mat(:, idx_low));
        Zmag_low_mean = mean(Zmag_mat(:, idx_low));
        Zang_low_mean = mean(Zang_mat(:, idx_low));

        R_high_mean  = mean(R_mat(:, idx_high));
        X_high_mean  = mean(X_mat(:, idx_high));
        Zmag_high_mean = mean(Zmag_mat(:, idx_high));
        Zang_high_mean = mean(Zang_mat(:, idx_high));

        P_base_single = mean(P_mat(:, idx_base));
        Q_base_single = mean(Q_mat(:, idx_base));
        P_low_band  = mean(P_mat(:, idx_low));
        Q_low_band  = mean(Q_mat(:, idx_low));
        P_base_band = mean(P_mat(:, idx_base));
        Q_base_band = mean(Q_mat(:, idx_base));
        P_high_band = mean(P_mat(:, idx_high));
        Q_high_band = mean(Q_mat(:, idx_high));

        % ========== 7. 存入汇总表 ==========
        currentRow = {line, ...
            low_freq_val,  low_I_pct,  low_U_pct,  R_low_mean, X_low_mean, ...
            Zmag_low_mean, Zang_low_mean, ...
            high_freq_val, high_I_pct, high_U_pct, R_high_mean, X_high_mean, ...
            Zmag_high_mean, Zang_high_mean, ...
            P_base_single, Q_base_single, P_real_time, ...
            P_low_band, Q_low_band, P_base_band, Q_base_band, P_high_band, Q_high_band};
        AllSummary = [AllSummary; currentRow];

        % ========== 8. 绘图 ==========
        % 公用设置
        phase_labels = {'A', 'B', 'C'};
        phase_colors = {[0.80, 0.60, 0.10], [0.15, 0.65, 0.25], [0.85, 0.20, 0.15]};
        sub_font_size = cfg.font_size - 2;

        % 确定非 50Hz 频率的列索引（用于独立谐波图）
        idx_harm = find(cfg.which_freq ~= 50);
        n_harm = length(idx_harm);

        % ------ 8a. 总览大图 (tight_subplot, 10行) ------
        n_rows = 10;
        n_cols = n_freq;
        fig_overview = figure('Name', sprintf('%s 总览', line), ...
            'Position', [50, 50, 320*n_cols, 80*n_rows], 'Visible', 'off');
        ha = tight_subplot(n_rows, n_cols, [0.04 0.03], [0.05 0.08], [0.05 0.02]);

        for col = 1:n_cols
            f_val = cfg.which_freq(col);
            is_50hz = (abs(f_val - 50) < 0.1);

            % Row 1: P
            axes(ha(0*n_cols + col));
            if is_50hz
                yyaxis left;
                plot(win_center_t, P_mat(:, col), 'b-', 'LineWidth', 1.2);
                ylabel('P (W)'); yyaxis right;
                plot(win_center_t, Q_mat(:, col), 'r-', 'LineWidth', 1.2);
                ylabel('Q (var)');
                title(sprintf('P&Q @ %.1f Hz', f_val), 'FontSize', sub_font_size);
            else
                plot(win_center_t, P_mat(:, col), 'LineWidth', 1.2);
                ylabel('P (W)'); grid on;
                title(sprintf('有功 P @ %.1f Hz', f_val), 'FontSize', sub_font_size);
            end
            if is_50hz, grid on; end

            % Row 2: Q
            axes(ha(1*n_cols + col));
            if is_50hz
                axis off;
            else
                plot(win_center_t, Q_mat(:, col), 'LineWidth', 1.2);
                ylabel('Q (var)'); grid on;
                title(sprintf('无功 Q @ %.1f Hz', f_val), 'FontSize', sub_font_size);
            end

            % Row 3: Up
            axes(ha(2*n_cols + col));
            plot(win_center_t, Up_mat(:, col), 'LineWidth', 1.2);
            ylabel('Up (V)'); grid on;
            title(sprintf('正序电压 Up @ %.1f Hz', f_val), 'FontSize', sub_font_size);

            % Row 4: Ip
            axes(ha(3*n_cols + col));
            plot(win_center_t, Ip_mat(:, col), 'LineWidth', 1.2);
            ylabel('Ip (A)'); grid on;
            title(sprintf('正序电流 Ip @ %.1f Hz', f_val), 'FontSize', sub_font_size);

            % Row 5: Uabc
            axes(ha(4*n_cols + col));
            hold on;
            for ph = 1:3
                plot(win_center_t, Uabc_mat(:, col, ph), ...
                    'LineWidth', 1.2, 'Color', phase_colors{ph});
            end
            ylabel('Uabc (V)'); grid on;
            title(sprintf('三相电压 @ %.1f Hz', f_val), 'FontSize', sub_font_size);
            legend(phase_labels, 'Location', 'best', 'FontSize', sub_font_size - 3);

            % Row 6: Iabc
            axes(ha(5*n_cols + col));
            hold on;
            for ph = 1:3
                plot(win_center_t, Iabc_mat(:, col, ph), ...
                    'LineWidth', 1.2, 'Color', phase_colors{ph});
            end
            ylabel('Iabc (A)'); grid on;
            title(sprintf('三相电流 @ %.1f Hz', f_val), 'FontSize', sub_font_size);
            legend(phase_labels, 'Location', 'best', 'FontSize', sub_font_size - 3);

            % Row 7: R
            axes(ha(6*n_cols + col));
            plot(win_center_t, R_mat(:, col), 'LineWidth', 1.2, 'Color', [0.20, 0.40, 0.80]);
            ylabel('R (ohm)'); grid on;
            title(sprintf('阻抗实部 R @ %.1f Hz', f_val), 'FontSize', sub_font_size);

            % Row 8: X
            axes(ha(7*n_cols + col));
            plot(win_center_t, X_mat(:, col), 'LineWidth', 1.2, 'Color', [0.80, 0.20, 0.20]);
            ylabel('X (ohm)'); grid on;
            title(sprintf('阻抗虚部 X @ %.1f Hz', f_val), 'FontSize', sub_font_size);

            % Row 9: |Z|
            axes(ha(8*n_cols + col));
            plot(win_center_t, Zmag_mat(:, col), 'LineWidth', 1.2, 'Color', [0.00, 0.60, 0.30]);
            ylabel('|Z| (ohm)'); grid on;
            title(sprintf('阻抗幅值 |Z| @ %.1f Hz', f_val), 'FontSize', sub_font_size);

            % Row 10: ∠Z
            axes(ha(9*n_cols + col));
            plot(win_center_t, Zang_mat(:, col), 'LineWidth', 1.2, 'Color', [0.60, 0.10, 0.60]);
            xlabel('时间 (s)', 'FontSize', sub_font_size);
            ylabel('\angleZ (deg)'); grid on;
            title(sprintf('阻抗相角 \\angleZ @ %.1f Hz', f_val), 'FontSize', sub_font_size);
        end

        sgtitle(sprintf('%s — 滑动窗 DFT 全览 (%s窗, β=%d)', line, cfg.window_type, cfg.kaiser_beta), ...
            'FontSize', cfg.font_size + 4, 'FontWeight', 'bold');

        if cfg.save_overview
            fname = fullfile(outputFull, sprintf('%s_总览.png', line));
            exportgraphics(fig_overview, fname, 'Resolution', cfg.png_dpi);
            fprintf('已保存: %s\n', fname);
        end
        if cfg.save_fig
            fname_fig = fullfile(outputFull, sprintf('%s_总览.fig', line));
            savefig(fig_overview, fname_fig);
            fprintf('已保存: %s\n', fname_fig);
        end
        close(fig_overview);

        % ------ 8b. 谐波功率图（非 50Hz 频率的 P, Q）------
        if cfg.save_harmonic && n_harm > 0
            fig_hp = figure('Name', sprintf('%s 谐波功率', line), ...
                'Position', [50, 50, 300*n_harm, 350], 'Visible', 'off');
            ha_hp = tight_subplot(2, n_harm, [0.08 0.06], [0.10 0.12], [0.06 0.04]);

            for hc = 1:n_harm
                col = idx_harm(hc);
                f_val = cfg.which_freq(col);

                axes(ha_hp(0*n_harm + hc));
                plot(win_center_t, P_mat(:, col), 'b-', 'LineWidth', 1.5);
                ylabel('P (W)'); grid on;
                title(sprintf('有功 P @ %.1f Hz', f_val), 'FontSize', sub_font_size);

                axes(ha_hp(1*n_harm + hc));
                plot(win_center_t, Q_mat(:, col), 'r-', 'LineWidth', 1.5);
                xlabel('时间 (s)'); ylabel('Q (var)'); grid on;
                title(sprintf('无功 Q @ %.1f Hz', f_val), 'FontSize', sub_font_size);
            end

            sgtitle(sprintf('%s — 谐波功率 (%s窗)', line, cfg.window_type), ...
                'FontSize', cfg.font_size + 2, 'FontWeight', 'bold');

            fname = fullfile(outputFull, sprintf('%s_谐波功率.png', line));
            exportgraphics(fig_hp, fname, 'Resolution', cfg.png_dpi);
            fprintf('已保存: %s\n', fname);
            if cfg.save_fig
                fname_fig = fullfile(outputFull, sprintf('%s_谐波功率.fig', line));
                savefig(fig_hp, fname_fig);
                fprintf('已保存: %s\n', fname_fig);
            end
            close(fig_hp);
        end

        % ------ 8c. 谐波阻抗图（非 50Hz 频率的 |Z|, ∠Z）------
        if cfg.save_harmonic && n_harm > 0
            fig_hi = figure('Name', sprintf('%s 谐波阻抗', line), ...
                'Position', [50, 50, 300*n_harm, 350], 'Visible', 'off');
            ha_hi = tight_subplot(2, n_harm, [0.08 0.06], [0.10 0.12], [0.06 0.04]);

            for hc = 1:n_harm
                col = idx_harm(hc);
                f_val = cfg.which_freq(col);

                axes(ha_hi(0*n_harm + hc));
                plot(win_center_t, Zmag_mat(:, col), 'LineWidth', 1.5, ...
                    'Color', [0.00, 0.60, 0.30]);
                ylabel('|Z| (ohm)'); grid on;
                title(sprintf('阻抗幅值 |Z| @ %.1f Hz', f_val), 'FontSize', sub_font_size);

                axes(ha_hi(1*n_harm + hc));
                plot(win_center_t, Zang_mat(:, col), 'LineWidth', 1.5, ...
                    'Color', [0.60, 0.10, 0.60]);
                xlabel('时间 (s)'); ylabel('\angleZ (deg)'); grid on;
                title(sprintf('阻抗相角 \\angleZ @ %.1f Hz', f_val), 'FontSize', sub_font_size);
            end

            sgtitle(sprintf('%s — 谐波阻抗 (%s窗)', line, cfg.window_type), ...
                'FontSize', cfg.font_size + 2, 'FontWeight', 'bold');

            fname = fullfile(outputFull, sprintf('%s_谐波阻抗.png', line));
            exportgraphics(fig_hi, fname, 'Resolution', cfg.png_dpi);
            fprintf('已保存: %s\n', fname);
            if cfg.save_fig
                fname_fig = fullfile(outputFull, sprintf('%s_谐波阻抗.fig', line));
                savefig(fig_hi, fname_fig);
                fprintf('已保存: %s\n', fname_fig);
            end
            close(fig_hi);
        end
    end
end

%% ==================== 汇总输出 ====================

if isempty(AllSummary)
    warning('没有成功分析任何线路。');
    return;
end

SummaryTable = cell2table(AllSummary, ...
    'VariableNames', {'线路名称', ...
    '次同步频率_Hz', '次同步电流_基波百分比', '次同步电压_基波百分比', ...
    '次同步阻抗实部_ohm', '次同步阻抗虚部_ohm', ...
    '次同步阻抗幅值_ohm', '次同步阻抗相角_deg', ...
    '超同步频率_Hz', '超同步电流_基波百分比', '超同步电压_基波百分比', ...
    '超同步阻抗实部_ohm', '超同步阻抗虚部_ohm', ...
    '超同步阻抗幅值_ohm', '超同步阻抗相角_deg', ...
    '基波P_W', '基波Q_var', '总实时有功_W', ...
    '次同步频带P_W', '次同步频带Q_var', ...
    '基波频带P_W', '基波频带Q_var', ...
    '超同步频带P_W', '超同步频带Q_var'});

fprintf('\n\n========== 所有线路分析汇总 ==========\n');
disp(SummaryTable);

if cfg.save_xlsx
    xlsxPath = fullfile(outputFull, '功率流_分析汇总.xlsx');
    writetable(SummaryTable, xlsxPath);
    fprintf('汇总表已保存: %s\n', xlsxPath);
end

fprintf('\n===== 脚本运行完成 =====\n');

%% ==================== 局部函数定义 ====================

function iif_result = iif(condition, true_val, false_val)
    % 简单的内联 if 替代
    if condition
        iif_result = true_val;
    else
        iif_result = false_val;
    end
end

function cplx = get_complex_at_freq_windowed(signal, freq, fs, w, win_corr)
    % 使用预定义的窗口和修正系数提取复数幅值（峰值）
    %   signal  : 时域信号向量
    %   freq    : 目标频率 (Hz)
    %   fs      : 采样率 (Hz)
    %   w       : 预计算的窗口向量
    %   win_corr: 峰值恢复系数 = 2 / sum(w)
    signal = double(signal(:));
    N = length(signal);
    n = double((0:N-1)');
    fs = double(fs);

    signal_w = signal .* w;
    complex_exp = exp(-1j * 2 * pi * freq * n / fs);
    X = sum(signal_w .* complex_exp);
    mag = abs(X) * win_corr;
    ang = angle(X);
    cplx = mag * exp(1j * ang);
end

function V120 = f_seqconv(Vabc)
    % ABC 三相 → 正序/负序/零序 变换
    a = exp(1j * 2 * pi / 3);
    A = 1/3 * [1, a, a^2; 1, a^2, a; 1, 1, 1];
    V120 = A * Vabc;
end
