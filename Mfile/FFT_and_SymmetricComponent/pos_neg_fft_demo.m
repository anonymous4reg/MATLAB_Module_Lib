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

subplot(2, 1, 1)
plot(fx, mx, 'linewidth', 1.8)
axisbk = axis;
axis([0, 100, axisbk(3:4)])
subplot(2, 1, 2)
plot(fx, ax * 180 / pi, 'linewidth', 1.8)
axisbk = axis;
axis([0, 100, axisbk(3:4)])

