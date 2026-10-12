%% template_sliding_window_fft_spectrum.m  —  多测点滑动窗全频谱可视化（关键词检索测点）
% version 2.0  revised by Yamin
%
% 本脚本由原 template_sliding_window_fft_spectrum.m（手写列号版）改写而来，
% 核心改动：测点改用**列名关键词检索**（思路同 template02_simple_fft_demo_multi.m）。
%
%   1. 一次分析**一个 CSV**；脚本循环处理 POINT_KEYWORDS 中的**所有测点**
%      （可用 POINT_SEL 只跑其中几个）；
%   2. 每个测点用关键词定位列：char = 单关键词；cell = 多关键词，需**同时命中**；
%   3. 命中列先按相别重排，再自动拆成「三相电压 Ua/Ub/Uc」与「三相电流 Ia/Ib/Ic」：
%        · 电压组、电流组各自需恰好三相；缺哪一组就跳过对应的图（只画有的那组）；
%        · 只保留能识别相别的列，自动排除 3U0 / 3I0 等派生零序通道。
%   4. 输出目录 = <CSV目录>/<OUTPUT_DIR_PREFIX><CSV文件名(去扩展名)>/；
%      每个测点输出 fig + png：
%        图1 电压幅值谱 3D surf（指定相）
%        图2 电压相位谱 3D surf（指定相）
%        图3 三相电压频谱瀑布图
%        图4 三相电流频谱瀑布图
%
% 依赖外部文件：f_sliding_window_generate.m、f_fft_simple.m、f_savefig.m
%               （列名检索与 CSV 读取辅助函数内置在文件末尾）
% =========================================================================

clear; close all; clc

%% ==================== 用户配置区 ====================

% ---- 指定要分析的 CSV 文件（只读这一个文件）----
RootDir  = '../02-fault_rec_data/故障波形/';                 % CSV 所在目录
% CSV_FILE = '2026-10-06@15-54-39.560000.csv'; 
CSV_FILE = 'SH12286_RCD_16935_20261006_094931_670_S__rate10000Hz.csv';% 文件名（相对 RootDir）或绝对路径

% CSV 编码：'auto' = 自动探测；也可强制指定 'GBK' / 'UTF-8' / 'GB18030'
CSV_ENCODING = 'auto';

% 只读取命中的列（避免整表读入；更省内存、更快，建议保持 true）
READ_ONLY_SELECTED_COLS = true;

% ---- 测点关键词（★核心：给定多个关键词 → 多个测点）----
%   每个元素 = 一个测点（一条线路 / 一条母线）：
%     char  → 单个关键词
%     cell  → 多个关键词，需**同时命中**才选中
%   脚本会自动从命中列里按相别拆出三相电压（Ua/Ub/Uc）与三相电流（Ia/Ib/Ic），
%   并自动排除 3U0 / 3I0 等派生零序通道：
%     · 电流测点（线路电流）：{'光伏线311','电流'} → 命中 Ia/Ib/Ic 三列；
%     · 电压测点（母线电压）：{'35kV5母电压'}     → 命中 Ua/Ub/Uc 三列。
%   若某测点同时含电压与电流（列名同时含 Ua/Ub/Uc 与 Ia/Ib/Ic），则两组图都会画。
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

% 只处理列表中的第几个测点：[] = 全部处理；也可写向量，如 [1 3 5]
POINT_SEL = [];

% 相别后缀顺序：命中列会按此顺序重排（U 在前、I 在后，便于按相别分组）
PHASE_ORDER = {'Ua', 'Ub', 'Uc', 'Ia', 'Ib', 'Ic'};

% 只保留能识别出相别的列（Ua/Ub/Uc、Ia/Ib/Ic），自动排除 3U0 / 3I0 等派生零序通道
KEEP_ONLY_PHASE_COLS = true;

% ---- 采样频率与时间截取 ----
cfg.sample_freq = int64(10e3);   % 采样频率 (Hz)
cfg.t_start     = 0;             % 数据截取起始 (s)
cfg.t_end       = 1.5;           % 数据截取结束 (s)（本文件约 1.4 s，取满以得到多窗瀑布图）

% ---- 滑动窗参数 ----
%   t_span:      窗长时间 (s)，频率分辨率 = 1/t_span
%   window_step: 窗每次向前移动的距离 (采样点数)
%   窗的数量由数据长度自动计算，无需手动指定
cfg.t_span       = 1;
cfg.window_width = cfg.t_span * cfg.sample_freq;   % 窗宽（采样点数）
cfg.window_step  = 100;                            % 窗移动步长（采样点）

% 窗函数类型（抑制频谱旁瓣泄漏，瀑布图效果更清晰）
%   'none'(默认/矩形窗) | 'hann' | 'hamming' | 'blackman'
cfg.window_type = 'hann';

