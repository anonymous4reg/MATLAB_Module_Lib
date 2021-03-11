function [freq_ax, mag_ax, ang_ax] = fft_simple(input_sig, ...
	fs, t_span)
%UNTITLED2 Summary of this function goes here
%   fs: sampling frequency
%	ts: sample time, = 1/fs
%	t_span: time span
%	sig_length: t_span * fs

[row, col] = size(input_sig);
ts = 1/fs;	% sampling period
sig_length = t_span * fs;  % lenght of sig
n = 2^nextpow2(sig_length);

raw_fft = fft(input_sig, sig_length, 1);

spectrum_dual_mag = abs(raw_fft / sig_length);
spectrum_dual_angle = angle(raw_fft);

spectrum_single_mag = spectrum_dual_mag;
spectrum_single_mag(2:end - 1) = 2 .* spectrum_dual_mag(2:end - 1);  %  
spectrum_single_mag = spectrum_single_mag(1:(sig_length / 2), :);
spectrum_single_angle = spectrum_dual_angle(1:(sig_length / 2), :);

freq_ax = 0 : (1/t_span) : fs/2;
freq_ax = freq_ax(1 : end - 1)';

mag_ax = spectrum_single_mag;
ang_ax = spectrum_single_angle;

end

