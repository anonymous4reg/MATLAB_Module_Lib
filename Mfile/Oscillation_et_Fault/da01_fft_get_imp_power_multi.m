%% da01c_fft_get_imp_power_multi.m  —  多测点「谐波阻抗 + 谐波功率」批量计算与出图
% version 2.6  revised by Yamin
%
% 本脚本由 da01_fft_get_imp_universal.m (v3.1) 改写而来，主要改动：
%   1. 测点不再手写列号，改为**列名关键词检索**（思路同 template02b / da01b）；
%   2. 测点按「**母线组**」组织：一个电压测点 + 挂在该母线上的若干电流支路
%      （实际录波中，多条支路的电流汇聚到同一段母线，因此共用一个电压测点）；
%   3. 【v2.0 · 走 B 方案】恢复原程序的**凯泽窗（Kaiser）精细频谱 + 频带功率积分**：
%        · 频带功率：在 [f_c-W, f_c+W] 内按 0.1 Hz 步长做加窗 DFT，
%          对 P、Q **都**在频带内求和，再除以等效噪声带宽 ENBW 校正；
%        · 阻抗：在频带中心 f_c 处取单点复幅值，Z = U(f_c) / I(f_c)。
%   4. 【v2.0】阻抗**分正序 / 负序**分别统计，并画成**极坐标图**
%      （半径 = |Z|，极角 = ∠Z），一张图里叠加该母线下所有支路。
%   5. 输出：
%        · Excel 文本汇总（母线 / 支路 / 频率 / 正负序 / 阻抗 / 功率）
%        · 每个 (母线组, 分析频率) 的「极坐标阻抗图」：
%            ① 正序 + 负序 合画一张
%            ② 正序单独一张   （POLAR_SPLIT_SEQ_FIG = true 时）
%            ③ 负序单独一张   （POLAR_SPLIT_SEQ_FIG = true 时）
%        · 每个母线组一张「功率柱状图」：每个频点一张子图，柱状显示各支路的 P、Q
%      全部以 fig + png 保存到 <CSV目录>/<OUTPUT_DIR_PREFIX><CSV名>/ 下。
%
%   注：【v2.1】不再输出任何「按频率展开」的阻抗曲线（|Z|-f、∠Z-f）。
%       因此粗谱（f_3ph_fft_pn0）也失去用途，已从计算流程中整体移除，
%       本脚本只做「指定频点」的阻抗 / 功率计算。
%   注：【v2.2】极坐标图支持「正序 / 负序」分开单独出图（见 POLAR_SPLIT_SEQ_FIG）。
%       阻抗取频带中心 f_c 处的**单点**复相量，**不做频带积分**（只有 P/Q 做积分），
%       故阻抗图标题中不再出现「频带 / 积分」字样。
%   注：【v2.3】支路配色改用**自动生成的高区分度配色**（见 COLOR_SCHEME / f_distinct_colors）。
%       MATLAB 自带 lines(n) 在 n>7 时会循环重复颜色（n=9 时第 8、9 条支路与第 1、2 条
%       颜色完全相同），支路一多就无法分辨；新配色保证任意两条支路的颜色都明显不同。
%   注：【v2.4】配色算法重写（f_distinct_colors）：
%       旧算法（色相分箱 + 最鲜艳 + CIE76 贪心）实测最小 CIEDE2000 色差只有 ~15.5，
%       与 Tableau10(16.2) / Okabe-Ito(21.7) 同一水平，细线下仍会看混；
%       现改为「CIEDE2000 最远点采样 + 局部交换改进」，n=9 时最小色差 ~36。
%       另保留一层**线型兜底**：若仍有 ΔE(CIE76) < POLAR_CLOSE_COLOR_DE 的
%       "看起来同色"支路，会自动分到实线 / 虚线 / 点线 / 点划线。
%       （新配色下该兜底不会触发，属安全网；设 POLAR_CLOSE_COLOR_DE=0 可关闭。）
%   注：【v2.5】配色继续调优（f_distinct_colors / f_assign_linestyles）：
%       · 候选色明度上限 80 → 72。上限 80 时会挑出「浅紫 #BFBFFF」这类发白、
%         白底上几乎看不清的颜色；压到 72 后每个颜色彩度 C* ≥ 32，与白底的
%         最小对比度由 1.73 提到 2.28，而最小 ΔE00 仅由 28.9 降到 27.8。
%       · 线型兜底判据由 CIE76 改为 **CIEDE2000**，阈值 50 → 28.5（口径与配色一致）。
%         实测两者对"哪对最像"判断差别很大：CIEDE2000 认为最近的是
%         「312 橄榄 vs H5 绿」(27.7)，CIE76 却认为是「314 墨绿 vs 317 青」(35.2)。
%       · 探索结论（n=12）：目标函数用「最大最小 ΔE00」最好（27.8），远优于
%         "色相 30° 等分 + 每色相取最艳"(仅 10.4，会出两条几乎一样的红) 与
%         "最大化平均 ΔE00"(20.8，最差一对明显更近)；"色相间隔 ≥ 25°"对 12 色无解。
%         （候选色网格由 13 加密到 17/21 仅把 27.8 抬到 28.8/29.2，性价比低，仍用 13。）
%   注：【v2.6】「正序 / 负序 单独」的极坐标图改用**较窄画幅**（见 POLAR_FIG_SIZE_1，
%       默认 15×13 cm）；单面板在其中居中、且保持近似正方形（物理尺寸与合画时的
%       单个面板相当）。此前单面板沿用 24 cm 的合画画幅，左右各空一大片、字号显得很小。
%       「正序 + 负序 合画」仍用 POLAR_FIG_SIZE（24×13 cm）。
%
% ------------------------------------------------------------------------
% ★★ 测点怎么给？★★
%   用「母线组」：
%     BUS_GROUPS = {
%         { 母线电压关键词, { 支路电流关键词1, 支路电流关键词2, ... } };
%         ...
%     };
%   · 母线电压关键词：char 或 cell（cell 时需**同时命中**才选中）
%   · 支路电流关键词：char 或 cell，每行一个支路
%   · 每个支路实际用的关键词 = 支路关键词 + BRANCH_COMMON_KEYWORDS
%     （例如 BRANCH_COMMON_KEYWORDS = {'电流'}，支路写 '光伏线311'
%       就会去匹配同时含 '光伏线311' 与 '电流' 的列）
%   · 电压测点必须能检索出 Ua/Ub/Uc 三相；支路必须能检索出 Ia/Ib/Ic（或 Ua/Ub/Uc）三相
%
%   例（多条光伏线 + SVG 都挂在 35kV 5 母上，共用同一个母线电压）：
%     BUS_GROUPS = {
%         { {'35kV5母电压'}, { '光伏线311', '光伏线312', '光伏线313', 'SVG' } };
%     };
%
% ★★ 计算口径 ★★
%   · 序分量：由三相复相量做对称分量分解
%       正序 F1 = (Fa + a ·Fb + a²·Fc) / 3
%       负序 F2 = (Fa + a²·Fb + a ·Fc) / 3        (a = exp(j·2π/3))
%   · 谐波阻抗 Z(f) = U_seq(f) / I_seq(f)     [Ω]（电压 kV / 电流 kA 时正好为 Ω）
%       正序阻抗 Z1 = U1 / I1，负序阻抗 Z2 = U2 / I2
%   · 谐波功率 S(f) = 1.5 · U(f) · conj(I(f))  → P = real(S)，Q = imag(S)
%       （峰值相量下 1.5·V_peak·I_peak = 3·V_rms·I_rms，即三相功率；
%         电压 kV、电流 kA 时 S 的单位为 MVA）。正序、负序分别计算。
%   · **频带积分**：P、Q 都在 [f_c-W, f_c+W] 内按 0.1 Hz 精细谱求和后除以 ENBW；
%     W = BAND_HALF_WIDTH。正序、负序都做频带积分。
%     视在功率 S、功率因数 PF 由积分后的 P、Q 反算（S=√(P²+Q²)，PF=P/S），
%     与 P、Q 口径一致。
%   · 阻抗则取**频带中心 f_c 处的单点复相量** Z = U(f_c)/I(f_c)（与原程序一致）。
%
% 依赖外部文件：f_savefig.m、f_set_fig_size.m、f_set_fontface.m
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

