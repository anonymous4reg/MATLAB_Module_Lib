function [freq_ax, mag_ax, ang_ax, complex_ax] = f_3ph_fft_pn0(input_sig, ...
    fs, signal_length, window_type)
% f_3ph_fft_pn0  三相信号 → 正序 / 负序 / 零序 频谱
%
%   输入参数：
%     input_sig     - N×3 矩阵，列序 = [A相, B相, C相]
%     fs            - 采样频率 (int64)
%     signal_length - FFT 长度/窗宽（采样点数, int64）
%     window_type   - (可选) 窗函数类型，原样透传给 f_fft_simple：
%                     'none'(默认) / 'hann' / 'hamming' / 'blackman'
%
%   输出参数（均为 单边谱长度 × 3，列序 = [正序, 负序, 零序]）：
%     freq_ax    - 单边频率轴 (单边谱长度 × 1, double)
%     mag_ax     - 序分量幅值谱
%     ang_ax     - 序分量相位谱 (rad)
%     complex_ax - 序分量复频谱
%
%   序分量定义（a = exp(j·2π/3)）：
%     正序 F1 = (Fa + a ·Fb + a²·Fc) / 3
%     负序 F2 = (Fa + a²·Fb + a ·Fc) / 3
%     零序 F0 = (Fa +    Fb +    Fc) / 3
%
%   说明：
%     - 三相频谱由 f_fft_simple 逐相计算，fs / 窗函数 / 幅值修正三者完全一致，
%       因此三相共用同一相位参考（f_fft_simple 的 FFT 固有约定为余弦参考）。
%       该参考相位对三相是同一个常数，故序分量的**幅值**不受其影响；
%       序分量**相位**则是相对余弦的相角。
%     - window_type 由本函数透传给 f_fft_simple，保证两者窗设置始终一致；
%       省略该参数时默认 'none'（与 f_fft_simple 的默认值一致）。
%     - 输入行数不必等于 signal_length：本函数会先按 fft(x, N) 的语义统一长度
%       （多则取前 N 点，少则补零），再交给 f_fft_simple。
%       这是必需的 —— 新版 f_fft_simple 会逐点乘以长度为 signal_length 的窗。
%
%   依赖：f_fft_simple.m

if nargin < 4 || isempty(window_type)
    window_type = 'none';
end

[~, col] = size(input_sig);
assert(col == 3, 'Input signal must be N*3 matrix')

N = double(signal_length);

% 新版 f_fft_simple 会逐点乘以长度为 signal_length 的窗，
% 因此要求输入行数**严格等于** signal_length。这里按 fft(x, N) 的语义统一长度：
%   多则截断（取前 N 点），少则补零 —— 与旧版 f_fft_simple 的行为保持一致。
nRow = size(input_sig, 1);
if nRow > N
    input_sig = input_sig(1:N, :);
elseif nRow < N
    input_sig = [input_sig; zeros(N - nRow, col)];
end

% 单边谱点数，与 f_fft_simple 的输出长度一致：floor(N/2) + 1
nFreq = floor(N / 2) + 1;

freq_abc = zeros(nFreq, 3);   % 各相频率轴（三相相同）
cmp_abc  = zeros(nFreq, 3);   % 各相复频谱

for idx = 1:3
    [fq, ~, ~, cx] = f_fft_simple(input_sig(:, idx), ...
        int64(fs), int64(signal_length), window_type);
    freq_abc(:, idx) = fq;
    cmp_abc(:, idx)  = cx;
end

% ---- ABC → 正 / 负 / 零序（逐频点，向量化）----
a = exp(1j * 2 * pi / 3);     % 120° 旋转算子
Fa = cmp_abc(:, 1);
Fb = cmp_abc(:, 2);
Fc = cmp_abc(:, 3);

pos_seq  = (Fa + a   * Fb + a^2 * Fc) / 3;
neg_seq  = (Fa + a^2 * Fb + a   * Fc) / 3;
zero_seq = (Fa +       Fb +       Fc) / 3;

freq_ax    = freq_abc(:, 1);
mag_ax     = [abs(pos_seq),   abs(neg_seq),   abs(zero_seq)];
ang_ax     = [angle(pos_seq), angle(neg_seq), angle(zero_seq)];
complex_ax = [pos_seq, neg_seq, zero_seq];

end
