function R = run_high_band(C, S)
%RUN_HIGH_BAND 高频段流水线：逐窗口提取 -> SISO 正/负序阻抗（10Hz 步长）。
%
% 复现原代码行为（P1 机械重构，数学零改动）：
%   - 电流取负号（原 U_I_Z_F_10hz_250_2500 L37-39）
%   - 不旋转、不折算相位（原 L179-180 直接 angle*180/pi）
%   - P1 保留原 ZP(11:end) 丢弃 250~340Hz；P2 按用户确认改为保留全部
%
% 返回 R.ZPD, R.ZND：[f, |Z|, phase°]

f_list = S.seg_f_hz;
nf = numel(f_list);
f0 = C.f0;

ZP = zeros(nf,3); ZN = zeros(nf,3);
for k = 1:nf
    f    = f_list(k);
    cols = S.seg_col0(k) : S.seg_col0(k)+S.N-1;
    U    = [S.ua(cols); S.ub(cols); S.uc(cols)];
    I    = C.current_sign * [S.ia(cols); S.ib(cols); S.ic(cols)];  % 与原代码负号一致
    W    = extract_components(U, I, f, f0);
    [Zp, Zn] = calc_impedance_siso(W);
    ZP(k,:) = [f, abs(Zp), angle(Zp)*180/pi];   % 原代码不折算相位
    ZN(k,:) = [f, abs(Zn), angle(Zn)*180/pi];
end

% FIX(P2): 保留 250~2500Hz 全部结果（用户已确认）。
% OLD: R.ZPD = ZP(11:end,:); R.ZND = ZN(11:end,:);  % 原代码丢弃 250~340Hz
R.ZPD = ZP;
R.ZND = ZN;
end
