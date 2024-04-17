function [freq_ax, mag_ax, ang_ax, complex_ax] = f_3ph_fft_pn0(input_sig, ...
	fs, signal_length)
% verion 2：
%			change to matrix multiplication method. Also add pi/2 to phase to 
%			make Sine as phase=0
%   fs: sampling frequency
%	ts: sample time, = 1/fs
%	t_span: time span
%	signal_length: t_span * fs, this will be the window width

[row, col] = size(input_sig);
assert(col==3, 'Input signal must be N*3 matrix')
ts = 1/fs;	% sampling period
% signal_length = t_span * fs;  % lenght of sig
t_span = signal_length / fs;

ans_length = ceil((signal_length + 1)/2);

freq_abc    = zeros(ans_length, 3);
mag_abc     = zeros(ans_length, 3);
ang_abc     = zeros(ans_length, 3);
cmp_abc     = zeros(ans_length, 3);
complex_abc = zeros(1, 3);

mat_abc2pn0 = [1, exp(1j*(2*pi/3)), exp(1j*( -2*pi/3)); ...
               1, exp(1j*( -2*pi/3)), exp(1j*(2*pi/3)); ...
               1, 1, 1]./3;

[freq_abc, mag_abc, ang_abc, cmp_abc] = ...
	    f_fft_simple(input_sig, int64(fs), int64(signal_length));

% Matlab set Cosine as phase=0. Here change to Sine as phase=0;
ang_abc =  ang_abc + pi/2;
cmp_abc = cmp_abc .* exp(1j*pi/2);

ans_mat = mat_abc2pn0 * cmp_abc.';
ans_mat = ans_mat.';


freq_ax = freq_abc(:, 1);
mag_ax = [abs(ans_mat(:, 1)), abs(ans_mat(:, 2)), abs(ans_mat(:, 3))];
ang_ax = [angle(ans_mat(:, 1)), angle(ans_mat(:, 2)), angle(ans_mat(:, 3))];
complex_ax = ans_mat;
end