%% template02b_simple_fft_demo_multi.m  —  多测点 FFT 批量出图（关键词检索列）
% version 1.0  revised by Yamin
%
% 本脚本由 template02_simple_fft_demo.m 改写而来，主要改动：
%   1. 支持在**一个 CSV** 中指定**多个测点**（原版只能给一组列号，一个测点）；
%   2. 测点用「列名关键词」检索给定，不用再手写列号（思路同 da02 / da01b）；
%   3. 每个测点单独输出一张 3 子图（时域波形 / 幅值谱 / 幅值含量%），
%      并以 fig + png 两种格式保存；
%   4. 保存目录 = 「CSV 所在目录」下 <OUTPUT_DIR_PREFIX><CSV 同名（去扩展名）> 的独立文件夹；
%      目录名前缀可用 OUTPUT_DIR_PREFIX 自定义，用于与其它脚本的输出区分开（留空 '' = 不加前缀）；
%   5. 额外把每个测点每个通道的谱峰统计汇总写入 Excel（默认 FFT幅值统计.xlsx），
%      每个通道一行，表头依次为：
%        测点 / 通道 / 列名 / 50Hz幅值 /
%        第一峰值频率、第一峰值幅值、第一峰值幅值占比 /
%        第二峰值频率、第二峰值幅值、第二峰值幅值占比 / …
%      其中「第一峰值」= **除去 50Hz（及其邻域）之后**的最大谱峰，
%      幅值占比 = 该峰幅值 / 50Hz幅值 × 100%。
%
% ------------------------------------------------------------------------
% 用法：
%   1) 指定 CSV_FILE（文件名，相对 RootDir；也可直接写绝对路径）；
%   2) 设定 FS —— 采样率，必须与 CSV 实际采样率一致；
%   3) 在 POINT_KEYWORDS 中列出测点，每个元素是一个测点：
%        char → 单个关键词
%        cell → 多个关键词，需**同时命中**才选中
%      例如 {'35kV#1光伏线311','电流'} 只会选中该线路的电流三相列；
%      脚本会自动按 Ua/Ub/Uc、Ia/Ib/Ic 的相序把命中列排好，
%      并默认排除 3U0/3I0 等派生的零序通道（KEEP_ONLY_PHASE_COLS 控制）；
%   4) 运行，结果保存在 <CSV目录>/<OUTPUT_DIR_PREFIX><CSV文件名>/ 下。
%
% 编码说明：故障录波 CSV 多为 GBK，脚本会自动探测（UTF-8 / GBK），
%           也可用 CSV_ENCODING 强制指定。
%
% 性能说明：默认 READ_ONLY_SELECTED_COLS = true，只把命中的列读进内存。
%
% 依赖外部文件：f_fft_simple.m、f_savefig.m、f_set_fig_size.m、f_set_fontface.m
% =========================================================================

clear; close all; clc

%% ==================== 用户定义区 ====================

% ---- 指定要分析的 CSV 文件（只读这一个文件）----
RootDir  = '../02-fault_rec_data/故障波形/';              % 数据目录
CSV_FILE = '2026-10-05@09-45-16.180000.csv';
CSV_FILE = '2026-10-06@09-49-31.670100.csv';
CSV_FILE = '2026-10-06@15-54-39.560000.csv';              % 文件名（相对 RootDir）或绝对路径

% CSV 编码：'auto' = 自动探测；也可强制指定 'GBK' / 'UTF-8' / 'GB18030'
CSV_ENCODING = 'auto';

% 只读取命中的列（避免整表读入；更省内存、更快，建议保持 true）
READ_ONLY_SELECTED_COLS = true;

% ---- 测点关键词（★核心：给定多个关键词 → 多个测点）----
%   每个元素 = 一个测点：
%     char  → 单个关键词
%     cell  → 多个关键词，需**同时命中**
POINT_KEYWORDS = {
    {'光伏线311', '电流'};
    {'光伏线312', '电流'};
    {'光伏线313', '电流'};
    {'光伏线314', '电流'};
    {'光伏线315', '电流'};
    {'光伏线316', '电流'};
    {'光伏线317', '电流'};
    {'SVG', '电流'};
    {'35kV5母电压'};
    {'220kV', '母线电压'};
};

