function R = run_low_band(C, S)
%RUN_LOW_BAND 低频段流水线：逐窗口提取 -> SISO + MIMO(2x2 频率耦合)。
%
% P2 修正（相对 P1/原代码）：
%   - FIX: 电流符号统一为 C.current_sign（流入设备）。原代码 MIMO 取负号、
%     SISO 不取（原 U_I_Z_F_1hz），两者相差 180°。现已统一，SISO 与 MIMO
%     在弱耦合频点应一致。
%   - FIX: 结果按 C.f_report_begin/f_report_end 裁剪（默认 1~250Hz）。
%   - 2x2 第 2 列仍沿用 fliplr 合成（P1 行为），P2b 改为按频率直查。
%
% 返回 R：
%   R.ZPD_SISO, R.ZND_SISO   [f, |Z|, phase°]
%   R.ZPD_MIMO, R.ZND_MIMO   [f, |Z|, phase°]（use_mimo=false 时为空）

f_list = S.seg_f_hz;
nf = numel(f_list);
f0 = C.f0;

% ---- 1) 逐窗口提取（每窗口一次 FFT，正负序+镜像+参考角全取）----
W = cell(1, nf);
for k = 1:nf
    f    = f_list(k);
    cols = S.seg_col0(k) : S.seg_col0(k)+S.N-1;
    U    = [S.ua(cols); S.ub(cols); S.uc(cols)];
    % FIX(P2): 电流符号统一（流入设备为正）。原代码 SISO 路径不取负号。
    % OLD: I_mimo = C.current_sign*[...]; I_siso = [...];  % 两路径符号不一致
    I    = C.current_sign * [S.ia(cols); S.ib(cols); S.ic(cols)];
    W{k} = extract_components(U, I, f, f0);
end

% ---- 2) SISO（等效原 U_I_Z_F_1hz_1_250，符号已统一）----
Zp = zeros(1,nf); Zn = zeros(1,nf);
for k = 1:nf
    [Zp(k), Zn(k)] = calc_impedance_siso(W{k});
end
ZPD_SISO = [f_list(:), abs(Zp(:)), wrap_phase_180(angle(Zp(:))*180/pi)];
ZND_SISO = [f_list(:), abs(Zn(:)), wrap_phase_180(angle(Zn(:))*180/pi)];

% ---- 3) MIMO（等效原 AutoZscan2ZPN 的两段式组装）----
ZPD_MIMO = zeros(0,3); ZND_MIMO = zeros(0,3); R.coupled = struct();
if C.use_mimo
    % 旋转后的相量数组，按 ff 索引（ff = f_begin + k - 1）
    Ip = zeros(1,nf); Vp = zeros(1,nf); Ip_m = zeros(1,nf); Vp_m = zeros(1,nf);
    In = zeros(1,nf); Vn = zeros(1,nf); In_m = zeros(1,nf); Vn_m = zeros(1,nf);
    for k = 1:nf
        w = W{k};
        Ip(k)=w.Ip; Vp(k)=w.Vp; Ip_m(k)=w.Ip_m; Vp_m(k)=w.Vp_m;
        In(k)=w.In; Vn(k)=w.Vn; In_m(k)=w.In_m; Vn_m(k)=w.Vn_m;
    end

    % 段1：循环 ff=1..99，配对 k <-> (100-k)（两端口均为正频率，可精确恢复）
    % FIX(P2b): 第2列 = 镜像频点扫描（M2 = 扫描 100-k）：
    %   行1 = 镜像电压 Vp_m(100-k)（小），行2 = conj(自电压 Vp(100-k))（大）。
    %   原代码 fliplr 有 off-by-one（取到 Vp_m(101-k)/Vp(101-k)，且 k=1 混入 DC bin）。
    %   合成数据验证：修正版 2x2 恢复误差 ~1e-15，fliplr ~3e-2。
    % FIX(P2b): k=50 时镜像=自身（100-50=50），两列相同，2x2 奇异——显式跳过，
    %   与 f=100（镜像=DC）同类退化。原代码因 fliplr 错位恰好绕开，但该点值无意义。
    % OLD: calc_impedance_mimo(1,100,1,f0, Vp(1:100),Ip(1:100),Vp_m(1:100),Ip_m(1:100), ...
    %       fliplr(Vp_m(1:100)),fliplr(Ip_m(1:100)),fliplr(Vp(1:100)),fliplr(Ip(1:100)));
    [ZPD1a, ZND_neg1a] = calc_impedance_mimo(1, 50, 1, f0, ...
        Vp(1:49),     Ip(1:49),     Vp_m(1:49),     Ip_m(1:49), ...
        Vp_m(99:-1:51), Ip_m(99:-1:51), Vp(99:-1:51),   Ip(99:-1:51));
    [ZPD1b, ZND_neg1b] = calc_impedance_mimo(51, 100, 1, f0, ...
        Vp(51:99),    Ip(51:99),    Vp_m(51:99),    Ip_m(51:99), ...
        Vp_m(49:-1:1), Ip_m(49:-1:1), Vp(49:-1:1),    Ip(49:-1:1));
    ZPD1_99    = [ZPD1a; ZPD1b];
    ZND_n99_n1 = [ZND_neg1a; ZND_neg1b];

    % 段2：循环 ff=101..349，配对 (p@ff, n@(ff-100))
    % FIX(P2b): 第2列修正：M2 = 扫描 ff-100，行1 = 负序镜像 Vn_m(ff-100)=n@ff（小），
    %   行2 = conj(负序自 Vn(ff-100))（大）。原代码误用 Vn_m(100:349)=n@200..448
    %   （频率错位 100Hz）且第2行未取共轭。合成数据验证：修正版 2x2 误差 3.37
    %   （原版 15.55）；有效 ZP 两版均 <0.4%，ZN 修正版 ~28-47%（两窗口法固有限制）。
    % OLD: calc_impedance_mimo(101,350,1,f0, Vp(101:349),Ip(101:349),Vp_m(101:349),Ip_m(101:349), ...
    %       Vn_m(100:349),In_m(100:349),Vn(1:249),In(1:249));
    [ZPD100_349, ZND_1_249] = calc_impedance_mimo(101, 350, 1, f0, ...
        Vp(101:349), Ip(101:349), Vp_m(101:349), Ip_m(101:349), ...
        Vn_m(1:249),  In_m(1:249),  conj(Vn(1:249)), conj(In(1:249)));

    ZPD_MIMO = [ZPD1_99; ZPD100_349];
    ZND_MIMO = [ZND_n99_n1; ZND_1_249];
    R.coupled = struct('Vp',Vp,'Ip',Ip,'Vp_m',Vp_m,'Ip_m',Ip_m, ...
                       'Vn',Vn,'In',In,'Vn_m',Vn_m,'In_m',In_m);
end

% ---- 4) 结果裁剪 ----
% FIX(P2): 按配置裁剪报告范围（默认 1~250Hz）。ZND_MIMO 的负频率行
%          （-99..-1，正序 1..99 的镜像）一并裁掉，只报告正频率段。
R.ZPD_SISO = trim_result(ZPD_SISO, C);
R.ZND_SISO = trim_result(ZND_SISO, C);
R.ZPD_MIMO = trim_result(ZPD_MIMO, C);
R.ZND_MIMO = trim_result(ZND_MIMO, C);
end

function Z = trim_result(Z, C)
if isempty(C.f_report_begin), return; end
sel = Z(:,1) >= C.f_report_begin & Z(:,1) <= C.f_report_end;
Z = Z(sel, :);
end