% ---- 支路关键词的公共附加词（与每个支路关键词**同时命中**才选中）----
%   若所有支路列名都形如 '...光伏线311电流_Ia(kA)'，填 {'电流'} 即可；
%   不需要附加就留空 {}。
BRANCH_COMMON_KEYWORDS = {'电流'};

% ---- 测点配置：母线组 = { 母线电压关键词, { 各支路电流关键词 } } ----
BUS_GROUPS = {
    { {'35kV5母电压'}, {
        '光伏线311', '光伏线312', '光伏线313', '光伏线314', ...
        '光伏线315', '光伏线316', '光伏线317', 'SVG' , '1号变35kV进线'} };
};

% 相别后缀顺序：命中列会按此顺序重排
PHASE_ORDER = {'Ua', 'Ub', 'Uc', 'Ia', 'Ib', 'Ic'};

% ---- 采样 / 时间切片 ----
FS = int64(10e3);        % 采样率 Hz（★必须与 CSV 一致，如 1000 / 5000 / 10e3）
T_START_SEC = 0;         % 起始秒
T_SPAN = 1;              % 分析时长 (s)

% ---- 精细谱（凯泽窗）+ 频带功率积分 ----
KAISER_BETA     = 8;     % 凯泽窗 β 参数（旁瓣衰减 > -100 dB）
FINE_FREQ_STEP  = 0.1;   % 精细谱频率步长 (Hz)
BAND_HALF_WIDTH = 0.5;   % 频带功率积分半宽 W (Hz)；P、Q 都在 [f_c-W, f_c+W] 内积分

% ---- 待分析的频率 (Hz) ----
FREQ_LIST     = [36, 50, 64];   % 可写任意频率（精细谱步长 0.1 Hz，一般都能落到网格上）
USE_AUTO_PEAK = false;          % true: 在 FREQ_LIST 附近自动找正序电流峰值作为频带中心
FREQ_TOL      = 0.5;            % 自动寻峰搜索容差 (Hz)，仅 USE_AUTO_PEAK=true 时生效

% ---- 阻抗有效判据 ----
%   电流小于该值时阻抗无意义（会剧烈发散），绘图 / 汇总时置为 NaN
Z_MIN_CURRENT = 1e-4;    % 单位与电流列一致 (kA)

% ---- 绘图参数 ----
POLAR_RMAX = [];             % 极坐标径向上限，[] = 自动；也可给 [pos_max, neg_max]
POLAR_NTICK = 5;             % 极坐标径向刻度段数
POLAR_SPLIT_SEQ_FIG = true;  % 除「正序+负序合画」外，是否再单独输出正序、负序各一张极坐标图

% 颜色过于接近的支路，改用**不同线型**区分（正序/负序极坐标图）。
%   **CIEDE2000** 色差 ΔE00 < 该阈值的两条支路视为「颜色难以区分」，自动分到不同线型。
%   实测（12 支路、L<=72 配色）：最优配色的最小 ΔE00 ≈ 27.7，且最接近的几对
%   （如「312 橄榄 vs H5 绿」「316 品红 vs H3 紫」）属"同色系"，细线下易混；
%   取 28.5 恰好只给这几对中的后者换线型（12 条里 3 条变虚线），图面不会太花。
%   设为 0 或 [] 即关闭该功能（全部用实线）。
POLAR_CLOSE_COLOR_DE = 28.5;

% 支路配色方案：
%   'distinct'（推荐）= 按色相分箱 + Lab 空间最大最小距离自动生成，支路再多也不会撞色
%   'lines'          = MATLAB 默认 lines(n)。注意 n>7 时它会**循环重复**颜色
%                      （如 n=9 时第 8、9 条支路与第 1、2 条颜色完全相同）
COLOR_SCHEME = 'distinct';
FONT_SIZE = 12;
LINEWIDTH = 1.3;
FIG_POS   = [3, 3];          % 图形左下角位置 (cm)
FIG_SIZE  = [24, 16];        % 图形宽、高 (cm)
POLAR_FIG_SIZE   = [24, 13]; % 极坐标图「正序+负序合画」宽、高 (cm)
% 极坐标图「正序 / 负序 单独」宽、高 (cm)。
%   单面板只有一个圆，若沿用 24 cm 的合画画幅会左右空一大片、字显得很小；
%   这里用较窄的画幅，极坐标圆的实际尺寸与合画时单个面板相当（约 9.5 cm 见方）。
POLAR_FIG_SIZE_1 = [15, 13];

% ---- 输出参数 ----
FigSaveFormat = {'fig', 'png'};   % 保存格式
FigSaveResolution = 300;          % 位图分辨率 (dpi)
OUTPUT_PARENT = '';               % 留空 = 保存在 CSV 同目录；也可指定输出根目录

% 输出**目录名**前缀：最终目录 = <输出根目录>/<前缀><CSV文件名(去扩展名)>
%   用于把本脚本的输出与其它脚本区分开，避免混进同一个文件夹。留空 '' = 不加前缀。
OUTPUT_DIR_PREFIX = 'DA01c_';

SAVE_XLSX = true;                    % 是否写 Excel 汇总
XLSX_NAME = '谐波阻抗与功率.xlsx';    % Excel 文件名（保存在输出目录下）


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
fprintf('采样率 FS：%d Hz，时间窗：%.3f s ~ %.3f s（%d 点）\n', ...
    double(FS), T_START_SEC, T_START_SEC + T_SPAN, double(FS) * T_SPAN);
fprintf('精细谱：凯泽窗 β=%g，步长 %.2f Hz；功率频带积分半宽 W=%.2f Hz（P、Q 都积分）\n', ...
    KAISER_BETA, FINE_FREQ_STEP, BAND_HALF_WIDTH);
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


