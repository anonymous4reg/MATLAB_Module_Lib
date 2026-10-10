%% 多文件多线路自动分析 - 凯泽窗（ENBW校正，频带功率正确）
% 功能：
%   1. 支持手动指定次同步/超同步频带（例如 [38,39] Hz 和 [61,62] Hz）
%   2. 支持自动寻峰：分别在高频参考频率和低频参考频率附近搜索正序电流峰值
%   3. 使用凯泽窗（β=14）进行精细频谱提取，基波泄漏衰减 > -100 dB
%   4. 通过等效噪声带宽（ENBW）校正频带功率，使积分结果等于真实功率
%   5. 计算次/超同步频率点的正序阻抗，以及实时有功功率
%   6. 绘制6张汇总图，并自动保存所有图形为PNG文件
close all; clc;clear;

%% ========== 用户定义区 ==========
Files(1).path = '2026-04-22@16-11-00.000000甲.csv';
Files(1).line_names = {'2212水谢一线', '2213水谢二线', '2214水蒿线', '2215水簸线', '2216水令线'};
Files(2).path = '2026-04-22@16-11-00.000000乙.csv';
Files(2).line_names = {'2220水盖线', '2221水驹线', '2222水升线', '2219水班线'};

USE_MANUAL_BANDS = false;               % true:手动频带; false:自动寻峰

% 手动指定频带（仅在 USE_MANUAL_BANDS = true 时生效）
MANUAL_LOW_BAND = [38, 39];            % 次同步频带 [下限,上限] Hz
MANUAL_HIGH_BAND = [62, 63];           % 超同步频带 [下限,上限] Hz

% 自动寻峰参数（仅在 USE_MANUAL_BANDS = false 时生效）
LOW_REF_FREQ = 37.5;                   % 低频参考频率 (Hz)，程序会在 ±FREQ_TOL 内搜索峰值
HIGH_REF_FREQ = 62.2;                  % 高频参考频率 (Hz)，程序会在 ±FREQ_TOL 内搜索峰值
FREQ_TOL = 1;                          % 搜索半径 (Hz)
BAND_HALF_WIDTH = 0.5;                 % 自动模式下频带半宽 (Hz)，用于功率积分

% 公共参数
BASE_BAND = [49, 51];                  % 基波频带 [Hz]
SAMPLE_FREQ = 1000;                    % 采样率 (Hz)
T_SPAN = 10;                           % 分析时长 (秒)
DRAW_FIGURES = true;                   % 是否显示绘制的图形窗口（保留，不影响保存）
PLOT_FREQ_RANGE = [1, 100];            % 频谱图频率范围

% 图片保存设置
SAVE_FIGURES = false;                   % 是否保存图形为PNG
OUTPUT_FOLDER = './第二次';  % 图片保存目录（自动创建）

KAISER_BETA = 14;                      % 凯泽窗参数，旁瓣衰减 > -100 dB

% 创建输出文件夹
if SAVE_FIGURES && ~exist(OUTPUT_FOLDER, 'dir')
    mkdir(OUTPUT_FOLDER);
end

%% ========== 初始化汇总表 ==========
% 列索引说明：
% 1:线路名称
% 2:次同步频率_Hz（中心频率）
% 3:次同步电流_基波百分比
% 4:次同步电压_基波百分比
% 5:次同步阻抗实部_ohm
% 6:次同步阻抗虚部_ohm
% 7:超同步频率_Hz（中心频率）
% 8:超同步电流_基波百分比
% 9:超同步电压_基波百分比
% 10:超同步阻抗实部_ohm
% 11:超同步阻抗虚部_ohm
% 12:基波功率_W（单点，用于筛选）
% 13:总实时有功功率_W
% 14:次同步频带功率_W（ENBW校正后）
% 15:基波频带功率_W（ENBW校正后）
% 16:超同步频带功率_W（ENBW校正后）
AllSummary = {};