% 相别后缀顺序：命中列会按此顺序重排（识别不到的列按原始列序附加在后面）
PHASE_ORDER = {'Ua', 'Ub', 'Uc', 'Ia', 'Ib', 'Ic'};

% 只保留能识别出相别的列（Ua/Ub/Uc、Ia/Ib/Ic），自动排除 3U0 / 3I0 等派生零序通道。
%   若某测点一个相别都识别不到（例如只想看单列 '3I0'），则保留全部命中列。
KEEP_ONLY_PHASE_COLS = true;

% ---- 采样与 FFT 参数 ----
FS = int64(10e3);        % 采样率 Hz（★必须与 CSV 一致，如 1000 / 5000 / 10e3）
T_STEP_IDX = 0;          % 第几个 1 秒窗口，0 = 从文件开头
FFT_WINDOW = 'none';     % f_fft_simple 的窗：none / hann / hamming / blackman

% ---- 绘图参数 ----
XaxisLimit = [0, 200];       % 频谱横轴范围 (Hz)
YaxisLimit = [];             % 幅值谱纵轴范围，留空 [] = 自动
FONT_SIZE = 14;
LINEWIDTH = 1.3;
FIG_POS  = [5, 5];           % 图形左下角位置 (cm)
FIG_SIZE = [15, 15];         % 图形宽、高 (cm)

% ---- 输出参数 ----
FigSaveFormat = {'fig', 'png'};   % 保存格式
FigSaveResolution = 300;          % 位图分辨率 (dpi)
OUTPUT_PARENT = '';               % 留空 = 保存在 CSV 同目录；也可指定输出根目录

% 输出**目录名**前缀：最终目录 = <输出根目录>/<前缀><CSV文件名(去扩展名)>
%   用于把本脚本的输出与其它脚本区分开，避免混进同一个文件夹。
%   例：前缀 'T02b_' + CSV '2026-10-06@15-54-39.560000'
%       → 目录 'T02b_2026-10-06@15-54-39.560000'
%   留空 '' = 不加前缀（目录名与 CSV 同名，与旧版一致）。
OUTPUT_DIR_PREFIX = 'T02b_';

% ---- 统计结果（Excel）----
% 每个测点的每个通道一行：
%   50Hz幅值（工频幅值），以及**除 50Hz 外**的第一峰值、第二峰值…
%   每个峰值记录「频率 / 幅值 / 幅值占比」，其中
%   幅值占比 = 该峰幅值 / 50Hz幅值 × 100%（与 da02 的次同步电流占基波百分比同口径）。
SAVE_XLSX = true;                 % 是否把每个测点的幅值统计写入 Excel
XLSX_NAME = 'FFT幅值统计.xlsx';    % Excel 文件名（保存在输出目录下）

% 谱峰搜索参数
FUND_FREQ       = 50;   % 工频 (Hz)：单独统计其幅值，并从峰值搜索中排除
N_PEAK          = 2;    % 除 50Hz 外记录的谱峰个数（1=只到第一峰值，2=到第二峰值…）
PEAK_MIN_FREQ   = 1;    % 峰值搜索下限频率 (Hz)，用于排除直流/极低频
PEAK_MIN_SEP_HZ = 2;    % 峰间最小间隔 (Hz)；也用于排除 50Hz 附近 ±该值内的谱线（避免旁瓣被当成峰值）


%% ==================== 定位 CSV 与读取列名 ====================
if exist(CSV_FILE, 'file')
    MatUrl = CSV_FILE;
else
    MatUrl = fullfile(RootDir, CSV_FILE);
end
if ~exist(MatUrl, 'file')
    error('找不到数据文件：%s', MatUrl);
end

[~, CSV_BASE] = fileparts(MatUrl);

% 输出目录：<输出根目录>/<前缀><CSV同名>
if isempty(OUTPUT_PARENT)
    outRoot = fileparts(MatUrl);
else
    outRoot = OUTPUT_PARENT;
end
OutDir = fullfile(outRoot, [f_safe_filename(OUTPUT_DIR_PREFIX), CSV_BASE]);
if ~exist(OutDir, 'dir')
    mkdir(OutDir);
end

