clear;clc
Uline = 37e3;
Sn = 4.2e6;
% In = Sn / Uline / sqrt(3)

k_scr = 4

Zn = Uline^2 / Sn


Zsc = Zn / k_scr

Rt = 1.36
Lt = 0.3070856
Zt = sqrt(Rt^2 + (2*50*pi*Lt)^2)

k_fix = Zsc / Zt;
Rt * k_fix
Lt * k_fix