% 频率范围
cfg.freq_limit = 100;            % 关注 0:N Hz 频段

% 瀑布图去基波：在瀑布图中屏蔽某频率附近的 bin，避免基波幅值过大淹没谐波
cfg.notch_freq      = 50;        % 要屏蔽的中心频率 (Hz)，设为 [] 则不去除
cfg.notch_halfwidth = 2;         % 屏蔽的半带宽 (Hz)

% 绘图：surf 使用哪一相 (1=A, 2=B, 3=C)
cfg.surf_phase = 1;

% 杂项
cfg.font_size = 14;
cfg.verbose   = true;            % 循环中打印进度

% ---- 输出参数 ----
FigSaveFormat     = {'fig', 'png'};   % 保存格式
FigSaveResolution = 300;              % 位图分辨率 (dpi)
OUTPUT_PARENT     = '';               % 留空 = 保存在 CSV 同目录；也可指定输出根目录

% 输出**目录名**前缀：最终目录 = <输出根目录>/<前缀><CSV文件名(去扩展名)>
%   用于把本脚本的输出与其它脚本区分开，避免混进同一个文件夹。留空 '' = 不加前缀。
OUTPUT_DIR_PREFIX = 'SWFFT_';


%% ==================== 定位 CSV 与输出目录 ====================
if exist(CSV_FILE, 'file')
    MatUrl = CSV_FILE;
else
    MatUrl = fullfile(RootDir, CSV_FILE);
end
if ~exist(MatUrl, 'file')
    error('找不到数据文件：%s', MatUrl);
end
[~, CSV_BASE] = fileparts(MatUrl);

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
fprintf('采样率 FS：%d Hz，时间截取：%.3f ~ %.3f s\n', ...
    double(cfg.sample_freq), cfg.t_start, cfg.t_end);
fprintf('滑动窗：窗长 %.3f s (%d 点)，步长 %d 点\n', ...
    cfg.t_span, cfg.window_width, cfg.window_step);
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
nPointIn  = numel(POINT_KEYWORDS);
pointName = {};    % 测点名称（关键词拼接）
pointUIdx = {};    % 该测点的三相电压列索引（可能为空）
pointIIdx = {};    % 该测点的三相电流列索引（可能为空）

fprintf('\n========== 测点检索 ==========\n');
for p = 1:nPointIn
    kws = f_to_cellstr(POINT_KEYWORDS{p});
    idx = f_find_cols_by_keywords(colNamesClean, kws, true);
    if isempty(idx)
        warning('测点 %d [%s] 未命中任何列，已跳过。', p, strjoin(kws, ' + '));
        continue
    end
    [idx, labels] = f_order_by_phase(colNamesClean, idx, PHASE_ORDER, KEEP_ONLY_PHASE_COLS);

    % 按相别把命中列拆成「电压组」与「电流组」
    isU  = ismember(labels, {'Ua', 'Ub', 'Uc'});
    isI  = ismember(labels, {'Ia', 'Ib', 'Ic'});
    idxU = idx(isU);   labU = labels(isU);
    idxI = idx(isI);   labI = labels(isI);

    okU = isequal(labU, {'Ua', 'Ub', 'Uc'});
    okI = isequal(labI, {'Ia', 'Ib', 'Ic'});
    if ~okU && ~okI
        warning(['测点 %d [%s] 命中 %d 列（%s），既非完整三相电压(Ua/Ub/Uc)，' ...
                 '也非完整三相电流(Ia/Ib/Ic)，已跳过。'], ...
            p, strjoin(kws, ' + '), numel(idx), strjoin(labels, ', '));
        continue
    end

    pointName{end+1} = strjoin(kws, '+');   %#ok<SAGROW>
    pointUIdx{end+1} = idxU;                %#ok<SAGROW>
    pointIIdx{end+1} = idxI;                %#ok<SAGROW>

    fprintf('\n测点 %d [%s] 命中 %d 列：\n', p, strjoin(kws, ' + '), numel(idx));
    for k = 1:numel(idx)
        fprintf('  [%3d] %-4s %s\n', idx(k), labels{k}, colNames{idx(k)});
    end
    if ~okU, fprintf('  （注意：未识别出完整三相电压，本测点将只画电流相关图）\n'); end
    if ~okI, fprintf('  （注意：未识别出完整三相电流，本测点将只画电压相关图）\n'); end
end

nPoint = numel(pointName);
if nPoint == 0
    error('没有任何测点命中，请检查 POINT_KEYWORDS 或 CSV_ENCODING。');
end

% ---- 按 POINT_SEL 筛选要处理的测点 ----
if isempty(POINT_SEL)
    selList = 1:nPoint;
else
    selList = POINT_SEL(:)';
    assert(all(selList >= 1 & selList <= nPoint), ...
        'POINT_SEL 超出范围（有效范围 1 ~ %d）。', nPoint);
