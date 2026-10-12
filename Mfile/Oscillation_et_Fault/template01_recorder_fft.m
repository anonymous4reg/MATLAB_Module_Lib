%% template01_recorder_fft.m  —  故障录波 CSV：多测点「正序/负序」FFT 批量出图
% version 2.0  revised by Yamin
%
% 本脚本由 v1.0（手写列号、单测点）改写而来，主要改动：
%   1. 测点改用「列名关键词」检索给定（思路同 template02b / da01b），不再手写列号；
%   2. 支持一次指定**多个测点**，逐个做序分量 FFT 并出图；
%   3. 每个测点单独一张图，以 fig + png 两种格式保存到与 **CSV 同名** 的独立目录；
%   4. 加入与 template02b 一致的**时间切片**：
%        SELECTED_RANGE = (FS*T_STEP_IDX+1) : (FS*(T_STEP_IDX+1))
%      即只分析第 T_STEP_IDX 个「1 秒」窗口（T_STEP_IDX=0 → 文件开头 1 秒）。
%
% ------------------------------------------------------------------------
% 用法：
%   1) 指定 CSV_FILE（文件名，相对 RootDir；也可直接写绝对路径）；
%   2) 设定 FS —— 采样率，必须与 CSV 实际采样率一致；
%   3) 在 POINT_KEYWORDS 中列出测点，每个元素是一个测点：
%        char → 单个关键词
%        cell → 多个关键词，需**同时命中**才选中
%      ★序分量分解需要**恰好三相**，故每个测点必须能检索出
%        恰好 3 个相别列（Ua/Ub/Uc 或 Ia/Ib/Ic），否则该测点会被跳过并给出警告；
%   4) 运行，结果保存在 <CSV目录>/<OUTPUT_DIR_PREFIX><CSV文件名>/ 下，
%      文件名为 NN_测点名.fig|.png。目录名前缀可用 OUTPUT_DIR_PREFIX 自定义，
%      用于与其它脚本的输出区分开（留空 '' = 不加前缀）。
%
% 编码说明：故障录波 CSV 多为 GBK，脚本会自动探测（UTF-8 / GBK），
%           也可用 CSV_ENCODING 强制指定。
%
% 性能说明：默认 READ_ONLY_SELECTED_COLS = true，只把命中的列读进内存。
%
% 依赖外部文件：f_3ph_fft_pn0.m、f_fft_simple.m、f_savefig.m、
%               f_set_fig_size.m、f_set_fontface.m
% =========================================================================

clear; close all; clc

%% ==================== 用户定义区 ====================

% ---- 指定要分析的 CSV 文件（只读这一个文件）----
RootDir  = '../02-fault_rec_data/故障波形/';              % 数据目录
% CSV_FILE = '2026-10-05@09-45-16.180000.csv';
% CSV_FILE = '2026-10-06@09-49-31.670100.csv';
% CSV_FILE = '2026-10-06@15-54-39.560000.csv';
% CSV_FILE = 'ctz_2026-10-05@09-46-16.262000.csv';
CSV_FILE = 'SH12286_RCD_16935_20261006_094931_670_S__rate10000Hz.csv'; % 文件名（相对 RootDir）或绝对路径

% CSV 编码：'auto' = 自动探测；也可强制指定 'GBK' / 'UTF-8' / 'GB18030'
CSV_ENCODING = 'auto';

% 只读取命中的列（避免整表读入；更省内存、更快，建议保持 true）
READ_ONLY_SELECTED_COLS = true;

% ---- 测点关键词（★每个测点需检索出恰好 3 个相别列）----
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

% 相别后缀顺序：命中列会按此顺序重排（Ua/Ub/Uc 或 Ia/Ib/Ic）
PHASE_ORDER = {'Ua', 'Ub', 'Uc', 'Ia', 'Ib', 'Ic'};

% 只保留能识别出相别的列（Ua/Ub/Uc、Ia/Ib/Ic），自动排除 3U0 / 3I0 等派生零序通道
KEEP_ONLY_PHASE_COLS = true;

% ---- 采样与 FFT 参数 ----
FS = int64(10e3);        % 采样率 Hz（★必须与 CSV 一致，如 1000 / 5000 / 10e3）
T_STEP_IDX = 0;          % 第几个 1 秒窗口，0 = 从文件开头
FFT_WINDOW = 'hann';     % f_fft_simple 的窗：none / hann / hamming / blackman

