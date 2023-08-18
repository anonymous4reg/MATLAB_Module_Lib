function [freq_ax, mag_ax, ang_ax, complex_ax] = f_fft_simple(input_sig, ...
	fs, signal_length)
% __f_fft_simple__ Summary of this function goes here
%   fs: sampling frequency
%	ts: sample time, = 1/fs
%	t_span: time span
%	signal_length: t_span * fs, this will be the window width

%% fft usage explaination
% fft(X, n) return the bilateral spectrum. frequency range depends on signal sample dots, 
% the length of X. If the signal X is M by n matrix, n represents signal length, then the
% fft return a 1 by n length complex vector (The bilateral spectrum). 
% While according to Matlab help document, the unique point in the bilateral spectrum vector
% is ceil((n+1)/2).
% complex number is arrange in frequency point 0, 1, ... ceil((n+1)/2), ..., 1, 0. 
% So, if the n is even number, ceil((n+1)/2) = n/2+1, if n is odd number, ceil((n+1)/2) = (n+1)/2
assert(isinteger(fs), 'Sample frequency must be integer. Use function int64() to convert double to int')
assert(isinteger(signal_length), 'Signal length must be Integer. Use function int64() to convert double to int')

[row, col] = size(input_sig);

ts = 1/fs;	% sampling period
t_span = signal_length / fs;

unique_points = int64(ceil((signal_length + 1)/2));

fft_bilateral = fft(input_sig, signal_length, 1) ./ double(signal_length); % 1 means dim=1
fft_unilateral = fft_bilateral(1:unique_points, :);
fft_unilateral(2:end - 1, :) = fft_unilateral(2:end - 1, :)*2.0;


spectrum_single_mag = abs(fft_unilateral); 
spectrum_single_angle = angle(fft_unilateral);

freq_ax = fs * (0:(signal_length/2)) / signal_length;

mag_ax = spectrum_single_mag;
ang_ax = spectrum_single_angle; % .* (abs(mag_ax) >= 1e-10); % avoiding angle singular
complex_ax = fft_unilateral;
end