fprintf('\n====================================================================\n');
fprintf('数据文件：%s\n', MatUrl);
fprintf('输出目录：%s\n', OutDir);
fprintf('采样率 FS：%d Hz，窗口：第 %d 秒\n', double(FS), T_STEP_IDX);
fprintf('====================================================================\n');

% ---- 自动探测编码 ----
if isempty(CSV_ENCODING) || strcmpi(CSV_ENCODING, 'auto')
    csvEnc = f_detect_csv_encoding(MatUrl);
else
    csvEnc = CSV_ENCODING;
end
fprintf('CSV 编码：%s\n', csvEnc);

% ---- 只解析表头拿到列名 ----
[opts, colNames] = f_get_column_names(MatUrl, csvEnc);
colNamesClean = cellfun(@(x) strrep(x, ' ', ''), colNames, 'UniformOutput', false);
fprintf('CSV 共 %d 列\n', numel(colNames));


%% ==================== 关键词检索：确定所有测点 ====================
nPointIn = numel(POINT_KEYWORDS);
pointName  = {};      % 测点名称（关键词拼接）
pointIdx   = {};      % 测点对应的原始列索引
pointLabel = {};      % 每列的短标签（Ua/Ib/...）

fprintf('\n========== 测点检索 ==========\n');
for p = 1:nPointIn
    kws = f_to_cellstr(POINT_KEYWORDS{p});
    idx = f_find_cols_by_keywords(colNamesClean, kws, true);
    if isempty(idx)
        warning('测点 %d [%s] 未命中任何列，已跳过。', p, strjoin(kws, ' + '));
        continue
    end
    [idx, labels] = f_order_by_phase(colNamesClean, idx, PHASE_ORDER, KEEP_ONLY_PHASE_COLS);

    pointName{end+1}  = strjoin(kws, '+');   %#ok<SAGROW>
    pointIdx{end+1}   = idx;                 %#ok<SAGROW>
    pointLabel{end+1} = labels;              %#ok<SAGROW>

    fprintf('\n测点 %d [%s] 命中 %d 列：\n', p, strjoin(kws, ' + '), numel(idx));
    for k = 1:numel(idx)
        fprintf('  [%3d] %-10s %s\n', idx(k), labels{k}, colNames{idx(k)});
    end
end

nPoint = numel(pointName);
if nPoint == 0
    error('没有任何测点命中，请检查 POINT_KEYWORDS 或 CSV_ENCODING。');
end
fprintf('\n共命中 %d 个测点。\n', nPoint);


%% ==================== 读取数据（只读命中的列） ====================
allIdx   = unique([pointIdx{:}]);
selNames = colNames(allIdx);

usedSelected = false;
if READ_ONLY_SELECTED_COLS
    try
        RawData = f_read_cols_by_name(MatUrl, opts, selNames);
        usedSelected = true;
        fprintf('已只读取 %d 列（未载入整表 %d 列）。\n', numel(selNames), numel(colNames));
    catch ME
        fprintf('  [提示] 按列读取失败（%s），回退为整表读取。\n', ME.message);
    end
end
if ~usedSelected
    RawData = f_read_full(MatUrl, csvEnc);
    fprintf('已整表读取 %d 列。\n', size(RawData, 2));
end

% 建立「原始列索引 → RawData 列位置」映射
if usedSelected
    posOf = zeros(1, numel(colNames));
    posOf(allIdx) = 1:numel(allIdx);
else
    posOf = 1:numel(colNames);
end

row = size(RawData, 1);

% 时间轴与取样区间
SELECTED_RANGE = (FS*T_STEP_IDX+1):(FS*(T_STEP_IDX+1));
if double(max(SELECTED_RANGE)) > row
    error(['取样区间 %d ~ %d 超出数据长度 %d 行。', ...
           '请检查 FS（当前 %d Hz）与 T_STEP_IDX（当前 %d）。'], ...
        double(min(SELECTED_RANGE)), double(max(SELECTED_RANGE)), row, double(FS), T_STEP_IDX);
end
myt    = transpose((1:row) / double(FS));
t_plot = myt(SELECTED_RANGE);


