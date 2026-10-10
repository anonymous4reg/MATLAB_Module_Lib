function ph = wrap_phase_180(ph)
%WRAP_PHASE_180 把相角折算到 [-180, 180] 度。
% 原代码 f_phase_round_180.m 的等价实现（仅做一次 ±360 平移，与原来一致）。

sel1 = ph >  180;
sel2 = ph < -180;
ph = (ph - 360).*sel1 + (ph + 360).*sel2 + ph.*(~sel1).*(~sel2);
end