end
nSel = numel(selList);
fprintf('\n共命中 %d 个测点，本次处理 %d 个。\n', nPoint, nSel);


%% ==================== 读取数据（只读命中的列） ====================
allIdx = [];
for k = 1:nPoint
    allIdx = [allIdx, pointUIdx{k}, pointIIdx{k}];   %#ok<AGROW>
end
allIdx   = unique(allIdx);
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

% ---- 时间截取 ----
idx_start = cfg.t_start * cfg.sample_freq + 1;
idx_end   = cfg.t_end   * cfg.sample_freq;
assert(idx_start < idx_end && idx_end <= row, ...
    '时间截取范围超出数据长度。t_end=%g s，数据行数=%d', cfg.t_end, row);

data_sel = double(RawData(idx_start:idx_end, :));


%% ==================== 滑动窗生成 ====================
data_len = size(data_sel, 1);
[win_idx_mat, n_windows] = f_sliding_window_generate(...
    1, cfg.window_width, cfg.window_step, data_len);

fprintf('窗宽=%.2f s (%d 点), 步长=%d 点, 共 %d 个窗\n', ...
    cfg.t_span, cfg.window_width, cfg.window_step, n_windows);

if n_windows < 2
    warning(['只生成 %d 个窗：3D surf（幅值谱 / 相位谱）至少需要 2 个窗才能成图，' ...
             '将跳过 surf 图，只输出瀑布图。请增大 cfg.t_end 或减小 cfg.t_span。'], n_windows);
end


%% ==================== 频率轴 / 绘图参数（所有测点共用） ====================
% 频率分辨率 Δf = fs / window_width = 1 / t_span
delta_f = double(cfg.sample_freq) / double(cfg.window_width);
n_bins  = round(cfg.freq_limit / delta_f) + 1;

% 频率轴（与 f_fft_simple 内部公式一致）
freq_ax_full = transpose(double(cfg.sample_freq) * ...
    (0:(double(cfg.window_width) / 2)) / double(cfg.window_width));
freq_ax = freq_ax_full(1:n_bins);

% 瀑布图去基波：频率屏蔽掩码
if ~isempty(cfg.notch_freq)
    notch_mask = (freq_ax >= cfg.notch_freq - cfg.notch_halfwidth) ...
               & (freq_ax <= cfg.notch_freq + cfg.notch_halfwidth);
else
    notch_mask = false(size(freq_ax));
end

% 图形尺寸（单位：cm，第 3、4 个数 = 宽、高）
LEFT_POSITION   = 5;
BOTTOM_POSITION = 1;
WIDTH_NUM       = 24;
HEIGHT_NUM      = 12;
POSITION_SET    = [LEFT_POSITION, BOTTOM_POSITION, WIDTH_NUM, HEIGHT_NUM];
% 瀑布图需要更多纵向空间以分辨细频率间隔
WATERFALL_HEIGHT = 28;
WATERFALL_POS    = [LEFT_POSITION, BOTTOM_POSITION, WIDTH_NUM, WATERFALL_HEIGHT];

ph = cfg.surf_phase;
phase_labels = {'A', 'B', 'C'};


%% ==================== 逐测点：滑动窗 FFT → 频谱 → 出图 ====================
win_center_t = zeros(n_windows, 1);