%% ========== 主循环 ==========
for iFile = 1:length(Files)
    MatUrl = Files(iFile).path;
    LINE_NAMES = Files(iFile).line_names;
    fprintf('\n\n####################################################################\n');
    fprintf('正在处理文件：%s\n', MatUrl);
    fprintf('包含线路：%s\n', strjoin(LINE_NAMES, ', '));
    fprintf('####################################################################\n');
    
    % 读取数据
    RawData = table2array(readtable(MatUrl, 'PreserveVariableNames', true));
    colNames = readtable(MatUrl, 'PreserveVariableNames', true, 'ReadVariableNames', true);
    colNames = colNames.Properties.VariableNames;
    colNamesClean = cellfun(@(x) strrep(x, ' ', ''), colNames, 'UniformOutput', false);
    findColIdx = @(lineName, quantity) find(contains(colNamesClean, [strrep(lineName,' ',''), quantity]), 1);
    
    for iLine = 1:length(LINE_NAMES)
        line = LINE_NAMES{iLine};
        fprintf('\n========================================\n');
        fprintf('正在分析线路：%s (文件: %s)\n', line, MatUrl);
        fprintf('========================================\n');
        
        % 查找电压电流列索引
        Ua_idx = findColIdx(line, 'Ua');
        Ub_idx = findColIdx(line, 'Ub');
        Uc_idx = findColIdx(line, 'Uc');
        Ia_idx = findColIdx(line, 'Ia');
        Ib_idx = findColIdx(line, 'Ib');
        Ic_idx = findColIdx(line, 'Ic');
        if any([Ua_idx, Ub_idx, Uc_idx, Ia_idx, Ib_idx, Ic_idx] == 0)
            warning('线路 %s 数据列不完整，跳过', line);
            continue;
        end
        
        USabc = double(RawData(:, [Ua_idx, Ub_idx, Uc_idx]));
        ISabc = double(RawData(:, [Ia_idx, Ib_idx, Ic_idx]));
        N = T_SPAN * SAMPLE_FREQ;
        if size(USabc,1) < N
            warning('数据长度不足 %d 点，跳过', N);
            continue;
        end
        USabc = USabc(1:N, :);
        ISabc = ISabc(1:N, :);
        
        % 实时有功功率
        P_real_time = mean(sum(USabc .* ISabc, 2));
        fprintf('实时总有功功率 = %.4f W\n', P_real_time);
        
        %% 精细频谱计算（凯泽窗，步长0.1Hz）
        freqs = PLOT_FREQ_RANGE(1):0.1:PLOT_FREQ_RANGE(2);
        nFreq = length(freqs);
        Ua_mag_fine = zeros(nFreq,1);
        Ub_mag_fine = zeros(nFreq,1);
        Uc_mag_fine = zeros(nFreq,1);
        Ia_mag_fine = zeros(nFreq,1);
        Ib_mag_fine = zeros(nFreq,1);
        Ic_mag_fine = zeros(nFreq,1);
        I1_mag_fine = zeros(nFreq,1);   % 正序电流幅值（用于寻峰）
        P1_fine = zeros(nFreq,1);       % 正序有功功率谱（未校正）
        
        % 预计算凯泽窗及系数
        w = kaiser(N, KAISER_BETA);
        win_corr = 2 / sum(w);          % 峰值恢复系数（用于单点幅值）
        % 等效噪声带宽 ENBW
        ENBW = N * sum(w.^2) / (sum(w))^2;
        fprintf('窗函数等效噪声带宽 ENBW = %.4f\n', ENBW);
        
        fprintf('正在使用凯泽窗（β=%d）计算精细频谱及正序功率谱...\n', KAISER_BETA);
        tic;
        for k = 1:nFreq
            f = freqs(k);
            Ua = get_complex_at_freq_windowed(USabc(:,1), f, SAMPLE_FREQ, w, win_corr);
            Ub = get_complex_at_freq_windowed(USabc(:,2), f, SAMPLE_FREQ, w, win_corr);
            Uc = get_complex_at_freq_windowed(USabc(:,3), f, SAMPLE_FREQ, w, win_corr);
            Ia = get_complex_at_freq_windowed(ISabc(:,1), f, SAMPLE_FREQ, w, win_corr);
            Ib = get_complex_at_freq_windowed(ISabc(:,2), f, SAMPLE_FREQ, w, win_corr);
            Ic = get_complex_at_freq_windowed(ISabc(:,3), f, SAMPLE_FREQ, w, win_corr);
            
            Ua_mag_fine(k) = abs(Ua);
            Ub_mag_fine(k) = abs(Ub);
            Uc_mag_fine(k) = abs(Uc);
            Ia_mag_fine(k) = abs(Ia);
            Ib_mag_fine(k) = abs(Ib);
            Ic_mag_fine(k) = abs(Ic);
            
            % 正序电流幅值（用于寻峰）
            i_abc = [Ia; Ib; Ic];
            i_pn0 = f_seqconv(i_abc);
            I1_mag_fine(k) = abs(i_pn0(1));
            
            % 正序有功功率（未校正）
            u_abc = [Ua; Ub; Uc];
            u_pn0 = f_seqconv(u_abc);
            Up = u_pn0(1);
            Ip = i_pn0(1);
            theta = angle(Up) - angle(Ip);
            P1_fine(k) = 1.5 * abs(Up) * abs(Ip) * cos(theta);
        end
        toc;
        
        %% 频率确定（手动或自动）
        if USE_MANUAL_BANDS
            % 手动模式：直接使用用户定义的频带
            low_band_lo = MANUAL_LOW_BAND(1);
            low_band_hi = MANUAL_LOW_BAND(2);
            high_band_lo = MANUAL_HIGH_BAND(1);
            high_band_hi = MANUAL_HIGH_BAND(2);
            low_freq = (low_band_lo + low_band_hi) / 2;
            high_freq = (high_band_lo + high_band_hi) / 2;
            fprintf('手动模式：次同步频带 [%.2f, %.2f] Hz，超同步频带 [%.2f, %.2f] Hz\n', ...
                    low_band_lo, low_band_hi, high_band_lo, high_band_hi);
        else
            % 自动寻峰模式：分别在低频和高频参考频率附近搜索正序电流幅值峰值
            % 低频搜索
            low_f_low = max(PLOT_FREQ_RANGE(1), LOW_REF_FREQ - FREQ_TOL);
            low_f_high = min(PLOT_FREQ_RANGE(2), LOW_REF_FREQ + FREQ_TOL);
            idx_low_range = (freqs >= low_f_low) & (freqs <= low_f_high);
            if ~any(idx_low_range)
                warning('低频参考频率搜索范围无效，使用参考频率');
                low_freq = LOW_REF_FREQ;
            else
                [~, idx_low_max] = max(I1_mag_fine(idx_low_range));
                freq_subset_low = freqs(idx_low_range);
                low_freq = freq_subset_low(idx_low_max);
                fprintf('低频实际峰值频率 = %.2f Hz (搜索范围 %.2f-%.2f Hz)\n', ...
                        low_freq, low_f_low, low_f_high);
            end
            
            % 高频搜索
            high_f_low = max(PLOT_FREQ_RANGE(1), HIGH_REF_FREQ - FREQ_TOL);
            high_f_high = min(PLOT_FREQ_RANGE(2), HIGH_REF_FREQ + FREQ_TOL);
            idx_high_range = (freqs >= high_f_low) & (freqs <= high_f_high);
            if ~any(idx_high_range)
                warning('高频参考频率搜索范围无效，使用参考频率');
                high_freq = HIGH_REF_FREQ;
            else
                [~, idx_high_max] = max(I1_mag_fine(idx_high_range));
                freq_subset_high = freqs(idx_high_range);
                high_freq = freq_subset_high(idx_high_max);
                fprintf('高频实际峰值频率 = %.2f Hz (搜索范围 %.2f-%.2f Hz)\n', ...
                        high_freq, high_f_low, high_f_high);
            end
            
            % 根据搜索到的中心频率定义频带范围（用于功率积分）
            low_band_lo = low_freq - BAND_HALF_WIDTH;
            low_band_hi = low_freq + BAND_HALF_WIDTH;
            high_band_lo = high_freq - BAND_HALF_WIDTH;
            high_band_hi = high_freq + BAND_HALF_WIDTH;
            fprintf('自动模式：次同步频率 %.4f Hz，超同步频率 %.4f Hz\n', low_freq, high_freq);
        end
        fprintf('最终使用的中心频率：低频=%.4f Hz, 工频=50.00 Hz, 高频=%.4f Hz\n', low_freq, high_freq);
        
        %% 频带功率积分（除以 ENBW 校正，使结果等于真实功率）
        idx_base = (freqs >= BASE_BAND(1)) & (freqs <= BASE_BAND(2));
        P_base_band = sum(P1_fine(idx_base)) / ENBW;
        
        idx_low = (freqs >= low_band_lo) & (freqs <= low_band_hi);
        P_low_band = sum(P1_fine(idx_low)) / ENBW;
        
        idx_high = (freqs >= high_band_lo) & (freqs <= high_band_hi);
        P_high_band = sum(P1_fine(idx_high)) / ENBW;
        
        fprintf('基波频带功率 (ENBW校正后) = %.4f W\n', P_base_band);
        fprintf('次同步频带功率 (ENBW校正后) = %.4f W\n', P_low_band);
        fprintf('超同步频带功率 (ENBW校正后) = %.4f W\n', P_high_band);
        
        %% 单点精确计算（用于阻抗及基波功率，无需校正）
        base_freq = 50;
        f_sel_list = [low_freq, base_freq, high_freq];
        Up_mags = zeros(3,1);
        Ip_mags = zeros(3,1);
        P_vals = zeros(3,1);
        R_vals = zeros(3,1);
        X_vals = zeros(3,1);
        for idx = 1:3
            f_sel = f_sel_list(idx);
            Ua = get_complex_at_freq_windowed(USabc(:,1), f_sel, SAMPLE_FREQ, w, win_corr);
            Ub = get_complex_at_freq_windowed(USabc(:,2), f_sel, SAMPLE_FREQ, w, win_corr);
            Uc = get_complex_at_freq_windowed(USabc(:,3), f_sel, SAMPLE_FREQ, w, win_corr);
            Ia = get_complex_at_freq_windowed(ISabc(:,1), f_sel, SAMPLE_FREQ, w, win_corr);
            Ib = get_complex_at_freq_windowed(ISabc(:,2), f_sel, SAMPLE_FREQ, w, win_corr);
            Ic = get_complex_at_freq_windowed(ISabc(:,3), f_sel, SAMPLE_FREQ, w, win_corr);
            u_pn0 = f_seqconv([Ua;Ub;Uc]);
            i_pn0 = f_seqconv([Ia;Ib;Ic]);
            Up = u_pn0(1);
            Ip = i_pn0(1);
            theta = angle(Up) - angle(Ip);
            P = 1.5 * abs(Up) * abs(Ip) * cos(theta);
            Up_mags(idx) = abs(Up);
            Ip_mags(idx) = abs(Ip);
            P_vals(idx) = P;
            Zp = Up / Ip;
            R_vals(idx) = real(Zp);
            X_vals(idx) = imag(Zp);
        end
        
        % 提取结果
        low_freq_val = f_sel_list(1);
        low_I_percent = (Ip_mags(1) / Ip_mags(2)) * 100;
        low_U_percent = (Up_mags(1) / Up_mags(2)) * 100;
        low_R = R_vals(1);
        low_X = X_vals(1);
        
        high_freq_val = f_sel_list(3);
        high_I_percent = (Ip_mags(3) / Ip_mags(2)) * 100;
        high_U_percent = (Up_mags(3) / Up_mags(2)) * 100;
        high_R = R_vals(3);
        high_X = X_vals(3);
        
        base_P = P_vals(2);
        
        %% 绘制每条线路的电压/电流频谱（Y轴上限根据两个振荡频带自动调整）
        if DRAW_FIGURES || SAVE_FIGURES
            idx_low_plot = (freqs >= low_band_lo) & (freqs <= low_band_hi);
            idx_high_plot = (freqs >= high_band_lo) & (freqs <= high_band_hi);
            idx_bands = idx_low_plot | idx_high_plot;
            if any(idx_bands)
                U_band_max = max([max(Ua_mag_fine(idx_bands)), max(Ub_mag_fine(idx_bands)), max(Uc_mag_fine(idx_bands))]);
                I_band_max = max([max(Ia_mag_fine(idx_bands)), max(Ib_mag_fine(idx_bands)), max(Ic_mag_fine(idx_bands))]);
            else
                U_band_max = max([Ua_mag_fine; Ub_mag_fine; Uc_mag_fine]);
                I_band_max = max([Ia_mag_fine; Ib_mag_fine; Ic_mag_fine]);
            end
            U_high = U_band_max * 1.05;
            I_high = I_band_max * 1.05;
            if U_high == 0, U_high = max([Ua_mag_fine; Ub_mag_fine; Uc_mag_fine]) * 1.05; end
            if I_high == 0, I_high = max([Ia_mag_fine; Ib_mag_fine; Ic_mag_fine]) * 1.05; end
            
            % 电压频谱图
            fig_volt = figure('Name', sprintf('%s 电压频谱', line), 'Position', [100,100,500,250], 'Visible', 'off');
            plot(freqs, Ua_mag_fine, 'Color',[0.85,0.33,0.10], 'LineWidth',1.5); hold on;
            plot(freqs, Ub_mag_fine, 'Color',[0.30,0.60,0.20], 'LineWidth',1.5);
            plot(freqs, Uc_mag_fine, 'Color',[0.00,0.45,0.74], 'LineWidth',1.5);
            xlim(PLOT_FREQ_RANGE); grid on; ylim([0, U_high]);
            xlabel('频率 (Hz)'); ylabel('幅值 (V)');
            legend('Ua','Ub','Uc'); title(sprintf('%s 电压频谱', line));
            if SAVE_FIGURES
                filename = fullfile(OUTPUT_FOLDER, sprintf('%s_电压频谱.png', line));
                exportgraphics(fig_volt, filename, 'Resolution', 300);
                fprintf('已保存: %s\n', filename);
            end
            if DRAW_FIGURES
                set(fig_volt, 'Visible', 'on');
            else
                close(fig_volt);
            end
            
            % 电流频谱图
            fig_curr = figure('Name', sprintf('%s 电流频谱', line), 'Position', [100,100,500,250], 'Visible', 'off');
            plot(freqs, Ia_mag_fine, 'Color',[0.85,0.33,0.10], 'LineWidth',1.5); hold on;
            plot(freqs, Ib_mag_fine, 'Color',[0.30,0.60,0.20], 'LineWidth',1.5);
            plot(freqs, Ic_mag_fine, 'Color',[0.00,0.45,0.74], 'LineWidth',1.5);
            xlim(PLOT_FREQ_RANGE); grid on; ylim([0, I_high]);
            xlabel('频率 (Hz)'); ylabel('幅值 (A)');
            legend('Ia','Ib','Ic'); title(sprintf('%s 电流频谱', line));
            if SAVE_FIGURES
                filename = fullfile(OUTPUT_FOLDER, sprintf('%s_电流频谱.png', line));
                exportgraphics(fig_curr, filename, 'Resolution', 300);
                fprintf('已保存: %s\n', filename);
            end
            if DRAW_FIGURES
                set(fig_curr, 'Visible', 'on');
            else
                close(fig_curr);
            end
        end
        
        % 存储到汇总表
        currentRow = {line, ...
                      low_freq_val, low_I_percent, low_U_percent, low_R, low_X, ...
                      high_freq_val, high_I_percent, high_U_percent, high_R, high_X, ...
                      base_P, P_real_time, ...
                      P_low_band, P_base_band, P_high_band};
        AllSummary = [AllSummary; currentRow];
    end
