function [freq_ax, mag_ax, ang_ax, complex_ax] = f_fft_simple(input_sig, ...
    fs, signal_length, window_type)
% f_fft_simple  FFT 频谱分析（支持加窗）
%
%   输入参数：
%     input_sig     - 输入信号，列向量或 N×M 矩阵（M 个通道）
%     fs            - 采样频率 (int64)
%     signal_length - FFT 长度/窗宽（采样点数, int64）
%     window_type   - (可选) 窗函数类型: 'none'(默认), 'hann', 'hamming', 'blackman'
%
%   输出参数：
%     freq_ax    - 单边频率轴 (N/2+1 × 1, double)
%     mag_ax     - 单边幅值谱 (与 input_sig 同列数)
%     ang_ax     - 单边相位谱 (rad)
%     complex_ax - 单边复频谱
%
%   频率分辨率 Δf = fs / signal_length
%
%   窗函数与幅值修正：
%     'none'     - 矩形窗，幅值修正 = 1.000（等同不加窗）
%     'hann'     - Hann 窗，幅值修正 = 2.000（相干增益 0.5 的倒数）
%     'hamming'  - Hamming 窗，幅值修正 ≈ 1.852（相干增益 0.54 的倒数）
%     'blackman' - Blackman 窗，幅值修正 ≈ 2.380（相干增益 0.42 的倒数）
%
%   加窗有效地抑制频谱旁瓣泄漏，代价是主瓣展宽（频率分辨率下降）。
%   幅值修正确保 bin 中心处的幅值读数正确；对于中间偏移（δ≠0），
%   需额外使用 f_extract_by_ipdft() 做插值以补偿扇形损耗（scalloping loss）。

if nargin < 4
    window_type = 'none';
end

assert(isinteger(fs), 'Sample frequency must be integer. Use function int64() to convert double to int')
assert(isinteger(signal_length), 'Signal length must be Integer. Use function int64() to convert double to int')

[row, col] = size(input_sig);

ts = 1/fs;  % sampling period
t_span = signal_length / fs;

unique_points = int64(ceil((signal_length + 1)/2));

%% --- 加窗处理 ---
% 窗函数生成与幅值修正系数（相干增益的倒数）
N = double(signal_length);
switch lower(window_type)
    case 'none'
        win = ones(N, 1);
        amp_correction = 1;
    case 'hann'
        win = hann(N, 'periodic');
        amp_correction = 2.0;          % 1 / 0.5
    case 'hamming'
        win = hamming(N, 'periodic');
        amp_correction = 1.852;        % 1 / 0.54
    case 'blackman'
        win = blackman(N, 'periodic');
        amp_correction = 2.380;        % 1 / 0.42
    otherwise
        error('f_fft_simple: 未知窗类型 "%s"。可选: none, hann, hamming, blackman', window_type);
end

input_sig_win = input_sig .* win;   % 信号 × 窗

%% FFT（在加窗信号上执行）
% 1 means dim=1
fft_bilateral = fft(input_sig_win, signal_length, 1) ./ N;
fft_unilateral = fft_bilateral(1:unique_points, :);
fft_unilateral(2:end - 1, :) = fft_unilateral(2:end - 1, :) * 2.0;

% 幅值修正：补偿窗函数的相干增益损失
fft_unilateral = fft_unilateral * amp_correction;

spectrum_single_mag = abs(fft_unilateral);
spectrum_single_angle = angle(fft_unilateral);

freq_ax = transpose(double(fs) * double(0:(signal_length/2)) / double(signal_length));

mag_ax = spectrum_single_mag;
ang_ax = spectrum_single_angle;
complex_ax = fft_unilateral;

end