%% ==================== 关键词检索：确定母线组与各支路 ====================
nGroup   = numel(BUS_GROUPS);
busName  = cell(1, nGroup);   % 母线名（关键词拼接）
busIdx   = cell(1, nGroup);   % 母线电压 3 列索引
brName   = cell(1, nGroup);   % 各支路名（cellstr）
brIdx    = cell(1, nGroup);   % 各支路 3 列索引（cell of 1×3）

fprintf('\n========== 测点检索 ==========\n');
for g = 1:nGroup
    entry  = BUS_GROUPS{g};
    busKw  = f_to_cellstr(entry{1});
    brList = entry{2};

    % ---- 母线电压 ----
    idxU = f_find_cols_by_keywords(colNamesClean, busKw, true);
    if isempty(idxU)
        warning('母线组 %d [%s] 的电压测点未命中任何列，整组跳过。', g, strjoin(busKw, ' + '));
        continue
    end
    [idxU, labU] = f_order_by_phase(colNamesClean, idxU, PHASE_ORDER, true);
    if ~isequal(labU, {'Ua', 'Ub', 'Uc'})
        warning(['母线组 %d [%s] 的电压测点命中 %d 列（%s），' ...
                 '需要恰好 Ua/Ub/Uc 三相，整组跳过。'], ...
            g, strjoin(busKw, ' + '), numel(idxU), strjoin(labU, ', '));
        continue
    end

    busName{g} = strjoin(busKw, '+');
    busIdx{g}  = idxU;

    % ---- 各电流支路 ----
    gName = {};  gIdx = {};
    for b = 1:numel(brList)
        brKw = [f_to_cellstr(brList{b}), f_to_cellstr(BRANCH_COMMON_KEYWORDS)];
        idxI = f_find_cols_by_keywords(colNamesClean, brKw, true);
        if isempty(idxI)
            warning('母线组 %d 的支路 %d [%s] 未命中任何列，已跳过。', ...
                g, b, strjoin(brKw, ' + '));
            continue
        end
        [idxI, labI] = f_order_by_phase(colNamesClean, idxI, PHASE_ORDER, true);
        okI = isequal(labI, {'Ia', 'Ib', 'Ic'});
        okU = isequal(labI, {'Ua', 'Ub', 'Uc'});
        if ~(okI || okU)
            warning(['母线组 %d 的支路 %d [%s] 命中 %d 列（%s），' ...
                     '需要恰好三相（Ia/Ib/Ic 或 Ua/Ub/Uc），已跳过。'], ...
                g, b, strjoin(brKw, ' + '), numel(idxI), strjoin(labI, ', '));
            continue
        end
        gName{end+1} = strjoin(f_to_cellstr(brList{b}), '+');   %#ok<SAGROW>
        gIdx{end+1}  = idxI;                                    %#ok<SAGROW>
    end

    if isempty(gName)
        warning('母线组 %d [%s] 下没有任何可用支路，整组跳过。', g, busName{g});
        continue
    end

    brName{g} = gName;
    brIdx{g}  = gIdx;

    fprintf('\n母线组 %d  电压测点 [%s]\n', g, busName{g});
    for k = 1:3
        fprintf('    %-3s [%3d] %s\n', labU{k}, idxU(k), colNames{idxU(k)});
    end
    fprintf('  支路 %d 条：\n', numel(gName));
    for b = 1:numel(gName)
        fprintf('    %-16s', gName{b});
        for k = 1:3
            fprintf(' [%3d]%s', gIdx{b}(k), colNames{gIdx{b}(k)});
        end
        fprintf('\n');
    end
end

% 去掉跳过的空组
keep = ~cellfun(@isempty, brName);
busName = busName(keep);  busIdx = busIdx(keep);
brName  = brName(keep);   brIdx  = brIdx(keep);
nGroup  = numel(busName);
if nGroup == 0
    error('没有任何母线组命中，请检查 BUS_GROUPS / BRANCH_COMMON_KEYWORDS 或 CSV_ENCODING。');
end
fprintf('\n共 %d 个母线组可用。\n', nGroup);


%% ==================== 读取数据（只读命中的列） ====================
allIdx = [];
for g = 1:nGroup
    allIdx = [allIdx, busIdx{g}, brIdx{g}{:}];   %#ok<AGROW>
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

if usedSelected
    posOf = zeros(1, numel(colNames));
    posOf(allIdx) = 1:numel(allIdx);
else
    posOf = 1:numel(colNames);
end

row = size(RawData, 1);

% ---- 时间切片 ----
N = FS * T_SPAN;
SELECTED_RANGE = (FS*T_START_SEC+1) : (FS*(T_START_SEC+T_SPAN));
if double(max(SELECTED_RANGE)) > row
    error(['取样区间 %d ~ %d 超出数据长度 %d 行。', ...
           '请检查 FS（当前 %d Hz）、T_START_SEC（%g s）与 T_SPAN（%g s）。'], ...
        double(min(SELECTED_RANGE)), double(max(SELECTED_RANGE)), row, ...
        double(FS), T_START_SEC, T_SPAN);
end
fprintf('时间切片：行 %d ~ %d（共 %d 点）\n', ...
    double(min(SELECTED_RANGE)), double(max(SELECTED_RANGE)), numel(SELECTED_RANGE));

% 单位（从列名末尾括号自动提取）
uU = f_unit_from_name(colNames{busIdx{1}(1)});
uI = f_unit_from_name(colNames{brIdx{1}{1}(1)});
if isempty(uU), uU = 'kV'; end
if isempty(uI), uI = 'kA'; end
fprintf('单位：电压 %s，电流 %s（故阻抗为 Ω，功率为 MVA 量级）\n', uU, uI);


%% ==================== 凯泽窗系数（精细谱共用） ====================
wKaiser  = kaiser(double(N), KAISER_BETA);     % N×1
winCorr  = 2 / sum(wKaiser);                   % 峰值恢复系数
ENBW     = double(N) * sum(wKaiser.^2) / (sum(wKaiser))^2;
fprintf('凯泽窗 (β=%g)：峰值修正系数 %.4f，等效噪声带宽 ENBW = %.4f\n', ...
    KAISER_BETA, winCorr, ENBW);


%% ==================== 逐母线组：序分量 → 阻抗 / 功率 ====================
nFreq = numel(FREQ_LIST);

% Excel 汇总累加器
SumBus = {}; SumBr = {}; SumFreq = []; SumBandLo = []; SumBandHi = [];
SumU1 = []; SumI1 = []; SumZ1m = []; SumZ1a = []; SumR1 = []; SumX1 = [];
SumP1 = []; SumQ1 = []; SumS1 = []; SumPF1 = [];
SumU2 = []; SumI2 = []; SumZ2m = []; SumZ2a = []; SumR2 = []; SumX2 = [];
SumP2 = []; SumQ2 = []; SumS2 = []; SumPF2 = [];