for si = 1:nSel
    p    = selList(si);
    name = pointName{p};
    hasU = ~isempty(pointUIdx{p});
    hasI = ~isempty(pointIIdx{p});

    fprintf('\n---- 测点 %d/%d：%s（电压:%d  电流:%d）----\n', ...
        si, nSel, name, hasU, hasI);

    if hasU, uabc = data_sel(:, posOf(pointUIdx{p})); end
    if hasI, iabc = data_sel(:, posOf(pointIIdx{p})); end

    % ---- 频谱预分配（n_windows × n_bins × 3 相）----
    %   统一预分配，缺哪一组时对应的矩阵不参与计算与绘图
    U_mag = zeros(n_windows, n_bins, 3);
    U_ang = zeros(n_windows, n_bins, 3);
    I_mag = zeros(n_windows, n_bins, 3);
    I_ang = zeros(n_windows, n_bins, 3);

    % ---- 核心计算：逐窗 FFT ----
    for win_idx = 1:n_windows
        left  = win_idx_mat(win_idx, 1);
        right = win_idx_mat(win_idx, 2);

        % 窗中心时间
        win_center_t(win_idx) = (left + right) / 2 / double(cfg.sample_freq) + cfg.t_start;

        if hasU
            uabc_win = uabc(left:right, :);
            for k = 1:3
                [~, um, ua] = f_fft_simple(uabc_win(:, k), ...
                    cfg.sample_freq, cfg.window_width, cfg.window_type);
                U_mag(win_idx, :, k) = um(1:n_bins)';
                U_ang(win_idx, :, k) = ua(1:n_bins)';
            end
        end
        if hasI
            iabc_win = iabc(left:right, :);
            for k = 1:3
                [~, im, ia] = f_fft_simple(iabc_win(:, k), ...
                    cfg.sample_freq, cfg.window_width, cfg.window_type);
                I_mag(win_idx, :, k) = im(1:n_bins)';
                I_ang(win_idx, :, k) = ia(1:n_bins)';
            end
        end

        if cfg.verbose
            fprintf('  win=%d/%d\n', win_idx, n_windows);
        end
    end

    [X, Y]   = meshgrid(win_center_t, freq_ax);
    baseName = f_safe_filename(sprintf('%02d_%s', si, name));

    % ================================================================
    %  图1：电压幅值谱 3D surf（指定相）
    % ================================================================
    if hasU && n_windows >= 2
        figure;
        surf(X, Y, squeeze(U_mag(:, :, ph))', 'EdgeColor', 'none');
        shading interp;
        xlabel('时间 (s)', 'FontSize', cfg.font_size);
        ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
        zlabel('幅值', 'FontSize', cfg.font_size);
        title(sprintf('%s - 电压幅值谱 (%s相) — 滑动窗 FFT', name, phase_labels{ph}), ...
            'FontSize', cfg.font_size);
        colorbar;
        view(3);
        set(gcf, 'unit', 'centimeters', 'position', POSITION_SET);
        f_savefig(OutDir, [baseName '_电压幅值谱surf'], FigSaveFormat, FigSaveResolution);
        close(gcf)
    end

    % ================================================================
    %  图2：电压相位谱 3D surf（指定相）
    % ================================================================
    if hasU && n_windows >= 2
        figure;
        surf(X, Y, rad2deg(squeeze(U_ang(:, :, ph)))', 'EdgeColor', 'none');
        shading interp;
        xlabel('时间 (s)', 'FontSize', cfg.font_size);
        ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
        zlabel('相位 (°)', 'FontSize', cfg.font_size);
        title(sprintf('%s - 电压相位谱 (%s相) — 滑动窗 FFT', name, phase_labels{ph}), ...
            'FontSize', cfg.font_size);
        colorbar;
        view(3);
        set(gcf, 'unit', 'centimeters', 'position', POSITION_SET);
        f_savefig(OutDir, [baseName '_电压相位谱surf'], FigSaveFormat, FigSaveResolution);
        close(gcf)
    end

    % ================================================================
    %  图3：三相电压频谱瀑布图
    % ================================================================
    if hasU
        figure;
        for k = 1:3
            subplot(3, 1, k);
            data_plot = squeeze(U_mag(:, :, k))';
            data_plot(notch_mask, :) = NaN;
            imagesc(win_center_t, freq_ax, data_plot);
            set(gca, 'YDir', 'normal');
            xlabel('时间 (s)', 'FontSize', cfg.font_size);
            ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
            title(sprintf('%s - 三相电压频谱瀑布图 — %s相', name, phase_labels{k}), ...
                'FontSize', cfg.font_size);
            colorbar;
            colormap('jet');
        end
        set(gcf, 'unit', 'centimeters', 'position', WATERFALL_POS);
        f_savefig(OutDir, [baseName '_三相电压瀑布图'], FigSaveFormat, FigSaveResolution);
        close(gcf)
    end

    % ================================================================
    %  图4：三相电流频谱瀑布图
    % ================================================================
    if hasI
        figure;
        for k = 1:3
            subplot(3, 1, k);
            data_plot = squeeze(I_mag(:, :, k))';
            data_plot(notch_mask, :) = NaN;
            imagesc(win_center_t, freq_ax, data_plot);
            set(gca, 'YDir', 'normal');
            xlabel('时间 (s)', 'FontSize', cfg.font_size);
            ylabel('频率 (Hz)', 'FontSize', cfg.font_size);
            title(sprintf('%s - 三相电流频谱瀑布图 — %s相', name, phase_labels{k}), ...
                'FontSize', cfg.font_size);
            colorbar;
            colormap('jet');
        end
        set(gcf, 'unit', 'centimeters', 'position', WATERFALL_POS);
        f_savefig(OutDir, [baseName '_三相电流瀑布图'], FigSaveFormat, FigSaveResolution);
        close(gcf)
    end
end

fprintf('\n===== 全部完成，共处理 %d 个测点，结果保存在：%s =====\n', nSel, OutDir);


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
    % 若 keepOnlyPhase=true 且已识别到相别，则丢弃（排除 3U0/3I0 等派生通道）
    if ~(keepOnlyPhase && ~isempty(idxOut))
        for k = 1:numel(idxIn)
            if ~used(k)
                idxOut(end+1) = idxIn(k);                              %#ok<AGROW>
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