% ---- 绘图参数 ----
XaxisLimit = [0, 300];       % 频谱横轴范围 (Hz)
YaxisLimit = [];             % 幅值谱纵轴范围，留空 [] = 自动
FONT_SIZE = 14;
LINEWIDTH = 1.3;
FIG_POS  = [5, 5];           % 图形左下角位置 (cm)
FIG_SIZE = [15, 12];         % 图形宽、高 (cm)

% ---- 输出参数 ----
FigSaveFormat = {'fig', 'png'};   % 保存格式
FigSaveResolution = 300;          % 位图分辨率 (dpi)
OUTPUT_PARENT = '';               % 留空 = 保存在 CSV 同目录；也可指定输出根目录

% 输出**目录名**前缀：最终目录 = <输出根目录>/<前缀><CSV文件名(去扩展名)>
%   用于把本脚本的输出与其它脚本区分开，避免混进同一个文件夹。
%   例：前缀 'T01_' + CSV '2026-10-05@09-45-16.180000'
%       → 目录 'T01_2026-10-05@09-45-16.180000'
%   留空 '' = 不加前缀（目录名与 CSV 同名，与旧版一致）。
OUTPUT_DIR_PREFIX = 'T01_';


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
pointIdx   = {};      % 测点对应的原始列索引（恰好 3 个）
pointLabel = {};      % 每列的短标签（Ua/Ub/Uc 或 Ia/Ib/Ic）

fprintf('\n========== 测点检索 ==========\n');
for p = 1:nPointIn
    kws = f_to_cellstr(POINT_KEYWORDS{p});
    idx = f_find_cols_by_keywords(colNamesClean, kws, true);
    if isempty(idx)
        warning('测点 %d [%s] 未命中任何列，已跳过。', p, strjoin(kws, ' + '));
        continue
    end
    [idx, labels] = f_order_by_phase(colNamesClean, idx, PHASE_ORDER, KEEP_ONLY_PHASE_COLS);

    % 序分量分解要求恰好三相，且相别能被正确识别
    if ~(isequal(labels, {'Ua', 'Ub', 'Uc'}) || isequal(labels, {'Ia', 'Ib', 'Ic'}))
        warning(['测点 %d [%s] 命中 %d 列（%s）。序分量分解需要恰好 3 个相别列 ' ...
                 '(Ua/Ub/Uc 或 Ia/Ib/Ic)，已跳过。'], ...
            p, strjoin(kws, ' + '), numel(idx), strjoin(labels, ', '));
        continue
    end

    pointName{end+1}  = strjoin(kws, '+');   %#ok<SAGROW>
    pointIdx{end+1}   = idx;                 %#ok<SAGROW>
    pointLabel{end+1} = labels;              %#ok<SAGROW>

    fprintf('\n测点 %d [%s] 命中 %d 列：\n', p, strjoin(kws, ' + '), numel(idx));
    for k = 1:numel(idx)
        fprintf('  [%3d] %-6s %s\n', idx(k), labels{k}, colNames{idx(k)});
    end
end

nPoint = numel(pointName);
if nPoint == 0
    error('没有任何测点命中（或命中的都不是三相组），请检查 POINT_KEYWORDS 或 CSV_ENCODING。');
end
fprintf('\n共命中 %d 个三相测点。\n', nPoint);


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

% ---- 时间切片（与 template02b 一致：第 T_STEP_IDX 个 1 秒窗口）----
SELECTED_RANGE = (FS*T_STEP_IDX+1):(FS*(T_STEP_IDX+1));
if double(max(SELECTED_RANGE)) > row
    error(['取样区间 %d ~ %d 超出数据长度 %d 行。', ...
           '请检查 FS（当前 %d Hz）与 T_STEP_IDX（当前 %d）。'], ...
        double(min(SELECTED_RANGE)), double(max(SELECTED_RANGE)), row, double(FS), T_STEP_IDX);
end
fprintf('时间切片：第 %d 秒，行 %d ~ %d（共 %d 点）\n', ...
    T_STEP_IDX, double(min(SELECTED_RANGE)), double(max(SELECTED_RANGE)), numel(SELECTED_RANGE));