for g = 1:nGroup
    nb = numel(brName{g});
    fprintf('\n---- 母线组 %d/%d：%s（%d 条支路）----\n', g, nGroup, busName{g}, nb);

    % 母线电压三相
    Uabc = double(RawData(SELECTED_RANGE, posOf(busIdx{g})));

    % 各支路电流三相
    IabcCell = cell(1, nb);
    for b = 1:nb
        IabcCell{b} = double(RawData(SELECTED_RANGE, posOf(brIdx{g}{b})));
    end

    % ================================================================
    %  精细谱（凯泽窗）→ 频带积分 P/Q + 中心点阻抗 Z1/Z2
    %  （v2.1：不再输出按频率展开的阻抗曲线，故粗谱已整体移除）
    % ================================================================
    Z1_k = complex(nan(nFreq, nb));   Z2_k = complex(nan(nFreq, nb));
    P_k  = nan(nFreq, nb);            Q_k  = nan(nFreq, nb);
    S1_k = nan(nFreq, nb);            PF1_k = nan(nFreq, nb);
    P2_k = nan(nFreq, nb);            Q2_k  = nan(nFreq, nb);
    S2_k = nan(nFreq, nb);            PF2_k = nan(nFreq, nb);
    I1mag_k = nan(nFreq, nb);         I2mag_k = nan(nFreq, nb);
    U1mag_k = nan(nFreq, 1);          U2mag_k = nan(nFreq, 1);
    fGot    = nan(1, nFreq);          bandLo = nan(1, nFreq);   bandHi = nan(1, nFreq);

    for k = 1:nFreq
        f0 = FREQ_LIST(k);

        % ---- 精细频率网格：覆盖 [f0-FREQ_TOL-W, f0+FREQ_TOL+W] ----
        lo = f0 - FREQ_TOL - BAND_HALF_WIDTH;
        hi = f0 + FREQ_TOL + BAND_HALF_WIDTH;
        fine = (ceil(lo / FINE_FREQ_STEP) : floor(hi / FINE_FREQ_STEP)) * FINE_FREQ_STEP;
        fine = fine(:);
        nF   = numel(fine);

        % ---- 母线与各支路在精细频率上的正 / 负序复幅值 ----
        [Up1_f, Up2_f] = f_seq_fine(Uabc, fine, FS, wKaiser, winCorr);
        Ip1_f = complex(zeros(nF, nb));   Ip2_f = complex(zeros(nF, nb));
        for b = 1:nb
            [Ip1_f(:, b), Ip2_f(:, b)] = f_seq_fine(IabcCell{b}, fine, FS, wKaiser, winCorr);
        end

        % ---- 频带中心：手动 or 自动寻峰 ----
        if USE_AUTO_PEAK
            idxSearch = (fine >= f0 - FREQ_TOL) & (fine <= f0 + FREQ_TOL);
            if any(idxSearch)
                Ienv = max(abs(Ip1_f), [], 2);        % 各支路正序电流幅值的包络
                Ienv(~idxSearch) = -Inf;
                [~, iMax] = max(Ienv);
                fCenter = fine(iMax);
                fprintf('  自动寻峰 [%.2f Hz] → 频带中心 %.3f Hz\n', f0, fCenter);
            else
                warning('频率 %.2f Hz 的寻峰范围无效，使用参考频率。', f0);
                fCenter = f0;
            end
        else
            fCenter = f0;
        end
        fGot(k) = fCenter;

        % ---- 频带范围 ----
        bandLo(k) = fCenter - BAND_HALF_WIDTH;
        bandHi(k) = fCenter + BAND_HALF_WIDTH;
        idxBand   = (fine >= bandLo(k)) & (fine <= bandHi(k));
        if ~any(idxBand)
            warning('频率 %.3f Hz 的积分频带内没有精细谱点，请检查 FINE_FREQ_STEP / BAND_HALF_WIDTH。', fCenter);
        end

        % ---- 频带积分 P、Q（正序、负序**都**积分；除以 ENBW 校正）----
        S1_fine = 1.5 * (Up1_f .* conj(Ip1_f));        % nF × nb（隐式扩展）
        S2_fine = 1.5 * (Up2_f .* conj(Ip2_f));        % nF × nb
        if any(idxBand)
            P_k(k, :)  = sum(real(S1_fine(idxBand, :)), 1) / ENBW;
            Q_k(k, :)  = sum(imag(S1_fine(idxBand, :)), 1) / ENBW;
            P2_k(k, :) = sum(real(S2_fine(idxBand, :)), 1) / ENBW;
            Q2_k(k, :) = sum(imag(S2_fine(idxBand, :)), 1) / ENBW;
        end

        % ---- 中心点单点阻抗（正序 Z1 / 负序 Z2）----
        [Up1_c, Up2_c] = f_seq_fine(Uabc, fCenter, FS, wKaiser, winCorr);
        U1mag_k(k) = abs(Up1_c);
        U2mag_k(k) = abs(Up2_c);
        for b = 1:nb
            [Ip1_c, Ip2_c] = f_seq_fine(IabcCell{b}, fCenter, FS, wKaiser, winCorr);
            I1mag_k(k, b) = abs(Ip1_c);
            I2mag_k(k, b) = abs(Ip2_c);
            if abs(Ip1_c) >= Z_MIN_CURRENT
                Z1_k(k, b) = Up1_c / Ip1_c;
            end
            if abs(Ip2_c) >= Z_MIN_CURRENT
                Z2_k(k, b) = Up2_c / Ip2_c;
            end
        end

        % ---- 视在功率 / 功率因数：由积分后的 P、Q 反算，保证与 P、Q 口径一致 ----
        S1_k(k, :)  = hypot(P_k(k, :),  Q_k(k, :));
        PF1_k(k, :) = P_k(k, :)  ./ max(S1_k(k, :),  eps);
        S2_k(k, :)  = hypot(P2_k(k, :), Q2_k(k, :));
        PF2_k(k, :) = P2_k(k, :) ./ max(S2_k(k, :),  eps);
    end

    % ---- 逐支路打印 ----
    for b = 1:nb
        fprintf('  [%s]\n', brName{g}{b});
        for k = 1:nFreq
            fprintf(['    %8.3f Hz (band %.2f~%.2f) | U1 %9.4f  I1 %9.4f | ' ...
                     'Z1 %9.4f Ω ∠%8.2f° | U2 %9.4f  I2 %9.4f | Z2 %9.4f Ω ∠%8.2f° | ' ...
                     'P1 %9.4f  Q1 %9.4f (MVA)\n'], ...
                fGot(k), bandLo(k), bandHi(k), U1mag_k(k), I1mag_k(k, b), ...
                abs(Z1_k(k, b)), angle(Z1_k(k, b))*180/pi, ...
                U2mag_k(k), I2mag_k(k, b), abs(Z2_k(k, b)), angle(Z2_k(k, b))*180/pi, ...
                P_k(k, b), Q_k(k, b));
        end
    end

    % ---- 汇总到 Excel 数据 ----
    for b = 1:nb
        for k = 1:nFreq
            SumBus{end+1}    = busName{g};                %#ok<SAGROW>
            SumBr{end+1}     = brName{g}{b};              %#ok<SAGROW>
            SumFreq(end+1)   = fGot(k);                   %#ok<SAGROW>
            SumBandLo(end+1) = bandLo(k);                 %#ok<SAGROW>
            SumBandHi(end+1) = bandHi(k);                 %#ok<SAGROW>
            SumU1(end+1)     = U1mag_k(k);                %#ok<SAGROW>
            SumI1(end+1)     = I1mag_k(k, b);             %#ok<SAGROW>
            SumZ1m(end+1)    = abs(Z1_k(k, b));           %#ok<SAGROW>
            SumZ1a(end+1)    = angle(Z1_k(k, b))*180/pi;  %#ok<SAGROW>
            SumR1(end+1)     = real(Z1_k(k, b));          %#ok<SAGROW>
            SumX1(end+1)     = imag(Z1_k(k, b));          %#ok<SAGROW>
            SumP1(end+1)     = P_k(k, b);                 %#ok<SAGROW>
            SumQ1(end+1)     = Q_k(k, b);                 %#ok<SAGROW>
            SumS1(end+1)     = abs(S1_k(k, b));           %#ok<SAGROW>
            SumPF1(end+1)    = PF1_k(k, b);               %#ok<SAGROW>
            SumU2(end+1)     = U2mag_k(k);                %#ok<SAGROW>
            SumI2(end+1)     = I2mag_k(k, b);             %#ok<SAGROW>
            SumZ2m(end+1)    = abs(Z2_k(k, b));           %#ok<SAGROW>
            SumZ2a(end+1)    = angle(Z2_k(k, b))*180/pi;  %#ok<SAGROW>
            SumR2(end+1)     = real(Z2_k(k, b));          %#ok<SAGROW>
            SumX2(end+1)     = imag(Z2_k(k, b));          %#ok<SAGROW>
            SumP2(end+1)     = P2_k(k, b);                %#ok<SAGROW>
            SumQ2(end+1)     = Q2_k(k, b);                %#ok<SAGROW>
            SumS2(end+1)     = abs(S2_k(k, b));           %#ok<SAGROW>
            SumPF2(end+1)    = PF2_k(k, b);               %#ok<SAGROW>
        end
    end

    % ================================================================
    %  图 1：极坐标阻抗图 —— 每个分析频率一组
    %       (a) 正序 + 负序 合画
    %       (b) 正序单独（可选）
    %       (c) 负序单独（可选）
    %  注：阻抗取频带中心 f_c 处的**单点**复相量，不做频带积分，
    %      故标题中不出现「频带 / 积分」字样。
    % ================================================================
    cmap = f_get_cmap(nb, COLOR_SCHEME);
    % 颜色相近的支路改用不同线型（实线/虚线），单靠颜色分不清时靠线型兜底
    lstyle = f_assign_linestyles(cmap, POLAR_CLOSE_COLOR_DE);
    for k = 1:nFreq
        fstr = strrep(num2str(fGot(k)), '.', 'p');

        % 径向上限（先算数据，画完后再设 RLim，否则会被自动缩放覆盖）
        rmax1 = f_pick_rmax(abs(Z1_k(k, :)), POLAR_RMAX, 1);
        rmax2 = f_pick_rmax(abs(Z2_k(k, :)), POLAR_RMAX, 2);

        % ---- (a) 正序 + 负序 合画 ----
        f_draw_polar({Z1_k(k, :), Z2_k(k, :)}, {'Z1(正序)', 'Z2(负序)'}, ...
            [rmax1, rmax2], brName{g}, cmap, lstyle, ...
            sprintf('%.2fHz 各支路正序/负序谐波阻抗（以 %s 序电压为基准）', fGot(k), busName{g}), ...
            FIG_POS, POLAR_FIG_SIZE, POLAR_NTICK, FONT_SIZE, LINEWIDTH);
        f_savefig(OutDir, f_safe_filename(sprintf('%02d_阻抗极坐标_%s_%sHz', g, busName{g}, fstr)), ...
            FigSaveFormat, FigSaveResolution);
        close(gcf)

        if POLAR_SPLIT_SEQ_FIG
            % ---- (b) 正序单独 ----
            f_draw_polar({Z1_k(k, :)}, {'Z1(正序)'}, rmax1, brName{g}, cmap, lstyle, ...
                sprintf('%.2fHz 各支路正序谐波阻抗（以 %s 序电压为基准）', fGot(k), busName{g}), ...
                FIG_POS, POLAR_FIG_SIZE_1, POLAR_NTICK, FONT_SIZE, LINEWIDTH);
            f_savefig(OutDir, f_safe_filename(sprintf('%02d_阻抗极坐标_正序_%s_%sHz', g, busName{g}, fstr)), ...
                FigSaveFormat, FigSaveResolution);
            close(gcf)

            % ---- (c) 负序单独 ----
            f_draw_polar({Z2_k(k, :)}, {'Z2(负序)'}, rmax2, brName{g}, cmap, lstyle, ...
                sprintf('%.2fHz 各支路负序谐波阻抗（以 %s 序电压为基准）', fGot(k), busName{g}), ...
                FIG_POS, POLAR_FIG_SIZE_1, POLAR_NTICK, FONT_SIZE, LINEWIDTH);
            f_savefig(OutDir, f_safe_filename(sprintf('%02d_阻抗极坐标_负序_%s_%sHz', g, busName{g}, fstr)), ...
                FigSaveFormat, FigSaveResolution);
            close(gcf)
        end
    end

    % ================================================================
    %  图 2：功率柱状图（每频点一张子图，P、Q 都取频带积分值）
    % ================================================================
    nCol = min(2, nFreq);
    nRow = ceil(nFreq / nCol);
    figure('Name', sprintf('%s — 功率 %s', CSV_BASE, busName{g}));
    for k = 1:nFreq
        subplot(nRow, nCol, k)
        bar([P_k(k, :).', Q_k(k, :).'])          % nb × 2
        grid on
        set(gca, 'XTickLabel', brName{g})
        xtickangle(30)
        ylabel('功率 (MVA)')
        title(sprintf('%.3f Hz  [%.2f, %.2f] Hz 积分', fGot(k), bandLo(k), bandHi(k)))
        if k == 1
            legend({'P (有功)', 'Q (无功)'}, 'Location', 'best')
        end
        f_set_fontface(gca, 'TimesNewRomanSimsun')
        set(gca, 'fontsize', FONT_SIZE)
    end
    sgtitle(sprintf('%s — %s 谐波功率（正序口径频带积分，%s·%s）', CSV_BASE, busName{g}, uU, uI), ...
        'Interpreter', 'none')
    f_set_fig_size(gcf, FIG_POS, FIG_SIZE)
    f_savefig(OutDir, f_safe_filename(sprintf('%02d_功率_%s', g, busName{g})), ...
        FigSaveFormat, FigSaveResolution);
    close(gcf)