%% ==================== 逐测点 FFT + 出图 ====================
% 幅值统计累加器（每个测点的每个通道一行）
StatPoint  = {};   % 测点
StatChan   = {};   % 通道（Ua/Ib/...）
StatCol    = {};   % 列名
StatFund   = [];   % 50Hz（工频）幅值
StatPkMag  = [];   % 除 50Hz 外的前 N_PEAK 个谱峰幅值（行 × N_PEAK，第 1 列 = 第一峰值）
StatPkFreq = [];   % 对应频率 (Hz)
StatPkPct  = [];   % 对应幅值占比 (%) = 峰幅值 / 50Hz幅值 × 100

for p = 1:nPoint
    cols = posOf(pointIdx{p});
    target_data = double(RawData(SELECTED_RANGE, cols));
    [~, nCol] = size(target_data);

    fprintf('\n---- 测点 %d/%d：%s（%d 列）----\n', p, nPoint, pointName{p}, nCol);

    % FFT
    [freq_ax, mag_ax, ph_ax, cmp_ax] = f_fft_simple(target_data, FS, FS, FFT_WINDOW); %#ok<ASGLU>

    % 幅值含量(%)：每列按自身最大值归一（与子图 3 一致）
    mag_pct = mag_ax ./ max(mag_ax, [], 1) * 100;

    % 单位（从列名末尾括号中提取，如 (kA)、(kV)）
    unitStr = f_unit_from_name(colNames{pointIdx{p}(1)});
    if isempty(unitStr)
        labTime = '原始信号';
        labMag  = '振幅';
    else
        labTime = ['原始信号(' unitStr ')'];
        labMag  = ['振幅(' unitStr ')'];
    end

    % ---- 统计每个通道：50Hz 幅值 + 除 50Hz 外的前 N_PEAK 个谱峰 ----
    [~, iFund] = min(abs(freq_ax - FUND_FREQ));   % 工频所在谱线
    fprintf('  各通道统计（50Hz 幅值 + 除 50Hz 外的谱峰，单位 %s）：\n', unitStr);
    for c = 1:nCol
        fundAmp = mag_ax(iFund, c);               % 50Hz（工频）幅值

        % 前 N_PEAK 个谱峰：**排除 50Hz 及其 ±PEAK_MIN_SEP_HZ 邻域**
        %   第 1 峰 = 除 50Hz 外剩余频段内的最大峰值
        [pkMag, pkFreq] = f_top_peaks(mag_ax(:, c), freq_ax, N_PEAK, ...
                                      PEAK_MIN_FREQ, FUND_FREQ, PEAK_MIN_SEP_HZ, PEAK_MIN_SEP_HZ);
        pkPct = pkMag / fundAmp * 100;            % 幅值占比（相对 50Hz 幅值）

        StatPoint{end+1} = pointName{p};              %#ok<SAGROW>
        StatChan{end+1}  = pointLabel{p}{c};          %#ok<SAGROW>
        StatCol{end+1}   = colNames{pointIdx{p}(c)};  %#ok<SAGROW>
        StatFund(end+1)  = fundAmp;                   %#ok<SAGROW>
        StatPkMag(end+1, :)  = pkMag;                 %#ok<SAGROW>
        StatPkFreq(end+1, :) = pkFreq;                %#ok<SAGROW>
        StatPkPct(end+1, :)  = pkPct;                 %#ok<SAGROW>

        fprintf('    %-6s 50Hz %9.4f', pointLabel{p}{c}, fundAmp);
        for k = 1:N_PEAK
            if isnan(pkMag(k))
                fprintf('  | #%d --', k);
            else
                fprintf('  | #%d %9.4f @ %7.2f Hz (%6.2f%%)', k, pkMag(k), pkFreq(k), pkPct(k));
            end
        end
        fprintf('\n');
    end

    figure('Name', sprintf('%s — %s', CSV_BASE, pointName{p}));

    % ---- 子图 1：时域波形 ----
    subplot(3, 1, 1)
    plot(t_plot, target_data, 'LineWidth', LINEWIDTH)
    ylabel(labTime)
    xlabel('time (sec)')
    grid on
    if nCol > 1
        legend(pointLabel{p}, 'Location', 'best')
    end
    f_set_fontface(gca, 'TimesNewRomanSimsun')
    set(gca, 'fontsize', FONT_SIZE)

    % ---- 子图 2：幅值谱 ----
    subplot(3, 1, 2)
    plot(freq_ax, mag_ax, 'LineWidth', LINEWIDTH)
    set(gca, 'xlim', XaxisLimit)
    if ~isempty(YaxisLimit)
        set(gca, 'ylim', YaxisLimit)
    end
    grid on
    ylabel(labMag)
    xlabel('频率(Hz)')
    if nCol > 1
        legend(pointLabel{p}, 'Location', 'best')
    end
    f_set_fontface(gca, 'TimesNewRomanSimsun')
    set(gca, 'fontsize', FONT_SIZE)

    % ---- 子图 3：幅值含量(%)（每列按自身最大值归一，mag_pct 已在上方算好）----
    subplot(3, 1, 3)
    plot(freq_ax, mag_pct, 'LineWidth', LINEWIDTH)
    set(gca, 'ylim', [-0.1, 1.1] * 100)
    set(gca, 'xlim', XaxisLimit)
    grid on
    ylabel('振幅含量(%)')
    xlabel('频率(Hz)')
    f_set_fontface(gca, 'TimesNewRomanSimsun')
    set(gca, 'fontsize', FONT_SIZE)

    sgtitle(sprintf('%s — %s', CSV_BASE, pointName{p}), 'Interpreter', 'none')

    f_set_fig_size(gcf, FIG_POS, FIG_SIZE);

    % ---- 保存 fig + png ----
    safeName = f_safe_filename(sprintf('%02d_%s', p, pointName{p}));
    f_savefig(OutDir, safeName, FigSaveFormat, FigSaveResolution);

    close(gcf)
