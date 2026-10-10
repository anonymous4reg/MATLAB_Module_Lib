function W = extract_components(U, I, f, f0)
%EXTRACT_COMPONENTS 对单个 1 秒窗口做 FFT，提取正/负序自频点与镜像频点复相量。
%
% 输入：
%   U, I    3 x N 三相电压/电流时域采样（电流符号已由调用方按路径约定应用）
%   f       本窗口注入频率 (Hz)
%   f0      基频 (Hz)
%
% 输出 W（复相量；幅值采用原代码"单边谱×2"归一化，Z=V/I 与归一化无关）：
%   W.f, W.f_mirror_p, W.f_mirror_n
%   W.angle0             基波正序电压参考角（含原代码笔误，见 FIX）
%   -- 原始（未旋转）相量 --
%   W.Vp_raw, W.Ip_raw     正序 @f
%   W.Vp_m_raw, W.Ip_m_raw 正序镜像 @(2*f0-f)（负频率时取共轭 bin）
%   W.Vn_raw, W.In_raw     负序 @f
%   W.Vn_m_raw, W.In_m_raw 负序镜像 @(2*f0+f)
%   -- 按原代码约定旋转后的相量（ScanImpedanceP/N 输出）--
%   正序（自频点与镜像）：X*exp(-1j*angle0)
%   负序自频点：conj(X)*exp(-1j*angle0)（原 ScanImpedanceN 的 -angle 约定）
%   负序镜像：X*exp(-1j*angle0)
%   W.Vp, W.Ip, W.Vp_m, W.Ip_m, W.Vn, W.In, W.Vn_m, W.In_m
%
% 与原代码对应：ScanImpedanceP.m L61-185、ScanImpedanceN.m L66-186。
% 本函数是全工程唯一做 FFT / 幅相提取 / 旋转约定的地方（重构要点）。

N = size(U, 2);
assert(mod(N,2)==0, 'extract_components: 窗口长度必须为偶数');

% ---- 1) 六个通道的 FFT 与幅相提取（复现原代码 magUas/phaseUas 配方）----
Ufft = fft(U, [], 2);          % 3 x N
Ifft = fft(I, [], 2);

magU = abs(Ufft / N); magU = magU(:, 1:N/2); magU(:, 2:end-1) = 2*magU(:, 2:end-1);
magI = abs(Ifft / N); magI = magI(:, 1:N/2); magI(:, 2:end-1) = 2*magI(:, 2:end-1);
phU  = angle(Ufft);            % 相位取原始 FFT 相位（与原代码一致）
phI  = angle(Ifft);

% 取某频点某相的复相量：幅值(单边×2归一) * exp(1j*相位)
X = @(magrow, phrow, freq) magrow(freq+1) .* exp(1i*phrow(freq+1));

% ---- 2) 各频点三相复相量 ----
f_pm = 2*f0 - f;               % 正序镜像频率（可为负）
f_nm = 2*f0 + f;               % 负序镜像频率（恒正）

% 自频点 f
Ua_f = X(magU(1,:), phU(1,:), f); Ub_f = X(magU(2,:), phU(2,:), f); Uc_f = X(magU(3,:), phU(3,:), f);
Ia_f = X(magI(1,:), phI(1,:), f); Ib_f = X(magI(2,:), phI(2,:), f); Ic_f = X(magI(3,:), phI(3,:), f);
% 正序镜像 2*f0-f（负频率时取 |..| 的 bin、相位取反=共轭，复现 ScanImpedanceP L121-148）
if f_pm < 0
    U_pm = [conj(X(magU(1,:), phU(1,:), -f_pm)); conj(X(magU(2,:), phU(2,:), -f_pm)); conj(X(magU(3,:), phU(3,:), -f_pm))];
    I_pm = [conj(X(magI(1,:), phI(1,:), -f_pm)); conj(X(magI(2,:), phI(2,:), -f_pm)); conj(X(magI(3,:), phI(3,:), -f_pm))];
