%% da02_fft_get_imp_batch.m  —  多文件多线路谐波分析（加窗FFT + 频带功率）
% version 1.0  revised by Yamin, 2026-06-11
%
% 基于 da01_fft_get_imp_universal.m 为底本，融合 check(1).m 的功能增强：
%   1. 多文件、多线路批处理，列名自动匹配
%   2. FFT 加窗选项：none（默认）/ kaiser / hann，含幅值恢复
%   3. 频率确定：手动指定 + 正序电流谱自动寻峰
%   4. 单点 P/Q/R/X/Z + 频带积分功率（ENBW 校正）
%   5. 多线路汇总对比表 + 6 张汇总图
%
% 依赖外部文件：tight_subplot.m（可选，仅序分量图时需要）

clear; close all; clc;

% 获取脚本所在目录（防止 clear 后 pwd 失效）
SCRIPT_DIR = fileparts(mfilename('fullpath'));
if isempty(SCRIPT_DIR), SCRIPT_DIR = pwd; end

%% ==================== 用户定义区 ====================

RootDir = '../02-fault_rec_data/故障波形/';

% ----- 文件与线路配置 -----
% Files(iFile).path:       CSV 文件名（相对于 RootDir）
% Files(iFile).line_names: 该文件中要分析的线路名称（需与 CSV 列名中的线路名匹配）
% Files(iFile).t_start:    (可选) 该文件的数据起始秒数，默认取全局 T_START_SEC
Files(1).path = '甲母2026-05-28@16-06-44-07-18.csv';
Files(1).line_names = {'2212水谢一线', '2213水谢二线', '2214水蒿线', '2215水簸线', '2216水令线'};
Files(1).t_start = 80;
Files(2).path = '乙母2026-05-28@16-06-44-07-44.csv';
Files(2).line_names = {'2220水盖线', '2221水驹线', '2222水升线', '2219水班线'};
Files(2).t_start = 80-(44.894000-18.473000);

% ----- 加窗选项 -----
% 'none' = 矩形窗（与 da01 相同）；'kaiser' = 凯泽窗；'hann' = Hann 窗
WINDOW_TYPE = 'kaiser';
KAISER_BETA = 8;       % 仅 WINDOW_TYPE='kaiser' 时生效，β=14 旁瓣衰减 > -100 dB

% ----- 频率模式 -----
FREQ_MODE = 'auto';     % 'manual' = 手动给定频率；'auto' = 正序电流谱自动寻峰

% 手动模式参数（FREQ_MODE='manual' 时生效）
MANUAL_LOW_FREQ  = 37.9;    % 次同步目标频率 (Hz)
MANUAL_HIGH_FREQ = 62.1;    % 超同步目标频率 (Hz)

% 自动寻峰参数（FREQ_MODE='auto' 时生效）
LOW_REF_FREQ    = 37.5;     % 次同步参考频率 (Hz)，在 ±FREQ_TOL 内搜索
HIGH_REF_FREQ   = 62.2;     % 超同步参考频率 (Hz)，在 ±FREQ_TOL 内搜索
FREQ_TOL        = 1;        % 搜索半径 (Hz)
BAND_HALF_WIDTH = 0.5;      % 自动模式下频带半宽 (Hz)，用于功率积分

% ----- 公共分析参数 -----
BASE_FREQ       = 50;       % 基波频率 (Hz)
BASE_BAND       = [49, 51]; % 基波频带 [下限, 上限] Hz
SAMPLE_FREQ     = 1000;     % 采样率 (Hz)
T_SPAN          = 10;       % 分析时长 (秒)
T_START_SEC     = 0;        % 默认数据起始偏移 (秒)，可被 Files(iFile).t_start 覆盖

% ----- 绘图开关 -----
DRAW_DETAIL_PLOTS = true;   % 每条线路的 V/I 频谱图
DRAW_SEQ_PLOTS    = false;  % 每条线路的 4×3 序分量宫格图（依赖 tight_subplot.m）
DRAW_SUMMARY_PLOTS = true;  % 多线路汇总对比图
SAVE_FIGURES      = true;   % 保存图形为 PNG
OUTPUT_FOLDER     = '../04-fault_recorder/output_da02/';  % 图片/表格保存目录
SAVE_XLSX         = true;   % 保存汇总表为 xlsx（含中文表头）

% ----- 显示参数 -----
PLOT_FREQ_RANGE = [1, 100];     % 频谱图频率轴范围
SUBPLOT_FONT_SIZE = 10;         % 序分量图字体大小

%% ==================== 初始化 ====================

if SAVE_FIGURES || SAVE_XLSX
    outputFull = fullfile(SCRIPT_DIR, OUTPUT_FOLDER);
    if ~exist(outputFull, 'dir')
        mkdir(outputFull);
    end
end

