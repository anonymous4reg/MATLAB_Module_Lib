function run_all_cases(data_root, case_filter, save_figs)
%RUN_ALL_CASES 批量处理：数据根目录下所有工况文件夹的阻抗计算。
%
% 用法：
%   run_all_cases()                                     % 默认数据根目录
%   run_all_cases('/path/to/data')                      % 指定数据根目录
%   run_all_cases('/path/to/data', {'Q1.0'})            % 只处理指定工况（按文件夹名）
%   run_all_cases(..., true/false)                      % 是否保存 fig/png 图（默认 true）
%
% 说明：图形保存（fig/png）在 MATLAB -batch 无头模式下偶发渲染死锁，
%   批量/脚本场景建议 save_figs=false（.mat 结果不受影响），
%   交互式 MATLAB 中可开 true。
%
% 数据布局：data_root 下每个子文件夹为一个工况，内含 Lfile*.mat（低频 10kHz）与
% Hfile*.mat（高频 50kHz），文件名后缀不限（由 find_scan_cases 自动发现配对）。
%
% 每个工况输出到其文件夹下三个子目录（用户确认的布局）：
%   <工况>/1-250Hz/    低频结果（DATA_ZPD_SISO/MIMO.mat、DATA_ZND_SISO/MIMO.mat + 图）
%   <工况>/250-2500Hz/ 高频结果（DATA_ZPD.mat、DATA_ZND.mat + 图）
%   <工况>/1-2500Hz/   合并结果（低频 MIMO 1~249Hz + 高频 250~2500Hz，
%                        50/100Hz 退化洞位用 SISO 填充）（DATA_ZPD.mat、DATA_ZND.mat + 图）
%
% 频段/采样率默认：低频注入 1~349Hz @1Hz、报告 1~250Hz、10kHz(100us)；
% 高频注入/报告 250~2500Hz @10Hz、50kHz(20us)。如需调整见 cfg 定义处。

if nargin < 1 || isempty(data_root)
    data_root = '/Users/ym/Downloads/siyuan_svg_56Mvar';
end
if nargin < 2, case_filter = {}; end
if nargin < 3 || isempty(save_figs), save_figs = true; end

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'config'), fullfile(root,'io'), ...
        fullfile(root,'core'), fullfile(root,'pipeline'));

% ---- 频段配置（按需修改）----
cfg.low  = impedance_scan_config();                 % 默认 100us/1..349Hz/报告1..250Hz
cfg.high = impedance_scan_config('sample_time_us',20,'f_begin',250,'f_end',2500, ...
                                 'f_step',10,'f_report_begin',250,'f_report_end',2500, ...
                                 'use_mimo',false);

% ---- 发现工况 ----
cases = find_scan_cases(data_root);
if ~isempty(case_filter)
    keep = false(size(cases));
    for i = 1:numel(cases)
        nm = folder_name(cases(i).folder);
        keep(i) = any(strcmp(nm, case_filter));
    end
    cases = cases(keep);
    fprintf('run_all_cases: 按过滤器保留 %d 组\n', numel(cases));
end
if isempty(cases)
    warning('run_all_cases: 没有找到任何工况数据（%s 下需含 Lfile*.mat 与 Hfile*.mat 的子文件夹）', data_root);
    return;
end

% ---- 逐工况处理 ----
for i = 1:numel(cases)
    case_name = folder_name(cases(i).folder);
    fprintf('\n==== 工况 %d/%d: %s ====\n', i, numel(cases), case_name);
    process_one_case(cases(i), cfg, save_figs);
end
fprintf('\nRUN_ALL_CASES DONE（%d 组工况）\n', numel(cases));
end

function nm = folder_name(folder)
% 取路径最后一段（不剥扩展名：Q1.0 应保持完整）
seg = strsplit(folder, filesep);
nm = seg{end};
end

function process_one_case(ci, cfg, save_figs)
% 低频
fprintf('  低频: %s\n', ci.lfile);
S1 = load_scan_recording(ci.lfile, cfg.low.sample_time_us, cfg.low.f_begin, cfg.low.f_end, cfg.low.f_step);
R1 = run_low_band(cfg.low, S1);
save_impedance_results(R1, fullfile(ci.folder,'1-250Hz'), 'low', save_figs);
fprintf('  低频完成: SISO %dx%d, MIMO %dx%d -> 1-250Hz/\n', ...
        size(R1.ZPD_SISO,1), size(R1.ZPD_SISO,2), size(R1.ZPD_MIMO,1), size(R1.ZPD_MIMO,2));

% 高频
fprintf('  高频: %s\n', ci.hfile);
S2 = load_scan_recording(ci.hfile, cfg.high.sample_time_us, cfg.high.f_begin, cfg.high.f_end, cfg.high.f_step);
R2 = run_high_band(cfg.high, S2);
save_impedance_results(R2, fullfile(ci.folder,'250-2500Hz'), 'high', save_figs);
fprintf('  高频完成: %dx%d -> 250-2500Hz/\n', size(R2.ZPD,1), size(R2.ZPD,2));

% 合并 1~2500Hz
M = merge_impedance_bands(R1, R2);
save_impedance_results(M, fullfile(ci.folder,'1-2500Hz'), 'merged', save_figs);
fprintf('  合并完成: ZPD %dx%d (f=%g..%g), ZND %dx%d -> 1-2500Hz/\n', ...
        size(M.ZPD,1), size(M.ZPD,2), M.ZPD(1,1), M.ZPD(end,1), ...
        size(M.ZND,1), size(M.ZND,2));
end
