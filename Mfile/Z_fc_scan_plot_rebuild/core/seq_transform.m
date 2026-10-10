function [Vp, Vn] = seq_transform(Va, Vb, Vc)
%SEQ_TRANSFORM 三相相量 -> 正序/负序（对称分量法）。
%   Vp = (Va + a*Vb + a^2*Vc)/3，Vn = (Va + a^2*Vb + a*Vc)/3，a = exp(j*2*pi/3)。
% 与原代码内联公式完全一致，仅收敛到一处（全工程唯一正负序变换点）。

a  = exp(1i*2*pi/3);
Vp = (Va + a*Vb + a^2*Vc)/3;
Vn = (Va + a^2*Vb + a*Vc)/3;
end
