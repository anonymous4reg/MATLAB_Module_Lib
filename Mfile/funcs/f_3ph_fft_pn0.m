function [freq_ax, mag_ax, ang_ax, complex_ax] = f_3ph_fft_pn0(input_sig, ...
	fs, signal_length)
%UNTITLED2 Summary of this function goes here
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
complex_abc = zeros(1, 3);

mat_abc2pn0 = [exp(1j), exp(1j*(-2*pi/3)), exp(1j*( 2*pi/3)); ...
               exp(1j), exp(1j*( 2*pi/3)), exp(1j*(-2*pi/3)); ...
               1, 1, 1]./3;

for idx = 1:3
	[freq_abc(:, idx), mag_abc(:, idx), ang_abc(:, idx), ~] = ...
	    f_fft_simple(input_sig(:, idx), int64(fs), int64(signal_length));

	pos_seq = (mag_abc(:, 1).*exp(1i.* ang_abc(:, 1)) + ...
			   mag_abc(:, 2).*exp(1i.*(ang_abc(:, 2) + 2*pi/3)) + ...
			   mag_abc(:, 3).*exp(1i.*(ang_abc(:, 3) - 2*pi/3)))/3;

	neg_seq = (mag_abc(:, 1).*exp(1i.* ang_abc(:, 1)) + ...
			   mag_abc(:, 2).*exp(1i.*(ang_abc(:, 2) - 2*pi/3)) + ...
			   mag_abc(:, 3).*exp(1i.*(ang_abc(:, 3) + 2*pi/3)))/3;

	zero_seq =(mag_abc(:, 1).*exp(1.i* ang_abc(:, 1)) + ...
			   mag_abc(:, 2).*exp(1.i*(ang_abc(:, 2))) + ...
			   mag_abc(:, 3).*exp(1.i*(ang_abc(:, 3))))/3;
end



freq_ax = freq_abc(:, 1);
mag_ax = [abs(pos_seq), abs(neg_seq), abs(zero_seq)];
ang_ax = [angle(pos_seq), angle(neg_seq), angle(zero_seq)];
complex_ax = [pos_seq, neg_seq, zero_seq];
end

