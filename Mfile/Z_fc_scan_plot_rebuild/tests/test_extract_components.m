function test_extract_components()
%TEST_EXTRACT_COMPONENTS 单元测试：FFT 幅相提取与正负序变换的正确性。
% 构造已知频谱的三相信号，验证 extract_components 的复相量输出。

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'core'));

fs = 10000; N = fs;              % 1 秒窗口
t = (0:N-1)/fs;
f0 = 50; f = 37;                 % 注入频率 37Hz
AmpV = 280; AmpI = 40;
phV = 30*pi/180; phI = -20*pi/180;

% 三相平衡正序注入 @f（电压）+ 平衡电流（滞后 50°）
th = 2*pi/3;
ua = AmpV*cos(2*pi*f*t + phV);
ub = AmpV*cos(2*pi*f*t + phV - th);
uc = AmpV*cos(2*pi*f*t + phV + th);
ia = AmpI*cos(2*pi*f*t + phI);
ib = AmpI*cos(2*pi*f*t + phI - th);
ic = AmpI*cos(2*pi*f*t + phI + th);
U = [ua; ub; uc]; I = [ia; ib; ic];

W = extract_components(U, I, f, f0);

% 自频点正序：幅值应为 AmpV/AmpI，相位应为 phV/phI（峰值约定，单边谱×2）
tol = 1e-9;
assert(abs(abs(W.Vp_raw) - AmpV) < tol, 'Vp 幅值错误: %g vs %g', abs(W.Vp_raw), AmpV);
assert(abs(angle(W.Vp_raw) - phV) < tol, 'Vp 相位错误: %g vs %g', angle(W.Vp_raw), phV);
assert(abs(abs(W.Ip_raw) - AmpI) < tol, 'Ip 幅值错误');
assert(abs(angle(W.Ip_raw) - phI) < tol, 'Ip 相位错误');

% 平衡输入下负序应为 0
assert(abs(W.Vn_raw) < tol, '平衡正序下 Vn 应为 0，得 %g', abs(W.Vn_raw));
assert(abs(W.In_raw) < tol, '平衡正序下 In 应为 0，得 %g', abs(W.In_raw));

% SISO 阻抗 = V/I
Z = W.Vp_raw/W.Ip_raw;
Zexp = (AmpV/AmpI)*exp(1i*(phV-phI));
assert(abs(Z - Zexp) < tol, 'SISO 阻抗错误');

% 基波参考角：信号无基波分量时 angle0 无定义，跳过；此处仅验证无异常
fprintf('TEST_EXTRACT_COMPONENTS PASS\n');
end
