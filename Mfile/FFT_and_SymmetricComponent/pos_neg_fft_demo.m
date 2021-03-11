% clear;clc
PosThreePhaseGen = @(amp, freq, t) amp.*[sin(2*pi*freq.*t);  sin(2*pi*freq.*t - 2*pi/3); sin(2*pi*freq.*t + 2*pi/3)]';
NegThreePhaseGen = @(amp, freq, t) amp.*[sin(2*pi*freq.*t);  sin(2*pi*freq.*t + 2*pi/3); sin(2*pi*freq.*t - 2*pi/3)]';
a = exp(1j * 2 * pi / 3);
Abc2Pn0Mat = (1/3) .* [1  a  a^2; 1  a^2  a; 1  1  1];



Fs = 1e4;  % sampling freq
T = 1/Fs;	% sampling period
Tspan = 10;  % simulation frequency
L = Tspan * Fs;  % lenght of signal

t = (0:L-1)*T;  % time vector;

Pos50Hz = PosThreePhaseGen(1, 50, t);
Neg58Hz = NegThreePhaseGen(0.5, 58, t);
SigSum = Pos50Hz;

SigPN0 = Abc2Pn0Mat * SigSum';
SigPN0 = SigPN0';


[fx, mx, ax] = fft_simple(Pos50Hz(:, 1) + Neg58Hz(:, 1), Fs, Tspan);
plot(fx, mx, 'linewidth', 1.8)
grid on
axis([0, 100, -0.1, 1.2])