end


%% ==================== Excel 汇总 ====================
if SAVE_XLSX
    varNames = {'母线测点', '支路测点', '频率(Hz)', '频带下限(Hz)', '频带上限(Hz)', ...
                sprintf('U1正序幅值(%s)', uU), sprintf('I1正序幅值(%s)', uI), ...
                'Z1幅值(Ω)', 'Z1相角(deg)', 'R1(Ω)', 'X1(Ω)', ...
                'P1(MW)', 'Q1(MVAr)', 'S1(MVA)', 'PF1', ...
                sprintf('U2负序幅值(%s)', uU), sprintf('I2负序幅值(%s)', uI), ...
                'Z2幅值(Ω)', 'Z2相角(deg)', 'R2(Ω)', 'X2(Ω)', ...
                'P2(MW)', 'Q2(MVAr)', 'S2(MVA)', 'PF2'};
    SumData = [SumBus(:), SumBr(:), num2cell(SumFreq(:)), ...
               num2cell(SumBandLo(:)), num2cell(SumBandHi(:)), ...
               num2cell(SumU1(:)), num2cell(SumI1(:)), ...
               num2cell(SumZ1m(:)), num2cell(SumZ1a(:)), ...
               num2cell(SumR1(:)), num2cell(SumX1(:)), ...
               num2cell(SumP1(:)), num2cell(SumQ1(:)), ...
               num2cell(SumS1(:)), num2cell(SumPF1(:)), ...
               num2cell(SumU2(:)), num2cell(SumI2(:)), ...
               num2cell(SumZ2m(:)), num2cell(SumZ2a(:)), ...
               num2cell(SumR2(:)), num2cell(SumX2(:)), ...
               num2cell(SumP2(:)), num2cell(SumQ2(:)), ...
               num2cell(SumS2(:)), num2cell(SumPF2(:))];

    SumTable = cell2table(SumData, 'VariableNames', varNames);
    xlsxPath = fullfile(OutDir, XLSX_NAME);
    writetable(SumTable, xlsxPath);
    fprintf('\nExcel 汇总已保存：%s\n', xlsxPath);
    disp(SumTable)