%% ==================== 逐测点 序分量 FFT + 出图 ====================
for p = 1:nPoint
    cols = posOf(pointIdx{p});
    target_data = double(RawData(SELECTED_RANGE, cols));   % 切片后恰好 FS×3
    [~, nCol] = size(target_data);

    fprintf('\n---- 测点 %d/%d：%s（%d 列）----\n', p, nPoint, pointName{p}, nCol);

    % 序分量 FFT：正序 / 负序 / 零序（列序 = [正序, 负序, 零序]）
    [freq_ax, mag_ax, ang_ax, cmp_ax] = f_3ph_fft_pn0(target_data, FS, FS, FFT_WINDOW); %#ok<ASGLU>

    % 单位（从列名末尾括号中提取，如 (kA)、(kV)）
    unitStr = f_unit_from_name(colNames{pointIdx{p}(1)});
    if isempty(unitStr)
        labMag = '幅值';
    else
        labMag = ['幅值(' unitStr ')'];
    end

    % 打印 50 Hz 处的正/负/零序幅值，便于快速核对
    [~, iF] = min(abs(freq_ax - 50));
    fprintf('  @50Hz：正序 %.4f，负序 %.4f，零序 %.4f %s\n', ...
        mag_ax(iF, 1), mag_ax(iF, 2), mag_ax(iF, 3), unitStr);

    figure('Name', sprintf('%s — %s', CSV_BASE, pointName{p}));

    % ---- 子图 1：正序幅值谱 ----
    subplot(2, 2, 1)
    plot(freq_ax, mag_ax(:, 1), 'LineWidth', LINEWIDTH)
    title('Positive Sequence')
    ylabel(labMag)
    xlabel('Frequency (Hz)')
    grid on
    set(gca, 'xlim', XaxisLimit)
    if ~isempty(YaxisLimit)
        set(gca, 'ylim', YaxisLimit)
    end
    f_set_fontface(gca, 'TimesNewRomanSimsun')
    set(gca, 'fontsize', FONT_SIZE)

    subplot(2, 2, 3)
    plot(freq_ax, rad2deg(ang_ax(:, 1)), 'LineWidth', LINEWIDTH)
    title('Positive Sequence')
    ylabel('Phase (deg)')
    xlabel('Frequency (Hz)')
    grid on
    set(gca, 'xlim', XaxisLimit)
    if ~isempty(YaxisLimit)
        set(gca, 'ylim', YaxisLimit)
    end
    f_set_fontface(gca, 'TimesNewRomanSimsun')
    set(gca, 'fontsize', FONT_SIZE)

    % ---- 子图 2：负序幅值谱 ----
    subplot(2, 2, 2)
    plot(freq_ax, mag_ax(:, 2), 'LineWidth', LINEWIDTH)
    title('Negative Sequence')
    ylabel(labMag)
    xlabel('Frequency (Hz)')
    grid on
    set(gca, 'xlim', XaxisLimit)
    if ~isempty(YaxisLimit)
        set(gca, 'ylim', YaxisLimit)
    end
    f_set_fontface(gca, 'TimesNewRomanSimsun')
    set(gca, 'fontsize', FONT_SIZE)

    subplot(2, 2, 4)
    plot(freq_ax, rad2deg(ang_ax(:, 2)), 'LineWidth', LINEWIDTH)
    title('Negative Sequence')
    ylabel('Phase (deg)')
    xlabel('Frequency (Hz)')
    grid on
    set(gca, 'xlim', XaxisLimit)
    if ~isempty(YaxisLimit)
        set(gca, 'ylim', YaxisLimit)
    end
    f_set_fontface(gca, 'TimesNewRomanSimsun')
    set(gca, 'fontsize', FONT_SIZE)

    sgtitle(sprintf('%s — %s', CSV_BASE, pointName{p}), 'Interpreter', 'none')

    f_set_fig_size(gcf, FIG_POS, FIG_SIZE);

    % ---- 保存 fig + png ----
    safeName = f_safe_filename(sprintf('%02d_%s', p, pointName{p}));
    f_savefig(OutDir, safeName, FigSaveFormat, FigSaveResolution);

    close(gcf)
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
