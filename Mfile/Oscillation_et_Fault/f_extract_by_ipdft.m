function [mag_interp, ang_interp, complex_interp, freq_corrected] = ...
    f_extract_by_ipdft(freq_ax, complex_spec, target_freqs, window_type)
% f_extract_by_ipdft  IpDFT 插值提取指定频率的复幅值
%
%   对 FFT 输出的复频谱做两点幅值插值，补偿栅栏效应 / 扇形损耗
%   （scalloping loss），使得频率不在 bin 中心时也能准确估计幅值和相位。
%
%   输入参数：
%     freq_ax       - 频率轴 (N_bins × 1, double)，来自 f_fft_simple
%     complex_spec  - 单边复频谱 (N_bins × M, M 个通道)，来自 f_fft_simple
%     target_freqs  - 待提取频率的向量 (n_freq × 1, double)
%     window_type   - 窗函数类型，须与 f_fft_simple 中使用的类型一致
%                     'none', 'hann', 'hamming', 'blackman'
%
%   输出参数：
%     mag_interp     - 插值后的幅值 (n_freq × M)
%     ang_interp     - 插值后的相位 (rad, n_freq × M)
%     complex_interp - 插值后的复数值 (n_freq × M)
%     freq_corrected - 修正后的估计频率 (n_freq × 1)
%
%   插值算法：
%     对每个目标频率 f_target：
%       1. 在 [f_target-2Δf, f_target+2Δf] 范围内搜索峰值 bin m
%       2. 取相邻 bin 中较大的一个，计算幅值比 β = |X(adj)| / |X(m)|
%       3. 由 β 与窗函数公式估计分数偏移 δ ∈ [0, 0.5]
%       4. 幅值修正：A_corr = |X(m)| × rect_fac(δ, window_type)
%       5. 频率修正：f_corr = (m + δ_sign·δ) × Δf
%       6. 相位修正：φ_corr = angle(X(m)) - π·δ·δ_sign
%
%   参考：
%     [1] Schoukens et al., "Estimation of the Parameters of
%         a Sinusoid by Interpolated FFT", IEEE IM-40, 1991.

%% 参数检查
if nargin < 4
    window_type = 'none';
end

%% 预处理
delta_f = freq_ax(2) - freq_ax(1);          % 频率分辨率
n_bins  = length(freq_ax);
n_freq  = length(target_freqs);
n_ch    = size(complex_spec, 2);

% 输出预分配
complex_interp = zeros(n_freq, n_ch);
freq_corrected = zeros(n_freq, 1);

%% 主循环：对每个目标频率
for f_idx = 1:n_freq
    f_target = target_freqs(f_idx);

    % --- 1. 搜索范围：目标频率 ± 2 个 bin ---
    bin_target = round(f_target / delta_f) + 1;   % 最接近的 bin（1-indexed）
    bin_lo = max(2,  bin_target - 2);              % 避免 DC (bin 1) 和越界
    bin_hi = min(n_bins - 1, bin_target + 2);      % 避免 Nyquist

    % --- 2. 对每个通道执行 IpDFT ---
    for ch = 1:n_ch
        spec_ch = complex_spec(:, ch);

        % 搜索范围内找峰值 bin
        [~, peak_local] = max(abs(spec_ch(bin_lo:bin_hi)));
        m = bin_lo + peak_local - 1;   % 峰值 bin 的绝对索引

        % 比较左右邻 bin，选幅值较大的方向
        if m <= 1
            % 在 DC 边界，只能向右
            adj = m + 1;
            dir_sign = +1;
        elseif m >= n_bins
            % 在 Nyquist 边界，只能向左
            adj = m - 1;
            dir_sign = -1;
        else
            mag_left  = abs(spec_ch(m - 1));
            mag_right = abs(spec_ch(m + 1));
            if mag_right >= mag_left
                adj = m + 1;
                dir_sign = +1;
            else
                adj = m - 1;
                dir_sign = -1;
            end
        end

        X_peak    = spec_ch(m);
        X_adj     = spec_ch(adj);
        mag_peak  = abs(X_peak);
        mag_adj   = abs(X_adj);

        % --- 3. 幅值比 → 分数偏移 δ ---
        if mag_peak < eps
            % 信号极弱或为零，直接返回
            complex_interp(f_idx, ch) = 0;
            continue;
        end

        beta = mag_adj / mag_peak;   % 0 ≤ β ≤ 1

        switch lower(window_type)
            case 'none'
                % 矩形窗: β ≈ δ/(1-δ)
                if beta >= 0.9999
                    delta_frac = 0.5;
                else
                    delta_frac = beta / (1 + beta);
                end
                % 幅值修正: |W_rect(δ)|⁻¹ = πδ/sin(πδ)
                scallop_correction = @(d) pi * d / sin(pi * d);

            case 'hann'
                % Hann 窗: β ≈ (1+δ)/(2-δ)
                if beta >= 0.9999
                    delta_frac = 0.5;
                else
                    delta_frac = (2 * beta - 1) / (beta + 1);
                end
                % 幅值修正: |W_hann(δ)|⁻¹ 的额外 scalloping loss 因子
                % f_fft_simple 的 amp_correction=2 已补偿相干增益 (δ=0)
                % 对于 δ≠0，额外衰减因子 = |W_hann(δ)|/coherent_gain
                %   = [sin(πδ)/(2πδ(1-δ²))] / 0.5 = sin(πδ)/(πδ(1-δ²))
                % 所以: A = |X(m)| / (sin(πδ)/(πδ(1-δ²)))
                %          = |X(m)| · πδ(1-δ²)/sin(πδ)
                scallop_correction = @(d) pi * d * (1 - d^2) / sin(pi * d);

            case 'hamming'
                % Hamming 近似用 Hann 的 δ 估计公式（工程上误差可接受）
                if beta >= 0.9999
                    delta_frac = 0.5;
                else
                    delta_frac = (2 * beta - 1) / (beta + 1);
                end
                scallop_correction = @(d) pi * d * (1 - d^2) / sin(pi * d);

            case 'blackman'
                % Blackman 近似
                if beta >= 0.9999
                    delta_frac = 0.5;
                else
                    delta_frac = (2 * beta - 1) / (beta + 1);
                end
                scallop_correction = @(d) pi * d * (1 - d^2) / sin(pi * d);

            otherwise
                error('f_extract_by_ipdft: 未知窗类型 "%s"', window_type);
        end

        % 数值保护：δ ∈ [0, 0.5]
        delta_frac = max(0, min(0.5, delta_frac));

        % --- 4. 幅值修正 ---
        if delta_frac < 1e-12
            mag_corrected = mag_peak;    % 正好在 bin 中心
        else
            mag_corrected = mag_peak * scallop_correction(delta_frac);
        end

        % --- 5. 相位修正 ---
        ang_corrected = angle(X_peak) - pi * delta_frac * dir_sign;

        % --- 6. 构建修正复数 ---
        complex_interp(f_idx, ch) = mag_corrected * exp(1i * ang_corrected);

    end % for ch

    % 修正频率（所有通道共享同一峰 bin，取第一通道的结果）
    freq_corrected(f_idx) = (m - 1 + dir_sign * delta_frac) * delta_f;

end % for f_idx

%% 输出
mag_interp     = abs(complex_interp);
ang_interp     = angle(complex_interp);

end