end

fprintf('\n===== 全部完成：%d 个母线组，结果保存在：%s =====\n', nGroup, OutDir);


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

% ------------------------------------------------------------------
%  精细谱（凯泽窗逐频点 DFT）
% ------------------------------------------------------------------
function [F1, F2] = f_seq_fine(sig3, freqs, fs, w, winCorr)
    % 三相信号在给定频率集合上的**正序 / 负序**复幅值（峰值）
    %   sig3   : N×3（列序 A,B,C）
    %   freqs  : 频率向量 (Hz)，可以是标量
    %   w      : N×1 凯泽窗
    %   winCorr: 峰值恢复系数 2/sum(w)
    % 返回 F1、F2：nF×1 的**列**向量（便于与 nF×nb 的支路矩阵做隐式扩展）
    Xa = f_dft_win(sig3(:, 1), freqs, fs, w, winCorr);
    Xb = f_dft_win(sig3(:, 2), freqs, fs, w, winCorr);
    Xc = f_dft_win(sig3(:, 3), freqs, fs, w, winCorr);
    a  = exp(1j * 2 * pi / 3);
    F1 = ((Xa + a   * Xb + a^2 * Xc) / 3).';   % 正序（转成列）
    F2 = ((Xa + a^2 * Xb + a   * Xc) / 3).';   % 负序（转成列）
end