end

%% ========== 输出汇总表 ==========
if ~isempty(AllSummary)
    SummaryTable = cell2table(AllSummary, ...
        'VariableNames', {'线路名称', ...
                          '次同步频率_Hz', '次同步电流_基波百分比', '次同步电压_基波百分比', ...
                          '次同步阻抗实部_ohm', '次同步阻抗虚部_ohm', ...
                          '超同步频率_Hz', '超同步电流_基波百分比', '超同步电压_基波百分比', ...
                          '超同步阻抗实部_ohm', '超同步阻抗虚部_ohm', ...
                          '基波功率_W', '总实时有功功率_W', ...
                          '次同步频带功率_W', '基波频带功率_W', '超同步频带功率_W'});
    fprintf('\n\n========== 所有线路分析汇总（凯泽窗 + ENBW校正） ==========\n');
    disp(SummaryTable);
    
    %% ========== 绘制6张汇总图 ==========
    nLines = size(AllSummary, 1);
    lineNames = AllSummary(:, 1);
    
    basePower_single = cell2mat(AllSummary(:, 12));
    realPower = cell2mat(AllSummary(:, 13));
    lowBandPower = cell2mat(AllSummary(:, 14));
    baseBandPower = cell2mat(AllSummary(:, 15));
    highBandPower = cell2mat(AllSummary(:, 16));
    
    lowCurrentPct = cell2mat(AllSummary(:, 3));
    lowVoltagePct = cell2mat(AllSummary(:, 4));
    highCurrentPct = cell2mat(AllSummary(:, 8));
    highVoltagePct = cell2mat(AllSummary(:, 9));
    
    lowR = cell2mat(AllSummary(:, 5));
    lowX = cell2mat(AllSummary(:, 6));
    highR = cell2mat(AllSummary(:, 10));
    highX = cell2mat(AllSummary(:, 11));
    
    % 筛选基波功率绝对值 ≥ 2 的线路（用于图2-图6，排除接近零的线路）
    validIdx = abs(basePower_single) >= 2;
    lineNames_valid = lineNames(validIdx);
    lowCurrentPct_valid = lowCurrentPct(validIdx);
    highCurrentPct_valid = highCurrentPct(validIdx);
    lowVoltagePct_valid = lowVoltagePct(validIdx);
    highVoltagePct_valid = highVoltagePct(validIdx);
    lowBandPower_valid = lowBandPower(validIdx);
    highBandPower_valid = highBandPower(validIdx);
    lowR_valid = lowR(validIdx);
    lowX_valid = lowX(validIdx);
    highR_valid = highR(validIdx);
    highX_valid = highX(validIdx);
    
    % 图1：基波频带功率柱状图
    fig1 = figure('Name', '基波频带功率', 'Position', [100, 100, 800, 400], 'Visible', 'off');
    bar(1:nLines, abs(baseBandPower), 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'k', 'LineWidth', 1.2);
    set(gca, 'XTick', 1:nLines, 'XTickLabel', lineNames, 'XTickLabelRotation', 45, 'FontSize', 10);
    xlabel('线路名称', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('功率 (W)', 'FontSize', 11, 'FontWeight', 'bold');
    title('基波频带功率 (49-51 Hz) ENBW校正后', 'FontSize', 12, 'FontWeight', 'bold');
    grid on; box off;
    if SAVE_FIGURES
        filename = fullfile(OUTPUT_FOLDER, '汇总_基波频带功率.png');
        exportgraphics(fig1, filename, 'Resolution', 300);
        fprintf('已保存: %s\n', filename);
    end
    if DRAW_FIGURES
        set(fig1, 'Visible', 'on');
    else
        close(fig1);
    end
    
    % 图2：次/超同步电压占比（%）
    if ~isempty(lineNames_valid)
        fig2 = figure('Name', '谐波电压占比', 'Position', [100, 100, 800, 400], 'Visible', 'off');
        b = bar(1:length(lineNames_valid), [lowVoltagePct_valid, highVoltagePct_valid], 'grouped');
        b(1).FaceColor = [0.85 0.33 0.10];
        b(2).FaceColor = [0.00 0.45 0.74];
        set(gca, 'XTick', 1:length(lineNames_valid), 'XTickLabel', lineNames_valid, 'XTickLabelRotation', 45);
        xlabel('线路名称'); ylabel('电压占比 (%)');
        title('次同步/超同步电压最大值占基波百分比');
        legend('次同步电压 (%)', '超同步电压 (%)', 'Location', 'best');
        grid on; box off;
        if SAVE_FIGURES
            filename = fullfile(OUTPUT_FOLDER, '汇总_谐波电压占比.png');
            exportgraphics(fig2, filename, 'Resolution', 300);
            fprintf('已保存: %s\n', filename);
        end
        if DRAW_FIGURES
            set(fig2, 'Visible', 'on');
        else
            close(fig2);
        end
    end
    
    % 图3：次/超同步电流占比（%）
    if ~isempty(lineNames_valid)
        fig3 = figure('Name', '谐波电流占比', 'Position', [100, 100, 800, 400], 'Visible', 'off');
        b = bar(1:length(lineNames_valid), [lowCurrentPct_valid, highCurrentPct_valid], 'grouped');
        b(1).FaceColor = [0.85 0.33 0.10];
        b(2).FaceColor = [0.00 0.45 0.74];
        set(gca, 'XTick', 1:length(lineNames_valid), 'XTickLabel', lineNames_valid, 'XTickLabelRotation', 45);
        xlabel('线路名称'); ylabel('电流占比 (%)');
        title('次同步/超同步电流最大值占基波百分比');
        legend('次同步电流 (%)', '超同步电流 (%)', 'Location', 'best');
        grid on; box off;
        if SAVE_FIGURES
            filename = fullfile(OUTPUT_FOLDER, '汇总_谐波电流占比.png');
            exportgraphics(fig3, filename, 'Resolution', 300);
            fprintf('已保存: %s\n', filename);
        end
        if DRAW_FIGURES
            set(fig3, 'Visible', 'on');
        else
            close(fig3);
        end
    end
    
    % 图4：谐波频带功率（次同步+超同步，ENBW校正后）
    if ~isempty(lineNames_valid)
        fig4 = figure('Name', '谐波频带功率', 'Position', [100, 100, 800, 400], 'Visible', 'off');
        b = bar(1:length(lineNames_valid), [(lowBandPower_valid), (highBandPower_valid)], 'grouped');
        b(1).FaceColor = [0.85 0.33 0.10];
        b(2).FaceColor = [0.00 0.45 0.74];
        set(gca, 'XTick', 1:length(lineNames_valid), 'XTickLabel', lineNames_valid, 'XTickLabelRotation', 45);
        xlabel('线路名称'); ylabel('功率 (W)');
        title('次同步频带功率 vs 超同步频带功率 (ENBW校正)');
        legend('次同步频带功率 (W)', '超同步频带功率 (W)', 'Location', 'best');
        grid on; box off;
        if SAVE_FIGURES
            filename = fullfile(OUTPUT_FOLDER, '汇总_谐波频带功率.png');
            exportgraphics(fig4, filename, 'Resolution', 300);
            fprintf('已保存: %s\n', filename);
        end
        if DRAW_FIGURES
            set(fig4, 'Visible', 'on');
        else
            close(fig4);
        end
    end
    
    % 图5：次同步阻抗极坐标
    if ~isempty(lineNames_valid)
        fig5 = figure('Name', '次同步阻抗极坐标', 'Position', [100, 100, 900, 700], 'Visible', 'off');
        Z_low = lowR_valid + 1j * lowX_valid;
        rho_low = abs(Z_low);
        theta_low = angle(Z_low);
        pax = polaraxes;
        hold on;
        colors = lines(length(lineNames_valid));
        h_low = gobjects(length(lineNames_valid), 1);
        for i = 1:length(lineNames_valid)
            h_low(i) = polarscatter(pax, theta_low(i), rho_low(i), 100, colors(i,:), 'filled', ...
                                    'MarkerEdgeColor', 'k', 'LineWidth', 1.2);
        end
        title(pax, '次同步频率正序阻抗（极坐标）');
        pax.ThetaZeroLocation = 'right';
        pax.ThetaDir = 'counterclockwise';
        legend(h_low, lineNames_valid, 'Location', 'bestoutside');
        hold off;
        if SAVE_FIGURES
            filename = fullfile(OUTPUT_FOLDER, '汇总_次同步阻抗极坐标.png');
            exportgraphics(fig5, filename, 'Resolution', 300);
            fprintf('已保存: %s\n', filename);
        end
        if DRAW_FIGURES
            set(fig5, 'Visible', 'on');
        else
            close(fig5);
        end
    end
    
    % 图6：超同步阻抗极坐标
    if ~isempty(lineNames_valid)
        fig6 = figure('Name', '超同步阻抗极坐标', 'Position', [100, 100, 900, 700], 'Visible', 'off');
        Z_high = highR_valid + 1j * highX_valid;
        rho_high = abs(Z_high);
        theta_high = angle(Z_high);
        pax = polaraxes;
        hold on;
        colors = lines(length(lineNames_valid));
        h_high = gobjects(length(lineNames_valid), 1);
        for i = 1:length(lineNames_valid)
            h_high(i) = polarscatter(pax, theta_high(i), rho_high(i), 100, colors(i,:), 'filled', ...
                                     'MarkerEdgeColor', 'k', 'LineWidth', 1.2);
        end
        title(pax, '超同步频率正序阻抗（极坐标）');
        pax.ThetaZeroLocation = 'right';
        pax.ThetaDir = 'counterclockwise';
        legend(h_high, lineNames_valid, 'Location', 'bestoutside');
        hold off;
        if SAVE_FIGURES
            filename = fullfile(OUTPUT_FOLDER, '汇总_超同步阻抗极坐标.png');
            exportgraphics(fig6, filename, 'Resolution', 300);
            fprintf('已保存: %s\n', filename);
        end
        if DRAW_FIGURES
            set(fig6, 'Visible', 'on');
        else
            close(fig6);
        end
    end
else
    warning('没有成功分析任何线路，无法生成汇总表和图形。');
end

fprintf('\n脚本运行完成。\n');

%% ========== 局部函数定义 ==========
function cplx = get_complex_at_freq_windowed(signal, freq, fs, w, win_corr)
    % 使用预定义的窗口和修正系数提取复数幅值（峰值）
    signal = double(signal(:));
    N = length(signal);
    n = double((0:N-1)');
    fs = double(fs);
    
    signal_w = signal .* w;
    complex_exp = exp(-1j * 2 * pi * freq * n / fs);
    X = sum(signal_w .* complex_exp);
    mag = abs(X) * win_corr;
    ang_deg = angle(X);
    cplx = mag * exp(1j * ang_deg);
end

function V120 = f_seqconv(Vabc)
    a = exp(1j * 2 * pi / 3);
    A = 1/3 * [1, a, a^2; 1, a^2, a; 1, 1, 1];
    V120 = A * Vabc;
end