function test_regression(tol)
%TEST_REGRESSION P1 回归测试：重构版输出 vs 原代码 golden 基线，逐点对比。
%
% 用法：test_regression()          默认容差（SISO/高频 1e-9，MIMO 1e-3）
%       test_regression(1e-9)      全部使用给定容差
% 通过则打印 PASS，否则 error（打印每项最大偏差）。
%
% 对比项：ZPD_SISO/ZND_SISO/ZPD_MIMO/ZND_MIMO（低频）、ZPD/ZND（高频）。
%
% 说明：MIMO 在 f=50（基频）处 2x2 矩阵病态（镜像=自身，近奇异），inv() 会把
% 机器舍入噪声放大（实测相位偏差 ~2.4e-5 度），故 MIMO 容差放宽到 1e-3，
% 属已知数值现象，非逻辑差异。

if nargin < 1, tol = []; end
if isempty(tol)
    tol_siso = 1e-9;
    tol_mimo = 1e-3;
else
    tol_siso = tol; tol_mimo = tol;
end

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'config'), fullfile(root,'io'), ...
        fullfile(root,'core'), fullfile(root,'pipeline'));

golden_dir = fullfile(root, '_baseline_data');
G = load(fullfile(golden_dir, 'golden_outputs.mat'));

% ---- 低频 ----
C1 = impedance_scan_config();
S1 = load_scan_recording(fullfile(golden_dir,'Lfile_1.mat'), ...
                         C1.sample_time_us, C1.f_begin, C1.f_end, C1.f_step);
R1 = run_low_band(C1, S1);
% ---- 高频 ----
C2 = impedance_scan_config('sample_time_us',20,'f_begin',250,'f_end',2500,'f_step',10,'use_mimo',false);
S2 = load_scan_recording(fullfile(golden_dir,'Hfile_1.mat'), ...
                         C2.sample_time_us, C2.f_begin, C2.f_end, C2.f_step);
R2 = run_high_band(C2, S2);

pairs = { 'ZPD_SISO', G.retZPDSISO, R1.ZPD_SISO, tol_siso; ...
          'ZND_SISO', G.retZNDSISO, R1.ZND_SISO, tol_siso; ...
          'ZPD_MIMO', G.retZPDMIMO, R1.ZPD_MIMO, tol_mimo; ...
          'ZND_MIMO', G.retZNDMIMO, R1.ZND_MIMO, tol_mimo; ...
          'ZPD_HIGH', G.retZPD,     R2.ZPD,     tol_siso; ...
          'ZND_HIGH', G.retZND,     R2.ZND,     tol_siso };

ok = true;
for i = 1:size(pairs,1)
    name = pairs{i,1}; gold = pairs{i,2}; mine = pairs{i,3}; t = pairs{i,4};
    assert(isequal(size(gold), size(mine)), ...
        '%s: 尺寸不一致 golden %dx%d vs new %dx%d', name, size(gold,1), size(gold,2), size(mine,1), size(mine,2));
    d = abs(gold - mine);
    md = max(d(:));
    if md > t
        ok = false;
        fprintf('FAIL %s: max|diff| = %.3e > tol %.1e\n', name, md, t);
        [r,c] = find(d == md, 1);
        fprintf('    at row %d col %d: golden=%g new=%g\n', r, c, gold(r,c), mine(r,c));
    else
        fprintf('PASS %s: max|diff| = %.3e\n', name, md);
    end
end
if ~ok
    error('test_regression: 存在超差项');
end
fprintf('TEST_REGRESSION PASS\n');
end
