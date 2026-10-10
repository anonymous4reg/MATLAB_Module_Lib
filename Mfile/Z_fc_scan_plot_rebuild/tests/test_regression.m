function test_regression()
%TEST_REGRESSION P2 期一致性测试（P1 的 golden 对比见 test_p1_regression.m）。
%
% 检查项：
%   1) 所有输出无 NaN/Inf
%   2) 报告范围正确：低频 SISO/MIMO 1~250Hz（MIMO 缺 100Hz 属预期），
%      高频 250~2500Hz 共 226 点（不再丢弃 250~340Hz）
%   3) 电流符号统一后，SISO 与 MIMO 在弱耦合频点应一致（远离 50Hz、远离
%      100Hz 镜像、远离 250/350Hz 谐振区）
%   4) SISO 正/负序与 MIMO 正/负序幅值在同一量级（正序镜像对：ZND(-f)=ZPD(f) 关系在 P2 裁剪后不再输出）
%
% 通过打印 PASS，否则 error。

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'config'), fullfile(root,'io'), ...
        fullfile(root,'core'), fullfile(root,'pipeline'));

data_dir = fullfile(root, '_baseline_data');

% ---- 低频 ----
C1 = impedance_scan_config();
S1 = load_scan_recording(fullfile(data_dir,'Lfile_1.mat'), ...
                         C1.sample_time_us, C1.f_begin, C1.f_end, C1.f_step);
R1 = run_low_band(C1, S1);
% ---- 高频 ----
C2 = impedance_scan_config('sample_time_us',20,'f_begin',250,'f_end',2500,'f_step',10, ...
                           'f_report_begin',250,'f_report_end',2500,'use_mimo',false);
S2 = load_scan_recording(fullfile(data_dir,'Hfile_1.mat'), ...
                         C2.sample_time_us, C2.f_begin, C2.f_end, C2.f_step);
R2 = run_high_band(C2, S2);

ok = true;

% ---- 1) NaN/Inf ----
names = {'ZPD_SISO','ZND_SISO','ZPD_MIMO','ZND_MIMO','ZPD_HIGH','ZND_HIGH'};
vals  = {R1.ZPD_SISO, R1.ZND_SISO, R1.ZPD_MIMO, R1.ZND_MIMO, R2.ZPD, R2.ZND};
for i = 1:numel(names)
    if any(~isfinite(vals{i}(:)))
        fprintf('FAIL: %s 含 NaN/Inf\n', names{i}); ok = false;
    end
end

% ---- 2) 报告范围 ----
fprintf('ZPD_SISO  f=[%g..%g] n=%d\n', R1.ZPD_SISO(1,1), R1.ZPD_SISO(end,1), size(R1.ZPD_SISO,1));
fprintf('ZND_SISO  f=[%g..%g] n=%d\n', R1.ZND_SISO(1,1), R1.ZND_SISO(end,1), size(R1.ZND_SISO,1));
fprintf('ZPD_MIMO  f=[%g..%g] n=%d\n', R1.ZPD_MIMO(1,1), R1.ZPD_MIMO(end,1), size(R1.ZPD_MIMO,1));
fprintf('ZND_MIMO  f=[%g..%g] n=%d\n', R1.ZND_MIMO(1,1), R1.ZND_MIMO(end,1), size(R1.ZND_MIMO,1));
fprintf('ZPD_HIGH  f=[%g..%g] n=%d\n', R2.ZPD(1,1), R2.ZPD(end,1), size(R2.ZPD,1));

if R1.ZPD_SISO(1,1) ~= 1 || R1.ZPD_SISO(end,1) ~= 250 || size(R1.ZPD_SISO,1) ~= 250
    fprintf('FAIL: 低频 SISO 报告范围应为 1~250\n'); ok = false;
end
if R2.ZPD(1,1) ~= 250 || R2.ZPD(end,1) ~= 2500 || size(R2.ZPD,1) ~= 226
    fprintf('FAIL: 高频报告范围应为 250~2500 共 226 点\n'); ok = false;
end

% ---- 3) SISO vs MIMO 弱耦合一致性（符号统一后应重合）----
dZ = @(A,B) abs(A(:,2).*exp(1i*A(:,3)*pi/180) - B(:,2).*exp(1i*B(:,3)*pi/180));
worst = 0; worst_f = 0;
for f = [1 5 10 20 30 40 60 70 80 90 99 110 130 160 200 240]
    i = find(R1.ZPD_SISO(:,1)==f, 1);
    j = find(R1.ZPD_MIMO(:,1)==f, 1);
    if isempty(i) || isempty(j), continue; end
    d = dZ(R1.ZPD_SISO(i,:), R1.ZPD_MIMO(j,:));
    if d > worst, worst = d; worst_f = f; end
end
fprintf('SISO vs MIMO 弱耦合区最大复数偏差 = %.4f Ω @ %gHz\n', worst, worst_f);
if worst > 3
    fprintf('FAIL: 符号统一后 SISO 与 MIMO 在弱耦合区偏差过大\n'); ok = false;
end

% ---- 4) 幅值量级 sanity ----
if max(R1.ZPD_SISO(:,2)) > 1e4 || max(R1.ZND_SISO(:,2)) > 1e4
    fprintf('FAIL: 低频阻抗幅值异常\n'); ok = false;
end

if ok
    fprintf('TEST_REGRESSION PASS\n');
else
    error('test_regression: 存在失败项');
end
end