% 检查 tight_subplot 是否存在
HAS_TIGHT_SUBPLOT = (exist('tight_subplot', 'file') == 2);
if DRAW_SEQ_PLOTS && ~HAS_TIGHT_SUBPLOT
    warning('tight_subplot.m 未找到，序分量图将使用普通 subplot');
end

% 汇总表列索引说明：
%  1:线路名称           2:次同步频率_Hz        3:次同步电流_基波%
%  4:次同步电压_基波%    5:次同步阻抗实部_ohm    6:次同步阻抗虚部_ohm
%  7:超同步频率_Hz       8:超同步电流_基波%      9:超同步电压_基波%
% 10:超同步阻抗实部_ohm  11:超同步阻抗虚部_ohm   12:基波P_W（单点）
% 13:基波Q_var（单点）   14:总实时有功_W         15:次同步频带P_W
% 16:次同步频带Q_var     17:基波频带P_W          18:基波频带Q_var
% 19:超同步频带P_W       20:超同步频带Q_var
AllSummary = {};

% 匿名工具函数
f_MagAngle2Imag = @(arg_mag, arg_angle) arg_mag .* exp(1i .* arg_angle);

%% ==================== 主循环：文件 × 线路 ====================

for iFile = 1:length(Files)
    MatUrl = fullfile(RootDir, Files(iFile).path);
    LINE_NAMES = Files(iFile).line_names;
    t_start = T_START_SEC;  % 全局默认
    if isfield(Files(iFile), 't_start')
        t_start = Files(iFile).t_start;
    end

    fprintf('\n');
    fprintf('####################################################################\n');
    fprintf('处理文件：%s  (起始偏移 %d 秒)\n', Files(iFile).path, t_start);
    fprintf('包含线路：%s\n', strjoin(LINE_NAMES, ', '));
    fprintf('####################################################################\n');

    % ---- 读 CSV，获取列名 ----
    RawData = table2array(readtable(MatUrl, 'PreserveVariableNames', true));
    TblMeta = readtable(MatUrl, 'PreserveVariableNames', true, 'ReadVariableNames', true);
    colNames = TblMeta.Properties.VariableNames;
    colNamesClean = cellfun(@(x) strrep(x, ' ', ''), colNames, 'UniformOutput', false);

    % 列名匹配辅助函数
    findColIdx = @(lineName, quantity) find(contains(colNamesClean, ...
        [strrep(lineName, ' ', ''), quantity]), 1);

    N_total = T_SPAN * SAMPLE_FREQ;
    idx_range = (SAMPLE_FREQ * t_start + 1) : (SAMPLE_FREQ * (t_start + T_SPAN));

    % ---- 预计算窗函数 ----
    [w, win_corr, ENBW] = f_prepare_window(N_total, WINDOW_TYPE, KAISER_BETA);
    fprintf('窗函数: %s, ENBW = %.4f\n', WINDOW_TYPE, ENBW);

    for iLine = 1:length(LINE_NAMES)
        line = LINE_NAMES{iLine};

        fprintf('\n========================================\n');
        fprintf('分析线路：%s  (文件: %s)\n', line, Files(iFile).path);
        fprintf('========================================\n');

        % ========== 1. 数据加载（自动列名匹配）==========
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

        USabc = double(RawData(idx_range, [cols.Ua, cols.Ub, cols.Uc]));
        ISabc = double(RawData(idx_range, [cols.Ia, cols.Ib, cols.Ic]));

        % 实时总有功功率（瞬时 u·i 均值）
        P_real_time = mean(sum(USabc .* ISabc, 2));
        fprintf('实时总有功功率 = %.4f W\n', P_real_time);

        % ========== 2. FFT 计算（加窗 + 幅值恢复）==========
        tic;
        [fa,  Ua_mag, Ua_ang, Ua_cplx] = f_fft_windowed(USabc(:,1), SAMPLE_FREQ, N_total, WINDOW_TYPE, KAISER_BETA);
        [~,   Ub_mag, Ub_ang, ~       ] = f_fft_windowed(USabc(:,2), SAMPLE_FREQ, N_total, WINDOW_TYPE, KAISER_BETA);
        [~,   Uc_mag, Uc_ang, ~       ] = f_fft_windowed(USabc(:,3), SAMPLE_FREQ, N_total, WINDOW_TYPE, KAISER_BETA);
        [fia, Ia_mag, Ia_ang, Ia_cplx] = f_fft_windowed(ISabc(:,1), SAMPLE_FREQ, N_total, WINDOW_TYPE, KAISER_BETA);
        [~,   Ib_mag, Ib_ang, ~       ] = f_fft_windowed(ISabc(:,2), SAMPLE_FREQ, N_total, WINDOW_TYPE, KAISER_BETA);
        [~,   Ic_mag, Ic_ang, ~       ] = f_fft_windowed(ISabc(:,3), SAMPLE_FREQ, N_total, WINDOW_TYPE, KAISER_BETA);

        % 相位修正：FFT 余弦基 → 相量正弦参考
        u_mag = [Ua_mag, Ub_mag, Uc_mag];
        u_ang = [Ua_ang, Ub_ang, Uc_ang] + pi/2;
        i_mag = [Ia_mag, Ib_mag, Ic_mag];
        i_ang = [Ia_ang, Ib_ang, Ic_ang] + pi/2;

        % ABC → 正负零序
        u_complex_array = f_MagAngle2Imag(u_mag, u_ang);
        i_complex_array = f_MagAngle2Imag(i_mag, i_ang);
        u_pn0_array = f_seqconv(u_complex_array')';
        i_pn0_array = f_seqconv(i_complex_array')';
        z_pn0_array = u_pn0_array ./ i_pn0_array;

        u_pn0_mag = abs(u_pn0_array);
        u_pn0_ang = angle(u_pn0_array);
        i_pn0_mag = abs(i_pn0_array);
        i_pn0_ang = angle(i_pn0_array);
        z_pn0_mag = abs(z_pn0_array);
        z_pn0_ang = angle(z_pn0_array);

        fprintf('FFT 计算完成，耗时 %.2f 秒\n', toc);

        % ========== 3. 精细频谱扫描（用于寻峰和频带功率）==========
        freqs_fine = (PLOT_FREQ_RANGE(1) : 0.1 : PLOT_FREQ_RANGE(2))';
        nFreqFine = length(freqs_fine);

        I1_mag_fine = zeros(nFreqFine, 1);   % 正序电流幅值（寻峰用）
        P1_fine      = zeros(nFreqFine, 1);   % 正序有功功率谱
        Q1_fine      = zeros(nFreqFine, 1);   % 正序无功功率谱

        fprintf('精细频谱扫描 (%.1f-%.1f Hz, 步长 0.1 Hz)...\n', ...
            PLOT_FREQ_RANGE(1), PLOT_FREQ_RANGE(2));
        tic;
        for k = 1:nFreqFine
            f = freqs_fine(k);

            Ua = get_complex_at_freq_windowed(USabc(:,1), f, SAMPLE_FREQ, w, win_corr);
            Ub = get_complex_at_freq_windowed(USabc(:,2), f, SAMPLE_FREQ, w, win_corr);
            Uc = get_complex_at_freq_windowed(USabc(:,3), f, SAMPLE_FREQ, w, win_corr);
            Ia = get_complex_at_freq_windowed(ISabc(:,1), f, SAMPLE_FREQ, w, win_corr);
            Ib = get_complex_at_freq_windowed(ISabc(:,2), f, SAMPLE_FREQ, w, win_corr);
            Ic = get_complex_at_freq_windowed(ISabc(:,3), f, SAMPLE_FREQ, w, win_corr);

            u_pn0 = f_seqconv([Ua; Ub; Uc]);
            i_pn0 = f_seqconv([Ia; Ib; Ic]);
            Up = u_pn0(1);
            Ip = i_pn0(1);

            I1_mag_fine(k) = abs(Ip);

            theta = angle(Up) - angle(Ip);
            P1_fine(k) = 1.5 * abs(Up) * abs(Ip) * cos(theta);
            Q1_fine(k) = 1.5 * abs(Up) * abs(Ip) * sin(theta);
        end
        fprintf('精细扫描完成，耗时 %.2f 秒\n', toc);

        % ========== 4. 频率确定 ==========
        if strcmpi(FREQ_MODE, 'auto')
            % ---- 自动寻峰：低频 ----
            low_f_lo = max(PLOT_FREQ_RANGE(1), LOW_REF_FREQ - FREQ_TOL);
            low_f_hi = min(PLOT_FREQ_RANGE(2), LOW_REF_FREQ + FREQ_TOL);
            idx_low_search = (freqs_fine >= low_f_lo) & (freqs_fine <= low_f_hi);
            if ~any(idx_low_search)
                warning('低频参考频率 %.2f Hz 搜索范围无效，使用参考频率', LOW_REF_FREQ);
                low_freq = LOW_REF_FREQ;
            else
                [~, idx_max] = max(I1_mag_fine(idx_low_search));
                f_sub = freqs_fine(idx_low_search);
                low_freq = f_sub(idx_max);
                fprintf('低频自动寻峰: %.2f Hz (搜索范围 %.2f-%.2f Hz)\n', ...
                    low_freq, low_f_lo, low_f_hi);
            end

            % ---- 自动寻峰：高频 ----
            high_f_lo = max(PLOT_FREQ_RANGE(1), HIGH_REF_FREQ - FREQ_TOL);
            high_f_hi = min(PLOT_FREQ_RANGE(2), HIGH_REF_FREQ + FREQ_TOL);
            idx_high_search = (freqs_fine >= high_f_lo) & (freqs_fine <= high_f_hi);
            if ~any(idx_high_search)
                warning('高频参考频率 %.2f Hz 搜索范围无效，使用参考频率', HIGH_REF_FREQ);
                high_freq = HIGH_REF_FREQ;
            else
                [~, idx_max] = max(I1_mag_fine(idx_high_search));
                f_sub = freqs_fine(idx_high_search);
                high_freq = f_sub(idx_max);
                fprintf('高频自动寻峰: %.2f Hz (搜索范围 %.2f-%.2f Hz)\n', ...
                    high_freq, high_f_lo, high_f_hi);
            end

            % 根据中心频率确定频带范围
            low_band_lo  = low_freq  - BAND_HALF_WIDTH;
            low_band_hi  = low_freq  + BAND_HALF_WIDTH;
            high_band_lo = high_freq - BAND_HALF_WIDTH;
            high_band_hi = high_freq + BAND_HALF_WIDTH;
        else
            % ---- 手动模式 ----
            low_freq  = MANUAL_LOW_FREQ;
            high_freq = MANUAL_HIGH_FREQ;
            low_band_lo  = MANUAL_LOW_FREQ  - BAND_HALF_WIDTH;
            low_band_hi  = MANUAL_LOW_FREQ  + BAND_HALF_WIDTH;
            high_band_lo = MANUAL_HIGH_FREQ - BAND_HALF_WIDTH;
            high_band_hi = MANUAL_HIGH_FREQ + BAND_HALF_WIDTH;
            fprintf('手动模式: 次同步频率 %.2f Hz, 超同步频率 %.2f Hz\n', low_freq, high_freq);
        end

        fprintf('频带范围: 次同步 [%.2f, %.2f], 基波 [%.0f, %.0f], 超同步 [%.2f, %.2f] Hz\n', ...
            low_band_lo, low_band_hi, BASE_BAND(1), BASE_BAND(2), high_band_lo, high_band_hi);

        % ========== 5. 单频点精确计算（P, Q, R, X, Z）==========
        f_sel_list = [low_freq, BASE_FREQ, high_freq];
        Up_mags = zeros(3,1);
        Ip_mags = zeros(3,1);
        P_single = zeros(3,1);
        Q_single = zeros(3,1);
        R_vals   = zeros(3,1);
        X_vals   = zeros(3,1);
        Zp_vals  = complex(zeros(3,1));

        for idx = 1:3
            f_sel = f_sel_list(idx);

            Ua = get_complex_at_freq_windowed(USabc(:,1), f_sel, SAMPLE_FREQ, w, win_corr);
            Ub = get_complex_at_freq_windowed(USabc(:,2), f_sel, SAMPLE_FREQ, w, win_corr);
            Uc = get_complex_at_freq_windowed(USabc(:,3), f_sel, SAMPLE_FREQ, w, win_corr);
            Ia = get_complex_at_freq_windowed(ISabc(:,1), f_sel, SAMPLE_FREQ, w, win_corr);
            Ib = get_complex_at_freq_windowed(ISabc(:,2), f_sel, SAMPLE_FREQ, w, win_corr);
            Ic = get_complex_at_freq_windowed(ISabc(:,3), f_sel, SAMPLE_FREQ, w, win_corr);

            u_pn0 = f_seqconv([Ua; Ub; Uc]);
            i_pn0 = f_seqconv([Ia; Ib; Ic]);
            Up = u_pn0(1);
            Ip = i_pn0(1);

            Up_mags(idx) = abs(Up);
            Ip_mags(idx) = abs(Ip);

            theta = angle(Up) - angle(Ip);
            P_single(idx) = 1.5 * abs(Up) * abs(Ip) * cos(theta);
            Q_single(idx) = 1.5 * abs(Up) * abs(Ip) * sin(theta);

            Zp = Up / Ip;
            Zp_vals(idx) = Zp;
            R_vals(idx)   = real(Zp);
            X_vals(idx)   = imag(Zp);
        end

        % 打印单点结果
        fprintf('\n----- 单频点计算结果 -----\n');
        fprintf('  频点         |  Up (V)   Ip (A)    P (W)      Q (var)    R (ohm)   X (ohm)\n');
        fprintf('  %6.2f Hz (次) | %8.2f %8.4f %10.4f %10.4f %9.4f %9.4f\n', ...
            f_sel_list(1), Up_mags(1), Ip_mags(1), P_single(1), Q_single(1), R_vals(1), X_vals(1));
        fprintf('  %6.2f Hz (基) | %8.2f %8.4f %10.4f %10.4f %9.4f %9.4f\n', ...
            f_sel_list(2), Up_mags(2), Ip_mags(2), P_single(2), Q_single(2), R_vals(2), X_vals(2));
        fprintf('  %6.2f Hz (超) | %8.2f %8.4f %10.4f %10.4f %9.4f %9.4f\n', ...
            f_sel_list(3), Up_mags(3), Ip_mags(3), P_single(3), Q_single(3), R_vals(3), X_vals(3));

        % ========== 6. 频带功率积分（ENBW 校正）==========
        idx_base_band = (freqs_fine >= BASE_BAND(1)) & (freqs_fine <= BASE_BAND(2));
        P_base_band = sum(P1_fine(idx_base_band)) / ENBW;
        Q_base_band = sum(Q1_fine(idx_base_band)) / ENBW;

        idx_low_band  = (freqs_fine >= low_band_lo)  & (freqs_fine <= low_band_hi);
        P_low_band  = sum(P1_fine(idx_low_band))  / ENBW;
        Q_low_band  = sum(Q1_fine(idx_low_band))  / ENBW;

        idx_high_band = (freqs_fine >= high_band_lo) & (freqs_fine <= high_band_hi);
        P_high_band = sum(P1_fine(idx_high_band)) / ENBW;
        Q_high_band = sum(Q1_fine(idx_high_band)) / ENBW;

        fprintf('\n----- 频带积分功率 (ENBW=%.4f 校正后) -----\n', ENBW);
        fprintf('  次同步频带 [%.2f,%.2f] Hz: P = %.4f W, Q = %.4f var\n', ...
            low_band_lo, low_band_hi, P_low_band, Q_low_band);
        fprintf('  基波频带   [%.0f,%.0f] Hz: P = %.4f W, Q = %.4f var\n', ...
            BASE_BAND(1), BASE_BAND(2), P_base_band, Q_base_band);
        fprintf('  超同步频带 [%.2f,%.2f] Hz: P = %.4f W, Q = %.4f var\n', ...
            high_band_lo, high_band_hi, P_high_band, Q_high_band);

        % ========== 7. 每条线路绘图 ==========
        if DRAW_DETAIL_PLOTS || DRAW_SEQ_PLOTS

            % ----- 7a. V/I 频谱图 -----
            if DRAW_DETAIL_PLOTS
                LEFT_POS = 5; BOTTOM_POS = 1; WIDTH_NUM = 12; HEIGHT_NUM = 15;

                % 电压频谱
                figure('Name', sprintf('%s 电压频谱', line));
                subplot(3,1,1)
                plot(fa, Ua_mag, 'LineWidth', 1.5); grid on;
                xlabel('频率 (Hz)'); ylabel('U (V)'); title(sprintf('%s - Ua', line));
                xlim(PLOT_FREQ_RANGE);
                subplot(3,1,2)
                plot(fa, Ub_mag, 'LineWidth', 1.5); grid on;
                xlabel('频率 (Hz)'); ylabel('U (V)'); title(sprintf('%s - Ub', line));
                xlim(PLOT_FREQ_RANGE);
                subplot(3,1,3)
                plot(fa, Uc_mag, 'LineWidth', 1.5); grid on;
                xlabel('频率 (Hz)'); ylabel('U (V)'); title(sprintf('%s - Uc', line));
                xlim(PLOT_FREQ_RANGE);
                set(gcf, 'unit', 'centimeters', 'position', [LEFT_POS, BOTTOM_POS, WIDTH_NUM, HEIGHT_NUM]);

                % 电流频谱
                figure('Name', sprintf('%s 电流频谱', line));
                subplot(3,1,1)
                plot(fia, Ia_mag, 'LineWidth', 1.5); grid on;
                xlabel('频率 (Hz)'); ylabel('I (A)'); title(sprintf('%s - Ia', line));
                xlim(PLOT_FREQ_RANGE);
                subplot(3,1,2)
                plot(fia, Ib_mag, 'LineWidth', 1.5); grid on;
                xlabel('频率 (Hz)'); ylabel('I (A)'); title(sprintf('%s - Ib', line));
                xlim(PLOT_FREQ_RANGE);
                subplot(3,1,3)
                plot(fia, Ic_mag, 'LineWidth', 1.5); grid on;
                xlabel('频率 (Hz)'); ylabel('I (A)'); title(sprintf('%s - Ic', line));
                xlim(PLOT_FREQ_RANGE);
                set(gcf, 'unit', 'centimeters', 'position', [LEFT_POS, BOTTOM_POS, WIDTH_NUM, HEIGHT_NUM]);
            end

            % ----- 7b. 4×3 序分量宫格图 -----
            if DRAW_SEQ_PLOTS
                figure('Name', sprintf('%s 序分量', line));
                if HAS_TIGHT_SUBPLOT
                    [ha, ~] = tight_subplot(4, 3, [0.06, 0.04], [0.03, 0.03], [0.04, 0.01]);
                    set(gcf, 'unit', 'centimeters', 'position', [0.5, 1, 45, 20]);
                end
                titles_12 = {
                    'U Pos Mag',  'U Neg Mag',  'Z Pos Mag';
                    'U Pos Phase', 'U Neg Phase', 'Z Pos Phase';
                    'I Pos Mag',  'I Neg Mag',  'Z Neg Mag';
                    'I Pos Phase', 'I Neg Phase', 'Z Neg Phase'};
                for hidx = 1:12
                    if HAS_TIGHT_SUBPLOT
                        axes(ha(hidx));
                    else
                        subplot(4, 3, hidx);
                    end
                    switch hidx
                        case 1
                            plot(fa, u_pn0_mag(:,1)); grid on;
                        case 2
                            plot(fa, u_pn0_mag(:,2)); grid on;
                        case 3
                            plot(fa, z_pn0_mag(:,1)); grid on;
                        case 4
                            plot(fa, u_pn0_ang(:,1)*180/pi); grid on;
                        case 5
                            plot(fa, u_pn0_ang(:,2)*180/pi); grid on;
                        case 6
                            plot(fa, z_pn0_ang(:,1)*180/pi); grid on;
                        case 7
                            plot(fa, i_pn0_mag(:,1)); grid on;
                        case 8
                            plot(fa, i_pn0_mag(:,2)); grid on;
                        case 9
                            plot(fa, z_pn0_mag(:,2)); grid on;
                        case 10
                            plot(fa, i_pn0_ang(:,1)*180/pi); grid on;
                        case 11
                            plot(fa, i_pn0_ang(:,2)*180/pi); grid on;
                        case 12
                            plot(fa, z_pn0_ang(:,2)*180/pi); grid on;
                    end
                    [r, c] = ind2sub([4,3], hidx);
                    title(titles_12{r, c});
                    xlim(PLOT_FREQ_RANGE);
                    set(gca, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE);
                end
                sgtitle(sprintf('%s — 序分量频谱', line));
            end
        end

        % ========== 8. 存入汇总数组 ==========
        low_I_pct  = (Ip_mags(1) / Ip_mags(2)) * 100;
        low_U_pct  = (Up_mags(1) / Up_mags(2)) * 100;
        high_I_pct = (Ip_mags(3) / Ip_mags(2)) * 100;
        high_U_pct = (Up_mags(3) / Up_mags(2)) * 100;

        currentRow = {line, ...
            low_freq,  low_I_pct,  low_U_pct,  R_vals(1), X_vals(1), ...
            high_freq, high_I_pct, high_U_pct, R_vals(3), X_vals(3), ...
            P_single(2), Q_single(2), P_real_time, ...
            P_low_band, Q_low_band, P_base_band, Q_base_band, P_high_band, Q_high_band};
        AllSummary = [AllSummary; currentRow];
    end
end

%% ==================== 汇总输出 ====================

if isempty(AllSummary)
    warning('没有成功分析任何线路。');
    return;
end

% ----- 汇总表 -----
SummaryTable = cell2table(AllSummary, ...
    'VariableNames', {'线路名称', ...
    '次同步频率_Hz', '次同步电流_基波百分比', '次同步电压_基波百分比', ...
    '次同步阻抗实部_ohm', '次同步阻抗虚部_ohm', ...
    '超同步频率_Hz', '超同步电流_基波百分比', '超同步电压_基波百分比', ...
    '超同步阻抗实部_ohm', '超同步阻抗虚部_ohm', ...
    '基波P_W', '基波Q_var', '总实时有功_W', ...
    '次同步频带P_W', '次同步频带Q_var', ...
    '基波频带P_W', '基波频带Q_var', ...
    '超同步频带P_W', '超同步频带Q_var'});

fprintf('\n\n========== 所有线路分析汇总 ==========\n');
disp(SummaryTable);

% 导出 xlsx（中文表头完整保留，可用 Excel 打开）
if SAVE_XLSX
    xlsxPath = fullfile(outputFull, '分析汇总.xlsx');
    writetable(SummaryTable, xlsxPath);
    fprintf('汇总表已保存: %s\n', xlsxPath);
end

% ----- 汇总图 -----
if DRAW_SUMMARY_PLOTS
    nLines = size(AllSummary, 1);
    lineNames = AllSummary(:, 1);
    baseP_single  = cell2mat(AllSummary(:, 12));
    baseP_band    = cell2mat(AllSummary(:, 17));
    lowP_band     = cell2mat(AllSummary(:, 15));
    highP_band    = cell2mat(AllSummary(:, 19));
    lowI_pct_all  = cell2mat(AllSummary(:, 3));
    lowU_pct_all  = cell2mat(AllSummary(:, 4));
    highI_pct_all = cell2mat(AllSummary(:, 8));
    highU_pct_all = cell2mat(AllSummary(:, 9));
    lowR_all      = cell2mat(AllSummary(:, 5));
    lowX_all      = cell2mat(AllSummary(:, 6));
    highR_all     = cell2mat(AllSummary(:, 10));
    highX_all     = cell2mat(AllSummary(:, 11));

    % 基波功率足够大的线路才纳入占比/阻抗图（排除接近零的线路）
    validIdx = abs(baseP_single) >= 2;
    lineNames_v = lineNames(validIdx);
    nValid = sum(validIdx);

    xTicks = 1:nLines;

    % ---- 图1：基波频带功率 ----
    fig1 = figure('Name', '基波频带功率');
    bar(xTicks, abs(baseP_band), 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'k', 'LineWidth', 1.2);
    set(gca, 'XTick', xTicks, 'XTickLabel', lineNames, 'XTickLabelRotation', 45, 'FontSize', 10);
    xlabel('线路名称'); ylabel('功率 (W)');
    title(sprintf('基波频带功率 [%.0f-%.0f Hz] ENBW校正后', BASE_BAND(1), BASE_BAND(2)));
    grid on; box off;

    if nValid > 0
        xTicksV = 1:nValid;

        % ---- 图2：次/超同步电压占比 ----
        fig2 = figure('Name', '谐波电压占比');
        b = bar(xTicksV, [lowU_pct_all(validIdx), highU_pct_all(validIdx)], 'grouped');
        b(1).FaceColor = [0.85 0.33 0.10]; b(2).FaceColor = [0.00 0.45 0.74];
        set(gca, 'XTick', xTicksV, 'XTickLabel', lineNames_v, 'XTickLabelRotation', 45);
        xlabel('线路名称'); ylabel('电压占比 (%)');
        title('次同步 / 超同步电压幅值占基波百分比');
        legend('次同步电压 (%)', '超同步电压 (%)', 'Location', 'best');
        grid on; box off;

        % ---- 图3：次/超同步电流占比 ----
        fig3 = figure('Name', '谐波电流占比');
        b = bar(xTicksV, [lowI_pct_all(validIdx), highI_pct_all(validIdx)], 'grouped');
        b(1).FaceColor = [0.85 0.33 0.10]; b(2).FaceColor = [0.00 0.45 0.74];
        set(gca, 'XTick', xTicksV, 'XTickLabel', lineNames_v, 'XTickLabelRotation', 45);
        xlabel('线路名称'); ylabel('电流占比 (%)');
        title('次同步 / 超同步电流幅值占基波百分比');
        legend('次同步电流 (%)', '超同步电流 (%)', 'Location', 'best');
        grid on; box off;

        % ---- 图4：谐波频带功率 ----
        fig4 = figure('Name', '谐波频带功率');
        b = bar(xTicksV, [lowP_band(validIdx), highP_band(validIdx)], 'grouped');
        b(1).FaceColor = [0.85 0.33 0.10]; b(2).FaceColor = [0.00 0.45 0.74];
        set(gca, 'XTick', xTicksV, 'XTickLabel', lineNames_v, 'XTickLabelRotation', 45);
        xlabel('线路名称'); ylabel('功率 (W)');
        title('次同步频带功率 vs 超同步频带功率 (ENBW校正)');
        legend('次同步频带 P (W)', '超同步频带 P (W)', 'Location', 'best');
        grid on; box off;

        % ---- 图5：次同步阻抗极坐标 ----
        fig5 = figure('Name', '次同步阻抗极坐标');
        Z_low = lowR_all(validIdx) + 1j * lowX_all(validIdx);
        pax = polaraxes;
        hold on;
        colors = lines(nValid);
        h_low = gobjects(nValid, 1);
        for i = 1:nValid
            h_low(i) = polarscatter(pax, angle(Z_low(i)), abs(Z_low(i)), ...
                100, colors(i,:), 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.2);
        end
        title(pax, '次同步频率正序阻抗（极坐标）');
        pax.ThetaZeroLocation = 'right';
        pax.ThetaDir = 'counterclockwise';
        legend(h_low, lineNames_v, 'Location', 'bestoutside');
        hold off;

        % ---- 图6：超同步阻抗极坐标 ----
        fig6 = figure('Name', '超同步阻抗极坐标');
        Z_high = highR_all(validIdx) + 1j * highX_all(validIdx);
        pax = polaraxes;
        hold on;
        h_high = gobjects(nValid, 1);
        for i = 1:nValid
            h_high(i) = polarscatter(pax, angle(Z_high(i)), abs(Z_high(i)), ...
                100, colors(i,:), 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.2);
        end
        title(pax, '超同步频率正序阻抗（极坐标）');
        pax.ThetaZeroLocation = 'right';
        pax.ThetaDir = 'counterclockwise';
        legend(h_high, lineNames_v, 'Location', 'bestoutside');
        hold off;
    end

    % ----- PNG 保存 -----
    if SAVE_FIGURES
        % 遍历当前所有 figure 并保存
        allFigs = findall(0, 'Type', 'figure');
        for iFig = 1:length(allFigs)
            figName = get(allFigs(iFig), 'Name');
            if isempty(figName), figName = sprintf('fig_%02d', iFig); end
            % 仅替换文件系统非法字符，保留中文
            safeName = regexprep(figName, '[/\\:*?"<>|]', '_');
            filename = fullfile(outputFull, [safeName, '.png']);
            exportgraphics(allFigs(iFig), filename, 'Resolution', 300);
            fprintf('已保存: %s\n', filename);
        end
    end
end

fprintf('\n===== 脚本运行完成 =====\n');

%% ==================== 局部函数 ====================

function [w, win_corr, ENBW] = f_prepare_window(N, window_type, kaiser_beta)
    % 预计算窗函数及其系数
    % 输入:
    %   N           - 信号长度
    %   window_type - 'none' | 'kaiser' | 'hann'
    %   kaiser_beta - Kaiser 窗 β 参数
    % 输出:
    %   w       - 窗函数向量 (N×1)
    %   win_corr - 峰值恢复系数 (2 / sum(w)), 用于单频点幅值修正
    %   ENBW    - 等效噪声带宽, 用于频带功率校正

    switch lower(window_type)
        case 'none'
            w = ones(N, 1);
        case 'kaiser'
            w = kaiser(N, kaiser_beta);
        case 'hann'
            w = hann(N);
        otherwise
            error('不支持的窗类型: %s。可选: none, kaiser, hann', window_type);
    end

    win_corr = 2 / sum(w);                    % 峰值振幅恢复系数
    ENBW = N * sum(w.^2) / (sum(w))^2;        % 等效噪声带宽
end

function cplx = get_complex_at_freq_windowed(signal, freq, fs, w, win_corr)
    % 使用预定义窗函数在任意频率处提取复数幅值（峰值）
    % 输入:
    %   signal   - 原始时域信号 (N×1)
    %   freq     - 目标频率 (Hz)
    %   fs       - 采样率 (Hz)
    %   w        - 窗函数 (N×1)
    %   win_corr - 峰值恢复系数
    % 输出:
    %   cplx - 复数幅值 (峰值)

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

function [f_axis, mag, ang, cplx] = f_fft_windowed(signal, fs, Nfft, window_type, kaiser_beta)
    % 标准 FFT + 加窗 + 幅值恢复（增强版 f_fft_simple）
    % 输入:
    %   signal      - 时域信号 (N×1)
    %   fs          - 采样率 (Hz), int64 或 double
    %   Nfft        - FFT 点数
    %   window_type - 'none' | 'kaiser' | 'hann'
    %   kaiser_beta - Kaiser β（仅 Kaiser 窗时使用）
    % 输出:
    %   f_axis - 单边频率轴 (Hz)
    %   mag    - 单边幅值谱（峰值, 已做窗幅值恢复）
    %   ang    - 单边相位谱 (rad)
    %   cplx   - 单边复数谱

    signal = double(signal(:));
    fs = double(fs);

    % 加窗
    switch lower(window_type)
        case 'none'
            win = ones(Nfft, 1);
        case 'kaiser'
            win = kaiser(Nfft, kaiser_beta);
        case 'hann'
            win = hann(Nfft);
        otherwise
            error('不支持的窗类型: %s', window_type);
    end

    signal_w = signal .* win;
    S = fft(signal_w, Nfft) / Nfft;           % 双边谱（除以 N 归一化）
    S_unilateral = S(1 : floor(Nfft/2)+1);    % 单边谱
    S_unilateral(2:end-1) = 2 * S_unilateral(2:end-1);

    % 幅值恢复：除以窗的相干增益
    coherent_gain = mean(win);
    S_unilateral = S_unilateral / coherent_gain;

    f_axis = fs * double(0:floor(Nfft/2))' / Nfft;
    mag  = abs(S_unilateral);
    ang  = angle(S_unilateral);
    cplx = S_unilateral;
end

function V120 = f_seqconv(Vabc)
    % ABC 三相 → 正序/负序/零序 变换
    % 输入:
    %   Vabc - 3×M 矩阵，每列为 [A; B; C] 复数相量
    % 输出:
    %   V120 - 3×M 矩阵，每列为 [正序; 负序; 零序]

    a = exp(1j * 2 * pi / 3);
    A = 1/3 * [1, a, a^2; 1, a^2, a; 1, 1, 1];
    V120 = A * Vabc;
end