function Xc = f_dft_win(sig, freqs, fs, w, winCorr)
    % 加窗后在任意频率处的复幅值：X(f) = winCorr · Σ x[n]·w[n]·exp(-j2πf n/fs)
    sig = double(sig(:));
    N   = numel(sig);
    n   = (0:N-1)';
    sw  = sig .* w;                                        % N×1
    E   = exp(-1j * (2*pi / double(fs)) * (n * freqs(:).'));  % N×nF
    Xc  = (sw.' * E) * winCorr;                            % 1×nF
end

% ------------------------------------------------------------------
%  极坐标绘图辅助
% ------------------------------------------------------------------
function f_draw_polar(panelZ, panelName, panelRmax, brNames, cmap, lstyle, suptitleStr, ...
    figPos, figSize, nTick, fontSize, lw)
    % 画一张（或并排两张）极坐标阻抗图，并统一加共享图例
    %   panelZ    : cell，每个面板一个 1×nb 复阻抗向量（NaN 表示该支路无效）
    %   panelName : cellstr，每个面板标题前缀，如 'Z1(正序)'
    %   panelRmax : 每个面板的径向上限
    %   lstyle    : cellstr，每条支路的线型（颜色相近者用不同线型区分）
    %   suptitleStr : 图的总标题
    nP = numel(panelZ);
    nb = numel(brNames);

    figure('Name', suptitleStr, 'NumberTitle', 'off')
    if nP == 1
        % 单面板：在（较窄的）画幅里居中放一个尽量大的正方形面板，
        %   使其物理尺寸与「双面板合画」时的单个面板相当，避免左右留大片空白。
        panelBot = 0.130;
        panelTop = 0.865;                      % 顶端 ≤0.87，避免 polaraxes 标题与 sgtitle 重叠
        hN  = panelTop - panelBot;             % 面板归一化高度
        wN  = min(0.90, (hN * figSize(2)) / figSize(1));   % 尽量取正方形
        posList = [(1 - wN)/2, panelBot, wN, hN];
    else
        posList = [0.055, 0.165, 0.395, 0.700; 0.550, 0.165, 0.395, 0.700];
    end

    paxAll = gobjects(1, nP);
    hLeg   = gobjects(1, nb);
    for p = 1:nP
        paxAll(p) = polaraxes('Position', posList(p, :));
        for b = 1:nb
            h = f_polar_branch(paxAll(p), panelZ{p}(b), cmap(b, :), lstyle{b}, lw);
            if p == 1
                hLeg(b) = h;
            end
        end
        f_style_polar(paxAll(p), panelRmax(p), nTick, fontSize);
        title(paxAll(p), sprintf('%s  |Z|\\in[0,%g]\\Omega', panelName{p}, panelRmax(p)))
    end

    lgd = legend(paxAll(1), hLeg, brNames, 'Orientation', 'horizontal', ...
        'NumColumns', min(nb, 5));
    lgd.Location = 'none';
    lgd.Position = [0.02, 0.005, 0.96, 0.090];
    lgd.Interpreter = 'none';
    lgd.FontSize = 9;

    sgtitle(suptitleStr, 'Interpreter', 'none')
    f_set_fig_size(gcf, figPos, figSize)
end

function h = f_polar_branch(pax, Zval, col, ls, lw)
    % 在极坐标轴 pax 上画一条「从原点到 Zval」的射线（角度 = ∠Z，长度 = |Z|）
    % Zval 非有限（电流过小）时不画线，但仍返回一个有效句柄供图例使用
    if ~isfinite(Zval) || Zval == 0
        th = NaN;  rr = NaN;
    else
        th = angle(Zval);          % 弧度
        rr = abs(Zval);
    end
    hold(pax, 'on')
    h = polarplot(pax, [th, th], [0, rr], 'LineStyle', ls, 'Color', col, 'LineWidth', lw);
    polarplot(pax, th, rr, 'o', 'Color', col, 'MarkerFaceColor', col, 'MarkerSize', 5)
end

function f_style_polar(pax, rmax, nTick, fontSize)
    % 统一极坐标轴样式：0° 在右、逆时针、角度用度显示、径向刻度整齐
    pax.ThetaAxisUnits    = 'degrees';
    pax.ThetaZeroLocation = 'right';
    pax.ThetaDir          = 'counterclockwise';
    pax.ThetaTick         = 0:45:315;
    pax.ThetaTickLabel    = compose('%d°', 0:45:315);

    rTick = linspace(0, rmax, nTick + 1);
    pax.RTick = rTick;
    lab = arrayfun(@(v) f_fmt_tick(v), rTick, 'UniformOutput', false);
    lab{1} = '';                       % 圆心 0 不标注
    pax.RTickLabel = lab;
    pax.RLim = [0, rmax];              % ★必须在画完数据之后再设
    pax.FontName = 'TimesNewRomanSimsun';
    pax.FontSize = fontSize;
    grid(pax, 'on')
end

function s = f_fmt_tick(v)
    if abs(v - round(v)) < 1e-9
        s = sprintf('%g', round(v));
    else
        s = sprintf('%g', v);
    end
end

function rmax = f_pick_rmax(zmag, userRmax, whichSeq)
    % 选径向上限：用户指定优先；否则按数据最大值向上取整到「整齐」的数
    zmag = zmag(isfinite(zmag));
    if ~isempty(userRmax)
        if isscalar(userRmax)
            rmax = userRmax;
        elseif numel(userRmax) >= whichSeq
            rmax = userRmax(whichSeq);
        else
            rmax = userRmax(1);
        end
        return
    end
    if isempty(zmag)
        rmax = 1;
        return
    end
    m = max(zmag);
    if m <= 0
        rmax = 1;
        return
    end
    rmax = ceil(m * 1.05 / 5) * 5;     % 留 5% 余量，向上取整到 5 的倍数
    if rmax <= 0
        rmax = 5;
    end
end

% ------------------------------------------------------------------
%  支路配色
% ------------------------------------------------------------------
function cmap = f_get_cmap(n, scheme)
    % 按方案返回 n 个颜色
    if nargin < 2 || isempty(scheme)
        scheme = 'distinct';
    end
    switch lower(scheme)
        case 'lines'
            cmap = lines(n);
        otherwise
            cmap = f_distinct_colors(n);
    end
end

function styles = f_assign_linestyles(cmap, deThresh)
    % 为「颜色过于接近」的支路分配**不同线型**，使颜色相近者仍能区分。
    %
    % 做法：把 ΔE00(CIEDE2000) < deThresh 的两条支路连一条边（视为"看起来同色"），
    %       在得到的图上做贪心着色，颜色 = 线型（实线/虚线/点线/点划线）。
    %       这样任意一对"同色"支路必定拿到不同线型；
    %       颜色本来就分得开的支路则保持实线，图面不会太花。
    %   注：改用 CIEDE2000（而非 CIE76）以与配色算法口径一致 —— 实测两者对
    %       "哪对最接近"的判断差别很大（CIE76 认为 314-317 最近，CIEDE2000 认为 312-H5 最近）。
    %
    %   cmap     : n×3 RGB
    %   deThresh : CIEDE2000 色差阈值；<= 0 或空 → 全部返回实线（关闭该功能）
    % 返回 1×n cellstr
    n = size(cmap, 1);
    styles = repmat({'-'}, 1, n);
    if nargin < 2 || isempty(deThresh) || deThresh <= 0 || n < 2
        return
    end

    % ---- 1. 构造"同色"邻接图（CIEDE2000 感知色差）----
    lab = f_rgb2lab(cmap);
    adj = false(n, n);
    for i = 1:n
        for j = i + 1:n
            if f_de2000(lab(i, :), lab(j, :)) < deThresh
                adj(i, j) = true;
                adj(j, i) = true;
            end
        end
    end

    % ---- 2. 贪心着色：线型按"最容易区分"到"次之"取用 ----
    %   实线 ↔ 虚线 差异最大，优先；不够时再上点线、点划线。
    styleBank = {'-', '--', ':', '-.'};
    for i = 1:n
        used = styles(1:i - 1);
        used = used(adj(i, 1:i - 1));      % 已与 i "同色"的支路所用线型
        for s = 1:numel(styleBank)
            if ~any(strcmp(styleBank{s}, used))
                styles{i} = styleBank{s};
                break
            end
        end
    end
end

function cmap = f_distinct_colors(n)
    % 生成 n 个互相容易区分的颜色（白底 + 细射线场景）
    %
    % 为什么要自建：MATLAB 自带的 lines(n) 在 n > 7 时会**循环重复**颜色 ——
    %   lines(9) 的第 8、9 个颜色与第 1、2 个完全相同（实测确认），
    %   支路一多就分不清谁是谁。
    %
    % 【v2.4 重写】旧的「色相分箱 + 最鲜艳 + CIE76 贪心」实测最小感知色差
    %   (CIEDE2000) 只有 ~15.5，和 Tableau10(16.2)、Okabe-Ito(21.7) 一个水平，
    %   细线下仍然会看混。现改为：
    %     1. 在 RGB 网格上取候选色，只保留鲜艳、中等明度的（白底对比好）；
    %        【v2.5】明度上限由 80 收紧到 72：上限 80 会挑出发白的浅紫
    %        (#BFBFFF, C*≈34)，白底细线几乎看不清。
    %     2. 用 **CIEDE2000 感知色差** 做「最远点采样」(farthest-point sampling)：
    %        先取离候选集质心最远的，再每次取"离已选集合最远"的那个；
    %     3. 再做若干轮**局部交换**改进（用未选色替换某个已选色，
    %        只要能把"最小两两间距"抬高就接受），逼近局部最优。
    %   实测（n=9）：最小 CIEDE2000 色差 ~15.5 → ~36（越大越好区分）。
    if n <= 0
        cmap = zeros(0, 3);
        return
    end

    % ---- 1. 候选色 ----
    g = linspace(0, 1, 13);
    [R, G, B] = ndgrid(g, g, g);
    cand = [R(:), G(:), B(:)];
    lab  = f_rgb2lab(cand);
    L = lab(:, 1);
    C = hypot(lab(:, 2), lab(:, 3));
    keep = L >= 28 & L <= 72 & C >= 30;      % 去掉过暗/过亮/发灰的
    cand = cand(keep, :);
    lab  = lab(keep, :);
    nC   = size(cand, 1);
    if nC < n                                % 候选不足（几乎不会发生）
        cmap = lines(n);
        return
    end

    % ---- 2. CIEDE2000 距离矩阵（逐行计算，控制内存峰值）----
    D = zeros(nC, nC);
    for i = 1:nC
        D(i, :) = f_de2000(lab(i, :), lab);
    end
    D(1:nC + 1:end) = Inf;

    % ---- 3. 最远点采样 + 局部交换改进（多起点取最优，种子固定 → 结果可复现）----
    c0 = mean(lab, 1);
    [~, i0] = max(sum((lab - c0).^2, 2));          % 主种子：离质心最远的那个
    seeds = unique([i0, 1:max(1, floor(nC / 8)):nC]);
    bestSel = [];  bestV = -Inf;
    for s = 1:numel(seeds)
        sel  = seeds(s);
        dmin = D(sel, :).';
        dmin(sel) = -Inf;
        for k = 2:n
            [~, ik] = max(dmin);
            sel(end + 1) = ik;                     %#ok<AGROW>
            dmin = min(dmin, D(ik, :).');
            dmin(sel) = -Inf;
        end
        sel = f_local_improve(D, sel);
        v = f_minsep(D, sel);
        if v > bestV
            bestV = v;  bestSel = sel;
        end
    end

    cmap = cand(bestSel, :);

    % 兜底：极端情况下候选不够 n 个，循环补齐（正常支路数不会走到这里）
    if size(cmap, 1) < n
        cmap = cmap(mod(0:n - 1, size(cmap, 1)) + 1, :);
    end
end

function sel = f_local_improve(D, sel)
    % 局部交换：反复尝试用未选色替换某个已选色，
    %   只要能把「已选集合内最小两两距离」**严格抬高**就接受，直到无法改进。
    %   注意：候选"离 others 很远"只是必要条件 —— 必须替换后整体最小距离
    %   真的变大才接受，否则会原地打转（死循环）。故替换后要回退检查。
    n = numel(sel);
    v = f_minsep(D, sel);
    for iter = 1:200                          % 迭代上限，双保险
        improved = false;
        for p = 1:n
            others = sel([1:p - 1, p + 1:n]);
            cs = min(D(:, others), [], 2);    % 每个候选到 others 的最近距离
            cs(sel) = -Inf;                   % 已选的不能再选
            [bestV, bestJ] = max(cs);
            if bestV <= v
                continue
            end
            old = sel(p);
            sel(p) = bestJ;
            nv = f_minsep(D, sel);            % ★必须真正抬高才接受
            if nv > v
                v = nv;
                improved = true;
                break
            end
            sel(p) = old;                     % 否则回退
        end
        if ~improved
            break
        end
    end
end

function v = f_minsep(D, sel)
    % 已选集合内的最小两两距离
    sub = D(sel, sel);
    sub(1:numel(sel) + 1:end) = Inf;
    v = min(sub(:));
end

function dE = f_de2000(lab1, lab2)
    % CIEDE2000 色差。lab1: 1×3（参考色），lab2: k×3，返回 1×k。
    % 逐行调用，避免一次性生成巨大的 N×N 中间量。
    L1 = lab1(1); a1 = lab1(2); b1 = lab1(3);
    L2 = lab2(:, 1).'; a2 = lab2(:, 2).'; b2 = lab2(:, 3).';

    C1 = hypot(a1, b1);
    C2 = hypot(a2, b2);
    Cbar = (C1 + C2) / 2;
    G  = 0.5 * (1 - sqrt(Cbar.^7 ./ (Cbar.^7 + 25^7)));
    a1p = (1 + G) * a1;
    a2p = (1 + G) .* a2;
    C1p = hypot(a1p, b1);
    C2p = hypot(a2p, b2);
    h1p = mod(atan2d(b1, a1p), 360);
    h2p = mod(atan2d(b2, a2p), 360);

    dLp = L2 - L1;
    dCp = C2p - C1p;
    dhp = h2p - h1p;
    dhp = dhp - 360 * (dhp > 180) + 360 * (dhp < -180);
    dhp(C1p .* C2p == 0) = 0;
    dHp = 2 * sqrt(C1p .* C2p) .* sind(dhp / 2);

    Lbp = (L1 + L2) / 2;
    Cbp = (C1p + C2p) / 2;
    hsum = h1p + h2p;
    habs = abs(h1p - h2p);
    nz   = (C1p .* C2p ~= 0);
    hbp  = hsum;                                          % C1p*C2p==0 时取 hsum
    hbp(nz & habs <= 180)               = hsum(nz & habs <= 180) / 2;
    hbp(nz & habs > 180 & hsum < 360)   = (hsum(nz & habs > 180 & hsum < 360) + 360) / 2;
    hbp(nz & habs > 180 & hsum >= 360)  = (hsum(nz & habs > 180 & hsum >= 360) - 360) / 2;

    T = 1 - 0.17 * cosd(hbp - 30) + 0.24 * cosd(2 * hbp) ...
        + 0.32 * cosd(3 * hbp + 6) - 0.20 * cosd(4 * hbp - 63);
    dth = 30 * exp(-(((hbp - 275) / 25).^2));
    Rc  = 2 * sqrt(Cbp.^7 ./ (Cbp.^7 + 25^7));
    Sl  = 1 + (0.015 * (Lbp - 50).^2) ./ sqrt(20 + (Lbp - 50).^2);
    Sc  = 1 + 0.045 * Cbp;
    Sh  = 1 + 0.015 * Cbp .* T;
    Rt  = -sind(2 * dth) .* Rc;

    dE = sqrt((dLp ./ Sl).^2 + (dCp ./ Sc).^2 + (dHp ./ Sh).^2 ...
              + Rt .* (dCp ./ Sc) .* (dHp ./ Sh));
end

function lab = f_rgb2lab(rgb)
    % sRGB → CIELAB (D65)，输入 N×3 的 [0,1] RGB
    c = rgb;
    lin = zeros(size(c));
    m = c > 0.04045;
    lin(m)  = ((c(m) + 0.055) / 1.055) .^ 2.4;
    lin(~m) = c(~m) / 12.92;

    M = [0.4124564 0.3575761 0.1804375;
         0.2126729 0.7151522 0.0721750;
         0.0193339 0.1191920 0.9503041];
    xyz = lin * M.';

    wp = [0.95047, 1.00000, 1.08883];
    t  = xyz ./ wp;
    d  = 6 / 29;
    f  = zeros(size(t));
    m2 = t > d^3;
    f(m2)  = t(m2) .^ (1 / 3);
    f(~m2) = t(~m2) / (3 * d^2) + 4 / 29;

    lab = [116 * f(:, 2) - 16, 500 * (f(:, 1) - f(:, 2)), 200 * (f(:, 2) - f(:, 3))];
end

% ------------------------------------------------------------------
%  CSV 读取辅助（与原 da01c 一致）
% ------------------------------------------------------------------
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