end

%% ==================== 幅值统计写入 Excel ====================
if SAVE_XLSX
    % 表头顺序：
    %   测点 / 通道 / 列名 / 50Hz幅值 /
    %   第一峰值频率、第一峰值幅值、第一峰值幅值占比 /
    %   第二峰值频率、第二峰值幅值、第二峰值幅值占比 / …
    % （第一峰值 = 除去 50Hz 后的最大谱峰；幅值占比 = 峰幅值 / 50Hz幅值 × 100%）
    varNames = {'测点', '通道', '列名', '50Hz幅值'};
    StatData = [StatPoint(:), StatChan(:), StatCol(:), num2cell(StatFund(:))];

    cnNum = {'一', '二', '三', '四', '五', '六', '七', '八', '九', '十'};
    for k = 1:N_PEAK
        if k <= numel(cnNum)
            cn = cnNum{k};
        else
            cn = num2str(k);
        end
        StatData = [StatData, num2cell(StatPkFreq(:, k)), ...
                              num2cell(StatPkMag(:, k)), ...
                              num2cell(StatPkPct(:, k))];          %#ok<AGROW>
        varNames{end+1} = sprintf('第%s峰值频率',     cn);          %#ok<AGROW>
        varNames{end+1} = sprintf('第%s峰值幅值',     cn);          %#ok<AGROW>
        varNames{end+1} = sprintf('第%s峰值幅值占比', cn);          %#ok<AGROW>
    end

    StatTable = cell2table(StatData, 'VariableNames', varNames);

    xlsxPath = fullfile(OutDir, XLSX_NAME);
    writetable(StatTable, xlsxPath);
    fprintf('\n幅值统计已保存：%s\n', xlsxPath);
    disp(StatTable)
end

fprintf('\n===== 全部完成，共 %d 个测点，结果保存在：%s =====\n', nPoint, OutDir);


%% ========== 局部函数定义 ==========

function c = f_to_cellstr(x)
    % 把 char / string / cellstr 统一成 cellstr
    if ischar(x)
        c = {x};
    elseif isstring(x)
        c = cellstr(x);
    elseif iscell(x)
        c = x;
    else
        error('关键词必须为 char / string / cellstr 类型');
    end
end

function idx = f_find_cols_by_keywords(colNamesClean, keywords, matchAll)
    % 按关键词检索列：返回列名中包含关键词的列索引
    if nargin < 3, matchAll = true; end
    kw = f_to_cellstr(keywords);
    kw = cellfun(@(x) strrep(x, ' ', ''), kw, 'UniformOutput', false);
    n = numel(colNamesClean);
    hit = false(1, n);
    for k = 1:n
        nm = colNamesClean{k};
        if matchAll
            hit(k) = all(cellfun(@(q) contains(nm, q), kw));
        else
            hit(k) = any(cellfun(@(q) contains(nm, q), kw));
        end
    end
    idx = find(hit);