else
    U_pm = [X(magU(1,:), phU(1,:), f_pm); X(magU(2,:), phU(2,:), f_pm); X(magU(3,:), phU(3,:), f_pm)];
    I_pm = [X(magI(1,:), phI(1,:), f_pm); X(magI(2,:), phI(2,:), f_pm); X(magI(3,:), phI(3,:), f_pm)];
end
% 负序镜像 2*f0+f（恒正）
Ua_nm = X(magU(1,:), phU(1,:), f_nm); Ub_nm = X(magU(2,:), phU(2,:), f_nm); Uc_nm = X(magU(3,:), phU(3,:), f_nm);
Ia_nm = X(magI(1,:), phI(1,:), f_nm); Ib_nm = X(magI(2,:), phI(2,:), f_nm); Ic_nm = X(magI(3,:), phI(3,:), f_nm);

% ---- 3) 正/负序变换（seq_transform 的唯一调用点）----
[Vp, Vn]     = seq_transform(Ua_f, Ub_f, Uc_f);
[Ip, In]     = seq_transform(Ia_f, Ib_f, Ic_f);
[Vp_m, ~]    = seq_transform(U_pm(1), U_pm(2), U_pm(3));
[Ip_m, ~]    = seq_transform(I_pm(1), I_pm(2), I_pm(3));
[~, Vn_m]    = seq_transform(Ua_nm, Ub_nm, Uc_nm);
[~, In_m]    = seq_transform(Ia_nm, Ib_nm, Ic_nm);

% ---- 4) 基波参考角 angle0 ----
Ua0 = X(magU(1,:), phU(1,:), f0); Ub0 = X(magU(2,:), phU(2,:), f0); Uc0 = X(magU(3,:), phU(3,:), f0);
% FIX(P2): 原代码（及 P1 复刻）Vp0 误用电流幅值乘电压相位；三相平衡时幅值
%          相同不影响相角，不平衡时参考角有偏差。现改为电压幅值。
% OLD: Vp0 = (abs(Ia0)*exp(1i*angle(Ua0)) + abs(Ib0)*exp(1i*(angle(Ub0)+2*pi/3)) + abs(Ic0)*exp(1i*(angle(Uc0)-2*pi/3)))/3;
Vp0   = (abs(Ua0)*exp(1i*angle(Ua0)) + abs(Ub0)*exp(1i*(angle(Ub0)+2*pi/3)) + abs(Uc0)*exp(1i*(angle(Uc0)-2*pi/3)))/3;
angle0 = angle(Vp0);

% ---- 5) 旋转（复现原代码 cos/sin 配方，保证数值一致）----
rot_p = @(Xv) abs(Xv).*(cos(angle(Xv)-angle0) + 1i*sin(angle(Xv)-angle0));
rot_n = @(Xv) abs(Xv).*(cos(-angle(Xv)-angle0) + 1i*sin(-angle(Xv)-angle0));  % 负序自频点取共轭

% ---- 6) 组装输出 ----
W = struct();
W.f = f; W.f_mirror_p = f_pm; W.f_mirror_n = f_nm; W.angle0 = angle0;

W.Vp_raw = Vp;     W.Ip_raw = Ip;
W.Vp_m_raw = Vp_m; W.Ip_m_raw = Ip_m;
W.Vn_raw = Vn;     W.In_raw = In;
W.Vn_m_raw = Vn_m; W.In_m_raw = In_m;

W.Vp = rot_p(Vp);       W.Ip = rot_p(Ip);
W.Vp_m = rot_p(Vp_m);   W.Ip_m = rot_p(Ip_m);
W.Vn = rot_n(Vn);       W.In = rot_n(In);        % 负序自频点：conj 约定
W.Vn_m = rot_p(Vn_m);   W.In_m = rot_p(In_m);    % 负序镜像：不取共轭（原代码约定）
end
