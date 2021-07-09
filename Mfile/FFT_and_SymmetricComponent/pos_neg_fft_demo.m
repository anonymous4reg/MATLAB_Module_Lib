% clear;clc
PosThreePhaseGen = @(amp, freq, t) amp .* [sin(2*pi*freq.*t);  sin(2*pi*freq.*t - 2*pi/3); sin(2*pi*freq.*t + 2*pi/3)]';
NegThreePhaseGen = @(amp, freq, t) amp .* [sin(2*pi*freq.*t);  sin(2*pi*freq.*t + 2*pi/3); sin(2*pi*freq.*t - 2*pi/3)]';
ZeroThreePhaseGen = @(amp, freq, t, phase) amp .* ...
    [sin(2*pi*freq.*t - phase); sin(2*pi*freq.*t - phase); sin(2*pi*freq.*t - phase)]';
a = exp(1j * 2 * pi / 3);
Abc2Pn0Mat = (1/3) .* [1  a  a^2; 1  a^2  a; 1  1  1];



Fs = 1e4;  % sampling freq
T = 1/Fs;	% sampling period
Tspan = 10;  % simulation frequency
L = Tspan * Fs;  % lenght of signal

t = (0:L-1)*T;  % time vector;

Pos50Hz = PosThreePhaseGen(1, 50, t);
Neg58Hz = NegThreePhaseGen(0.5, 58, t);
Zero70Hz = ZeroThreePhaseGen(0.75, 70, t, pi/6);
SigSum = Pos50Hz + Neg58Hz + Zero70Hz;

[fx, mx, ax] = fft_symmetric_component(SigSum, Fs, L);
% [fx, mx, ax] = fft_simple(SigSum, Fs, L);

figure
subplot(2, 1, 1)
set(gcf,'unit','centimeters','position',[10,5,18,8+3])
plot(fx, mx, 'linewidth', 1.8)
xlabel('Frequency (Hz)');
ylabel('Amplitude (\Omega)');
axisbk = axis;
axis([0, 100, axisbk(3:4)])
grid on
set(gca, 'fontname', 'Times new roman')
set(gca, 'ylim', [0, 1.2])


subplot(2, 1, 2)
plot(fx, ax * 180 / pi, 'linewidth', 1.8)
xlabel('Frequency (Hz)');
ylabel('Phase (Deg)');
axisbk = axis;
axis([0, 100, axisbk(3:4)])
grid on
set(gca, 'fontname', 'Times new roman')

% figure
% set(gcf,'unit','centimeters','position',[10,5,18,8+3])
% subplot(2,1,1);
% plot(ZA(:,1), ZA(:,2), '.-', 'MarkerIndices', 1:2:length(ZA), 'color', 'k', ...
% 	'linewidth', 1.0, 'color', [1, 1, 1]/255);
% xlabel('Frequency (Hz)');
% ylabel('Amplitude (\Omega)');
% grid on
% set(gca, 'fontname', 'Times new roman')
% subplot(2,1,2);
% plot(ZA(:,1),ZA(:,3), '.-', 'MarkerIndices', 1:2:length(ZA), 'color', 'k', ...
% 	'linewidth', 1.0, 'color', [1, 1, 1]/255);
% xlabel('Frequency (Hz)');
% ylabel('Phase (Deg)');
% grid on
% set(gca, 'fontname', 'Times new roman')
% saveas(gcf, append(this_file_path, '.fig'))
% saveas(gcf, append(this_file_path, '.emf'))
% print(this_file_path, '-dtiff', '-r600')