end

function [idxOut, labels] = f_order_by_phase(colNamesClean, idxIn, phaseOrder, keepOnlyPhase)
    % 把命中的列按相别顺序重排，并给出每列短标签
    if nargin < 4, keepOnlyPhase = false; end
    idxOut = zeros(1, 0);
    labels = {};
    used = false(1, numel(idxIn));
    for q = 1:numel(phaseOrder)
        ph = phaseOrder{q};
        pat = ['(?<![A-Za-z])', ph, '(?![A-Za-z])'];
        for k = 1:numel(idxIn)
            if used(k), continue; end
            if ~isempty(regexp(colNamesClean{idxIn(k)}, pat, 'once'))
                idxOut(end+1) = idxIn(k);   %#ok<AGROW>
                labels{end+1} = ph;         %#ok<AGROW>
                used(k) = true;
                break
            end
        end
    end
    % 未识别出相别的列，按原顺序附加；
    % 若 keepOnlyPhase=true 且已识别到相别，则丢弃（用于排除 3U0/3I0 等派生通道）
    if ~(keepOnlyPhase && ~isempty(idxOut))
        for k = 1:numel(idxIn)
            if ~used(k)
                idxOut(end+1) = idxIn(k);                        %#ok<AGROW>
                labels{end+1} = f_short_label(colNamesClean{idxIn(k)}); %#ok<AGROW>
            end
        end
    end
end

function s = f_short_label(name)
    % 取列名中 "_xxx(" 里的 xxx 作为短标签，如 ..._Ia(kA) → Ia
    t = regexp(name, '_([^_()]+)\(', 'tokens', 'once');
    if ~isempty(t)
        s = t{1};
    elseif numel(name) > 8
        s = name(end-7:end);
    else
        s = name;
    end
end

function u = f_unit_from_name(name)
    % 从列名末尾括号中提取单位，如 ..._Ia(kA) → kA；取不到返回 ''
    t = regexp(name, '\(([^()]*)\)\s*$', 'tokens', 'once');
    if isempty(t)
        u = '';
    else
        u = t{1};
    end
end

function [pkMag, pkFreq] = f_top_peaks(mag, freq, nPeak, fMin, fExcl, exclTol, minSep)
    % 取前 nPeak 个谱峰（按幅值降序），并**排除频率 fExcl 及其 ±exclTol 邻域**。
    %   nPeak 个峰全部从「有效频段 freq >= fMin 且 |freq - fExcl| > exclTol」内挑选；
    %   第 1 峰 = 该有效频段内的全局最大值（即「除去 fExcl 后的最大峰值」），
    %   其余峰从「局部极大值」中按幅值降序挑选，且与已选峰值保持 minSep 的频率间隔
    %   （避免把同一谱峰的旁瓣/相邻 bin 当成新的峰）。
    % 峰数不足时用 NaN 补齐。
    %
    % 用法：
    %   f_top_peaks(mag, freq, nPeak, fMin)                        % 不排除任何频率
    %   f_top_peaks(mag, freq, nPeak, fMin, fExcl)                 % 排除 fExcl（容差 0）
    %   f_top_peaks(mag, freq, nPeak, fMin, fExcl, exclTol, minSep)
    if nargin < 7 || isempty(minSep),  minSep  = 0;   end
    if nargin < 6 || isempty(exclTol), exclTol = 0;   end
    if nargin < 5,                     fExcl   = NaN; end

    mag  = double(mag(:));
    freq = double(freq(:));
    pkMag  = nan(1, nPeak);
    pkFreq = nan(1, nPeak);

    % 有效频段：>= fMin，且不在被排除频率的邻域内
    valid = freq >= fMin;
    if isfinite(fExcl) && exclTol > 0
        valid = valid & (abs(freq - fExcl) > exclTol);
    end
    if ~any(valid), return; end

    % 候选 = 有效频段内的「局部极大值」 ∪ {有效频段全局最大值}
    isPk = [false; (mag(2:end-1) > mag(1:end-2)) & (mag(2:end-1) >= mag(3:end)); false];
    isPk = isPk & valid;
    idxPk = find(isPk);

    v = mag;
    v(~valid) = -Inf;
    [vMax, iMax] = max(v);
    if ~isfinite(vMax), return; end

    cand = unique([iMax; idxPk(:)]);
    [~, ord] = sort(mag(cand), 'descend');
    cand = cand(ord);

    cnt = 0;
    for k = 1:numel(cand)
        if cnt >= nPeak, break; end
        fk = freq(cand(k));
        if any(abs(fk - pkFreq(1:cnt)) <= minSep), continue; end
        cnt = cnt + 1;
        pkMag(cnt)  = mag(cand(k));
        pkFreq(cnt) = fk;
    end
