function [ZP3, ZN3] = calc_impedance_mimo(f_begin, f_end_plus1, f_step, f0, ...
    Vp1, Ip1, Vp_m1, Ip_m1, Vp2, Ip2, Vp_m2, Ip_m2)
%CALC_IMPEDANCE_MIMO 组装 2x2 频率耦合阻抗矩阵并提取等效 Zp/Zn。
%
% 数学模型（每频点 ff，端口1=ff，端口2=镜像频点）：
%   [Vp(ff)          ]   [Z11 Z12] [Ip(ff)          ]
%   [conj(Vp_m(ff))  ] = [Z21 Z22] [conj(Ip_m(ff))  ]
%   第1列 = 扫描 ff 的测量；第2列 = 扫描镜像频点的测量（由调用方提供）
%   Z = V * inv(I)；等效阻抗（Schur 补）：
%   ZP = Z11 - Z12*Z21/Z22（端口1 处含耦合的等效输入阻抗）
%   ZN = Z22 - Z12*Z21/Z11（端口2 处等效阻抗，输出频率标注为 ff-2*f0）
%
% 参数（与原 ScanImpedance2plusV5 完全一致）：
%   f_begin, f_end_plus1  循环 ff = f_begin:f_step:(f_end_plus1-1)
%   各数组按索引 k = (ff-f_begin)/f_step + 1 取值
%
% 输出 [f, |Z|, phase°] 三列格式（相位折算 ±180），与原代码一致。

f_start = f_begin;
f_end   = f_end_plus1 - 1;
f_num   = (f_end - f_start)/f_step + 1;

ZP3 = zeros(f_num, 3);
ZN3 = zeros(f_num, 3);

for ff = f_start : f_step : f_end
    k = (ff - f_start)/f_step + 1;

    Z2 = [Vp1(k), Vp2(k); conj(Vp_m1(k)), conj(Vp_m2(k))] * ...
         inv([Ip1(k), Ip2(k); conj(Ip_m1(k)), conj(Ip_m2(k))]);

    ZP = Z2(1,1) - Z2(1,2)*Z2(2,1)/Z2(2,2);
    ZN = Z2(2,2) - Z2(1,2)*Z2(2,1)/Z2(1,1);

    ZP3(k,:) = [ff, abs(ZP), wrap_phase_180(angle(ZP)*180/pi)];
    ZN3(k,:) = [ff - 2*f0, abs(ZN), wrap_phase_180(angle(ZN)*180/pi)];
end
end
