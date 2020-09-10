clear;clc
% User input zone: 10% Ҫд�� 0.1
RatedCapacity = 3e6; % VA
RatedVoltage = 37e3; % Volt
ShortCircuitImpedancePer = 0.07; % ��·�迹�ٷֱ�
FullLoadLoss = 32.5e3; % ������� Watte
NoLoadCurrentPer = 0.003; % ���ص����ٷֱ�
NoLoadLoss = 3.15e3; % ������� Watte
Freq = 50;
Omega = 2*pi*Freq;


UBase = RatedVoltage / sqrt(3);  % Volt
IBase = RatedCapacity / UBase / 3;  % Amp
ZBase = UBase / IBase;  % Ohm

R12pu = FullLoadLoss / RatedCapacity; % yes
X12pu = ShortCircuitImpedancePer;

R1pu = R12pu / 2
X1pu = X12pu / 2
R2pu = R12pu / 2
X2pu = X12pu / 2

% L1pu = X1pu / Omega
% L2pu = X2pu / Omega

Rm_pu = RatedCapacity / ( NoLoadLoss)
Xm_pu = 1/NoLoadCurrentPer

% Lm_pu = Xm_pu / Omega