end

function s = f_safe_filename(s)
    % 替换文件系统非法字符（含空格），保留中文
    s = regexprep(s, '[\\/:*?"<>|\s]', '_');
end

function enc = f_detect_csv_encoding(filePath)
    % 读取 CSV 首行原始字节，判断是 UTF-8 还是 GBK
    enc = '';
    fid = fopen(filePath, 'r', 'n', 'ISO-8859-1');
    if fid < 0
        return
    end
    line = fgetl(fid);
    fclose(fid);
    if ~ischar(line)
        return
    end
    b = uint8(line);
    if ~any(b >= 128)
        enc = 'UTF-8';
        return
    end
    if f_is_valid_utf8(b)
        enc = 'UTF-8';
    else
        enc = 'GBK';
    end
end

function tf = f_is_valid_utf8(b)
    % 判断字节序列是否为合法 UTF-8
    b = double(b(:)');
    n = numel(b);
    i = 1;
    tf = true;
    while i <= n
        c = b(i);
        if c < 128
            i = i + 1;
        elseif c >= 194 && c <= 223
            if i+1 <= n && b(i+1) >= 128 && b(i+1) <= 191
                i = i + 2;
            else
                tf = false; return
            end
        elseif c >= 224 && c <= 239
            if i+2 <= n && all(b(i+1:i+2) >= 128 & b(i+1:i+2) <= 191)
                i = i + 3;
            else
                tf = false; return
            end
        elseif c >= 240 && c <= 244
            if i+3 <= n && all(b(i+1:i+3) >= 128 & b(i+1:i+3) <= 191)
                i = i + 4;
            else
                tf = false; return
            end
        else
            tf = false; return
        end
    end
end

function [opts, colNames] = f_get_column_names(filePath, enc)
    % 只解析表头拿到列名（不把数据读进内存），返回 import options 供后续按列读取
    if isempty(enc) || strcmp(enc, '(默认)')
        opts = detectImportOptions(filePath, 'PreserveVariableNames', true);
    else
        opts = detectImportOptions(filePath, 'PreserveVariableNames', true, 'Encoding', enc);
    end
    colNames = opts.VariableNames;
end

function M = f_read_cols_by_name(filePath, opts, selNames)
    % 只读取指定列名的列（返回矩阵，列顺序 = selNames 顺序）
    opts.SelectedVariableNames = selNames;
    T = readtable(filePath, opts);
    got = T.Properties.VariableNames;
    if isequal(got(:), selNames(:))
        M = table2array(T);
    else
        % 万一列顺序被改变，按名字重排
        M = zeros(height(T), numel(selNames));
        for j = 1:numel(selNames)
            jj = find(strcmp(got, selNames{j}), 1);
            if isempty(jj)
                error('读取结果中找不到列：%s', selNames{j});
            end
            M(:, j) = T{:, jj};
        end
    end
end

function M = f_read_full(filePath, enc)
    % 整表读取（回退方案）
    if isempty(enc) || strcmp(enc, '(默认)')
        T = readtable(filePath, 'PreserveVariableNames', true);
    else
        try
            T = readtable(filePath, 'PreserveVariableNames', true, 'Encoding', enc);
        catch ME
            fprintf('  [提示] readtable(Encoding=%s) 失败：%s\n         改用默认编码读取。\n', enc, ME.message);
            T = readtable(filePath, 'PreserveVariableNames', true);
        end
    end
    try
        M = table2array(T);
    catch
        fprintf('  [提示] table2array 失败，改用 readmatrix 读取数值矩阵。\n');
        if isempty(enc) || strcmp(enc, '(默认)')
            M = readmatrix(filePath);
        else
            M = readmatrix(filePath, 'Encoding', enc);
        end
    end
end
