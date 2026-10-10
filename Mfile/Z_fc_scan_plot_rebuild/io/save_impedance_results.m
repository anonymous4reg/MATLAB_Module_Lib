function save_impedance_results(R, out_dir, band_name, do_figs)
%SAVE_IMPEDANCE_RESULTS 保存阻抗结果 .mat 与幅相图（全工程唯一绘图/保存处）。
%
%   R           run_low_band / run_high_band / merge_impedance_bands 的输出
%   out_dir     输出目录（自动创建）
%   band_name   'low' | 'high' | 'merged'
%   do_figs     是否保存 fig/png（默认 true）。-batch 无头模式渲染偶发死锁，
%               脚本场景可传 false（.mat 结果不受影响）。
%
% 命名约定（用户确认：MIMO/SISO 分开命名）：
%   'low'    -> DATA_ZPD_SISO.mat / DATA_ZND_SISO.mat
%               DATA_ZPD_MIMO.mat / DATA_ZND_MIMO.mat   + 各 1 张图
%   'high'   -> DATA_ZPD.mat / DATA_ZND.mat（仅 SISO）+ 图
%   'merged' -> DATA_ZPD.mat / DATA_ZND.mat（合并曲线）+ 图
% 文件格式均为三列：[f_hz, |Z|Ω, phase°]

if nargin < 4 || isempty(do_figs), do_figs = true; end
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

switch band_name
    case 'low'
        if isfield(R,'ZPD_SISO') && ~isempty(R.ZPD_SISO)
            save_one(R.ZPD_SISO, fullfile(out_dir,'DATA_ZPD_SISO'), 'Positive seq SISO', do_figs);
            save_one(R.ZND_SISO, fullfile(out_dir,'DATA_ZND_SISO'), 'Negative seq SISO', do_figs);
        end
        if isfield(R,'ZPD_MIMO') && ~isempty(R.ZPD_MIMO)
            save_one(R.ZPD_MIMO, fullfile(out_dir,'DATA_ZPD_MIMO'), 'Positive seq MIMO', do_figs);
            save_one(R.ZND_MIMO, fullfile(out_dir,'DATA_ZND_MIMO'), 'Negative seq MIMO', do_figs);
        end
    case {'high','merged'}
        save_one(R.ZPD, fullfile(out_dir,'DATA_ZPD'), 'Positive sequence', do_figs);
        save_one(R.ZND, fullfile(out_dir,'DATA_ZND'), 'Negative sequence', do_figs);
    otherwise
        error('save_impedance_results: 未知 band_name %s', band_name);
end
end

function save_one(Z, file_url, title_str, do_figs)
save([file_url '.mat'], 'Z');
if ~do_figs, return; end
% 图：painters 渲染器（绕开无头模式 OpenGL 死锁）；单图独立 try/catch，
% 失败仅警告不中断主流程（.mat 已保存）。
f = [];
try
    f = figure('Visible','off','Renderer','painters','Color','w');
    subplot(2,1,1);
    plot(Z(:,1), 20*log10(Z(:,2)), 'k'); grid on;
    title(title_str); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    subplot(2,1,2);
    plot(Z(:,1), Z(:,3), 'k'); grid on;
    xlabel('Frequency (Hz)'); ylabel('Phase (deg)');
    set(f,'unit','centimeters','innerposition',[5 5 33 19]);
    % FIX: 渲染用不可见窗口，但保存前必须设 Visible='on'——
    %      fig 文件会存储 Visible 属性，否则用户打开 fig 时窗口是隐藏的（弹不出来）。
    set(f,'Visible','on');
    savefig(f, [file_url '.fig']);
    print(f, file_url, '-dpng', '-r200');
catch err
    warning('save_impedance_results: 图形保存跳过 %s（%s）', file_url, err.message);
end
try, close(f); catch, end
end
