function [freq_ax, mag_ax, ang_ax] = fft_symmetric_component(input_sig, ...
	fs, signal_length)
%UNTITLED2 Summary of this function goes here
%   fs: sampling frequency
%	ts: sample time, = 1/fs
%	t_span: time span
%	signal_length: t_span * fs

a = exp(1.0i * 2 * pi / 3);
Abc2Pn0Mat = (1/3) .* [1  a  a^2; 1  a^2  a; 1  1  1];

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

% why -1.0i or 1.0i
spectrum_single_complex = spectrum_single_mag .* exp(-1.0i .* ...
	spectrum_single_angle);

spectrum_pn0_complex = (Abc2Pn0Mat * spectrum_single_complex')';

spectrum_pn0_mag = abs(spectrum_pn0_complex);
spectrum_pn0_angle = angle(spectrum_pn0_complex);

freq_ax = 0 : (1/t_span) : fs/2;
freq_ax = freq_ax(1 : end - 1)';

mag_ax = spectrum_pn0_mag;
ang_ax = spectrum_pn0_angle .* (abs(mag_ax) >= 1e-10);

end

