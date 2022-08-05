function [freq_ax, mag_ax, ang_ax, complex_ax] = f_fft_simple(input_sig, ...
	fs, signal_length)
%UNTITLED2 Summary of this function goes here
%   fs: sampling frequency
%	ts: sample time, = 1/fs
%	t_span: time span
%	signal_length: t_span * fs, this will be the window width

[row, col] = size(input_sig);
ts = 1/fs;	% sampling period
% signal_length = t_span * fs;  % lenght of sig
t_span = signal_length / fs;

raw_fft = fft(input_sig, signal_length, 1);

spectrum_dual_mag = abs(raw_fft / signal_length);
spectrum_dual_angle = angle(raw_fft);

spectrum_single_mag = spectrum_dual_mag;
spectrum_single_mag(2:end - 1) = 2 .* spectrum_dual_mag(2:end - 1);  %  
spectrum_single_mag = spectrum_single_mag(1:(signal_length / 2), :);
spectrum_single_angle = spectrum_dual_angle(1:(signal_length / 2), :);

freq_ax = 0 : (1/t_span) : fs/2;
freq_ax = freq_ax(1 : end - 1)';

mag_ax = spectrum_single_mag;
ang_ax = spectrum_single_angle .* (abs(mag_ax) >= 1e-10); % avoiding angle singular
complex_ax = raw_fft ./ signal_length;

end

