function [Zp, Zn] = calc_impedance_siso(W)
%CALC_IMPEDANCE_SISO 单频点 SISO 正/负序阻抗（不考虑频率耦合）。
%   Zp = Vp/Ip，Zn = Vn/In，使用未旋转（原始）相量——旋转在比值中抵消，
%   与原代码 U_I_Z_F_* 的 Z=V/I 完全一致。
%
% 电流符号（流入设备方向）由调用方在送入 extract_components 前应用，
% 本函数不感知符号约定（重构要点：符号与数学解耦）。

Zp = W.Vp_raw ./ W.Ip_raw;
Zn = W.Vn_raw ./ W.In_raw;
end
