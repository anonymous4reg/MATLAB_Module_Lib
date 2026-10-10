function S = load_scan_recording(mat_path, sample_time_us, f_begin, f_end, f_step)
%LOAD_SCAN_RECORDING 读取扫频录波 .mat 并建立"频点 -> 窗口"映射。
%
% 数据格式：
%   .mat 内为单一矩阵变量，行布局（1-based）：
%     行1 = 仿真时间（秒）
%     行2 = 50kHz 主时钟 tick（未使用）
%     行3-5 = UA/UB/UC；行6-8 = IA/IB/IC
%   每个注入频点连续录 1 秒：N = fs*1 个采样点，按频率升序拼接。
%
% 采样率：sample_time_us 为仿真步长(us)，采样率 = 1e6/sample_time_us。
%   传入 sample_time_us <= 0 时自动从行1（仿真时间）检测；传入正值时
%   自动核对，不一致会警告（防止切窗错位）。
%
% 返回结构 S：
%   S.fs_hz      采样率
%   S.N          每频点采样数（1 秒）
%   S.ua..S.ic   整段时域波形（1 x totalN）
%   S.seg_f_hz   k x 1 每段注入频率
%   S.seg_col0   k x 1 每段首列（1-based，与原代码 (ff-f_start)/step*NN+1 一致）

Data = load(mat_path);
D = cell2mat(struct2cell(Data));
assert(size(D,1) >= 8, 'load_scan_recording: %s 行数 < 8，格式不符（需要 [t;tick;UA;UB;UC;IA;IB;IC]）', mat_path);

% ---- 采样率：配置值 + 行1 自动检测核对 ----
fs_det = detect_fs_from_time(D);
if sample_time_us <= 0
    sample_time_us = 1e6 / fs_det;
    fprintf('load_scan_recording: %s 自动检测采样率 = %.0f Hz (%.0f us)\n', mat_path, fs_det, sample_time_us);
else
    fs_cfg = 1e6 / sample_time_us;
    if ~isnan(fs_det) && abs(fs_det - fs_cfg)/fs_cfg > 0.01
        warning('load_scan_recording: %s 配置采样率 %.0f Hz 与数据行1检测值 %.0f Hz 不符，切窗可能错位', ...
                mat_path, fs_cfg, fs_det);
    end
end
fs = 1e6 / sample_time_us;
N  = round(fs * 1);                % 1 秒窗口

f_list = f_begin : f_step : f_end; % 频点列表

S = struct();
S.fs_hz     = fs;
S.N         = N;
S.ua        = D(3,:); S.ub = D(4,:); S.uc = D(5,:);
S.ia        = D(6,:); S.ib = D(7,:); S.ic = D(8,:);
S.seg_f_hz  = f_list(:);
S.seg_col0  = ((f_list(:) - f_begin) / f_step) * N + 1;   % 1-based 首列

% ---- 列数合理性检查 ----
need   = max(S.seg_col0) + N - 1;
expect = numel(f_list) * N;
assert(size(D,2) >= need, ...
    'load_scan_recording: %s 数据列数 %d 不足（需要 >= %d，按 f=%g:%g:%g、采样率 %.0fHz 计算）', ...
    mat_path, size(D,2), need, f_begin, f_end, f_step, fs);
if size(D,2) > expect + N
    warning('load_scan_recording: %s 数据列数 %d 明显多于预期 %d（%d 频点 x %d 点/秒），请检查频点范围或采样率', ...
            mat_path, size(D,2), expect, numel(f_list), N);
end
end

function fs = detect_fs_from_time(D)
% 行1 为仿真时间(秒)：中位数差分 -> 采样周期。取前 200 点（首段内部，避开段间跳变）。
n = min(200, size(D,2));
if n < 3
    fs = NaN; return;
end
dt = median(diff(D(1, 1:n)));
if ~isfinite(dt) || dt <= 0
    fs = NaN; return;
end
fs = 1/dt;
end
