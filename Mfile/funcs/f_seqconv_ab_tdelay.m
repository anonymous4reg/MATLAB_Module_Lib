function [V1_mag, V2_mag, V0, Valpha, Vbeta] = f_seqconv_ab_tdelay(Va, Vb, Vc, fs, f0)
% f_seqconv_ab_tdelay  三相瞬时值 → 正负零序幅值（αβ + 正交信号法）
%
%   [V1_mag, V2_mag, V0] = f_seqconv_ab_tdelay(Va, Vb, Vc, fs, f0)
%   [V1_mag, V2_mag, V0, Valpha, Vbeta] = f_seqconv_ab_tdelay(...)
%
%   输入：
%     Va, Vb, Vc  — 三相瞬时值列向量（长度相同，单位任意）
%     fs          — 采样频率 (Hz)
%     f0          — 基波频率 (Hz)，用于构造 T/4 延时
%
%   输出：
%     V1_mag  — 瞬时正序幅值 (与输入同长度)，平衡稳态时为常量
%     V2_mag  — 瞬时负序幅值 (与输入同长度)，平衡稳态≈0，故障时抬升
%     V0      — 零序瞬时值 (与输入同长度)，V0 = (Va + Vb + Vc) / 3
%     Valpha  — (可选) Clarke α 轴分量
%     Vbeta   — (可选) Clarke β 轴分量
%
%   【原理】
%     1. Clarke 变换:  abc → αβ0
%          Vα = (2Va - Vb - Vc) / 3
%          Vβ = (Vb - Vc) / √3
%          V0 = (Va + Vb + Vc) / 3
%
%     2. T/4 延时产生 90° 正交信号 α⊥, β⊥
%
%     3. 合成序分量幅值：
%          |V1| = 0.5·√[(Vα - Vβ⊥)² + (Vβ + Vα⊥)²]
%          |V2| = 0.5·√[(Vα + Vβ⊥)² + (Vβ - Vα⊥)²]
%
%   【为什么不用 Fortescue 直接算瞬时值？】
%     直接对瞬时值做 Fortescue：
%       V1_fort = (Vm/2)·e^(jωt)    → 复旋转量，实部振荡，不是直流
%       V2_fort = (Vm/2)·e^(-jωt)   → |V2| 平衡时也不为零！
%     原因：cos(ωt) = (e^(jωt)+e^(-jωt))/2，
%     实数信号同时含正反两个旋转方向。
%
%     本方法通过 Clarke + 正交信号分离旋转方向，
%     对平衡系统 |V1|≈常量、|V2|≈0，区别于 Fortescue。
%
%   【延时精度】
%     假设基波为正弦，比理想的 Hilbert 90° 移相稍粗糙，
%     但对固定频率应用足够（T/4 延时在 f≠f0 时会有误差）。
%     如需宽频移相，可改用 Hilbert 变换或二阶广义积分器 (SOGI)。
%
%   参考：Lyon (1954); Akagi et al., IEEE Trans. IA-20, 1984.
%
%   See also: f_seqconv_pn0_fortescue (待实现)

% 输入校验
narginchk(5, 5);

Va = Va(:);  Vb = Vb(:);  Vc = Vc(:);
assert(length(Va) == length(Vb) && length(Vb) == length(Vc), ...
    'Va, Vb, Vc 长度必须一致。');
assert(fs > 0 && f0 > 0, 'fs 和 f0 必须为正数。');

N = length(Va);

% ---- Clarke 变换: abc → αβ0 ----
V0     = (Va + Vb + Vc) / 3;
Valpha = (2*Va - Vb - Vc) / 3;
Vbeta  = (Vb - Vc) / sqrt(3);

% ---- T/4 延时（90° 相移）----
N_delay = round(fs / (4 * f0));

if N_delay < 1
    error('f0=%.1f Hz 过高或 fs=%.1f Hz 过低，T/4 延时不足 1 个采样点。', f0, fs);
end

% 正交信号：前 N_delay 点补零
Valpha_q = zeros(N, 1);
Vbeta_q  = zeros(N, 1);
Valpha_q(N_delay+1:end) = Valpha(1:end-N_delay);
Vbeta_q(N_delay+1:end)  = Vbeta(1:end-N_delay);

% ---- 合成正序 / 负序幅值 ----
% |V1| = 0.5·√[(Vα - Vβ⊥)² + (Vβ + Vα⊥)²]
% |V2| = 0.5·√[(Vα + Vβ⊥)² + (Vβ - Vα⊥)²]
V1_mag = 0.5 * sqrt((Valpha - Vbeta_q).^2 + (Vbeta + Valpha_q).^2);
V2_mag = 0.5 * sqrt((Valpha + Vbeta_q).^2 + (Vbeta - Valpha_q).^2);

end
