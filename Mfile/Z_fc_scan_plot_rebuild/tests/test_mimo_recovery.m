function test_mimo_recovery()
%TEST_MIMO_RECOVERY 相位级合成数据验证 2x2 频率耦合阻抗的组装正确性（P2b）。
%
% 设备模型：dq 不对称阻抗（转换器典型结构，Sun Jian 序列阻抗理论）
%   Zd(nu) = Rd + j*2*pi*nu*Ld,  Zq(nu) = Rq + j*2*pi*nu*Lq,  nu = f - f0
%   abc 正序 2x2（对 f 与镜像 2f0-f 的配对）：
%     Z11 = (Zd+Zq)/2, Z12 = (Zd-Zq)/2, Z21 = (Zd-Zq)/2, Z22 = (Zd+Zq)/2
%   该模型满足 LTP 一致性：Z11(50+δ)=conj(Z11(50-δ))，Z12(50+δ)=conj(Z12(50-δ))
%
% 生成"测量"相量（含源阻抗 Zsrc，镜像电压 = -Zsrc*I_mirror，与真实录波结构一致：
% 镜像电压极小、镜像电流显著），按 extract_components 的约定组织数组，
% 分别用不同装配恢复 2x2，与理论 Z2x2(f) 对比。
%
% 输出各频点的恢复误差 |Z_est - Z_true|，段1 应精确、段2 报告各候选装配误差。

f0 = 50; f_begin = 1; f_end = 349; f_step = 1;
f_list = f_begin:f_step:f_end;
nf = numel(f_list);

% ---- 设备参数 ----
Rd = 5; Ld = 4e-3; Rq = 8; Lq = 6e-3;   % dq 不对称（含耦合）
V_inj = 300; Vn_inj = 300;              % 正/负序注入电压幅值
Zsrc = 0.5;                             % 源阻抗（使镜像电压非零）

Zt = @(f) [ (Rd+Rq + 1i*2*pi*(f-f0)*(Ld+Lq))/2 , (Rd-Rq + 1i*2*pi*(f-f0)*(Ld-Lq))/2 ;
            (Rd-Rq + 1i*2*pi*(f-f0)*(Ld-Lq))/2 , (Rd+Rq + 1i*2*pi*(f-f0)*(Ld+Lq))/2 ];

% ---- 按模型生成测量相量（extract_components 约定）----
Vp=zeros(1,nf); Ip=zeros(1,nf); Vp_m=zeros(1,nf); Ip_m=zeros(1,nf);
Vn=zeros(1,nf); In=zeros(1,nf); Vn_m=zeros(1,nf); In_m=zeros(1,nf);
for k = 1:nf
    ff = f_list(k);
    Z = Zt(ff);
    % 正序子系统 @ff：x = [Ip(ff); conj(Ip(2f0-ff))]
    x = inv(Z + Zsrc*eye(2)) * [V_inj; 0];
    Ip(k)  = x(1);
    Vp(k)  = V_inj - Zsrc*x(1);
    Ip_m(k)= conj(x(2));                       % 镜像电流（提取器约定）
    Vp_m(k)= -Zsrc*conj(x(2));                 % 镜像电压 = -Zsrc*I_mirror（提取器约定）
    % 负序子系统 @ff：y = [In(ff); conj(In(2f0+ff))]
    y = inv(Z + Zsrc*eye(2)) * [Vn_inj; 0];
    In(k)  = y(1);
    Vn(k)  = Vn_inj - Zsrc*y(1);
    In_m(k)= conj(y(2));
    Vn_m(k)= -Zsrc*conj(y(2));
end

% ---- 装配候选 ----
% 段1（ff=1..99，配对 k <-> 100-k）
%   A1: fliplr（原代码，off-by-one：col2 = [Vp_m(101-k); conj(Vp(101-k))]）
%   B1: P2b 修正：col2 = [Vp_m(100-k); conj(Vp(100-k))]（镜像阵列倒序 + 主阵列倒序）
%       即 M2(扫描 100-k)：行1 = 镜像电压(小)，行2 = conj(自电压(大))
A1 = assemble(1, 100, f0, Vp(1:100),   Ip(1:100),   Vp_m(1:100),   Ip_m(1:100), ...
                       fliplr(Vp_m(1:100)), fliplr(Ip_m(1:100)), fliplr(Vp(1:100)), fliplr(Ip(1:100)));
B1 = assemble(1, 100, f0, Vp(1:99),    Ip(1:99),    Vp_m(1:99),    Ip_m(1:99), ...
                       Vp_m(99:-1:1),  Ip_m(99:-1:1), Vp(99:-1:1),  Ip(99:-1:1));
% 段2（ff=101..349，配对 ff <-> (ff-100) 负序侧）
%   A2: 原代码（Vn_m(100:349) = n@200..448 频率错误；Vn(1:249) 未取共轭）
%   B2: P2b 修正：col2 = [Vn_m(ff-100) 镜像; conj(Vn(ff-100)) 自] = [Vn_m(1:249); conj(Vn(1:249))]
A2 = assemble(101, 350, f0, Vp(101:349), Ip(101:349), Vp_m(101:349), Ip_m(101:349), ...
                        Vn_m(100:349), In_m(100:349), Vn(1:249),     In(1:249));
B2 = assemble(101, 350, f0, Vp(101:349), Ip(101:349), Vp_m(101:349), Ip_m(101:349), ...
                        Vn_m(1:249),   In_m(1:249),   conj(Vn(1:249)), conj(In(1:249)));

% ---- 对比 ----
fprintf('段1（ff=1..99，理论 Z2x2 已知）:\n');
fprintf('  f    |A1-Z|      |B1-Z|\n');
e1a=0; e1b=0;
for k = 1:99
    ff = k; Z = Zt(ff);
    e1a = max(e1a, max(abs(A1(:,:,k) - Z), [], 'all'));
    e1b = max(e1b, max(abs(B1(:,:,k) - Z), [], 'all'));
end
fprintf('  最大误差: A1(fliplr)=%.4e   B1(索引直换)=%.4e\n', e1a, e1b);

fprintf('段2（ff=101..349）:\n');
e2a=0; e2b=0; w2a=0; w2b=0;
for k = 1:249
    ff = 100+k; Z = Zt(ff);
    ea = max(abs(A2(:,:,k) - Z), [], 'all');
    eb = max(abs(B2(:,:,k) - Z), [], 'all');
    if ea > e2a, e2a = ea; w2a = ff; end
    if eb > e2b, e2b = eb; w2b = ff; end
end
fprintf('  最大误差: A2(原代码)=%.4e @%gHz   B2(修正)=%.4e @%gHz\n', e2a, w2a, e2b, w2b);

% 段1 断言：索引直换应精确恢复（模型一致性条件成立）
assert(e1b < 1e-6, 'test_mimo_recovery: 段1 索引直换恢复误差过大 %.3e', e1b);

% ---- 段2 有效阻抗（管线实际输出 ZP/ZN）误差评估 ----
% ZP = Z11 - Z12*Z21/Z22, ZN = Z22 - Z12*Z21/Z11
fprintf('段2 有效阻抗误差（相对 Zt 的有效阻抗）:\n');
fprintf('  f    A2_ZP_err  B2_ZP_err  A2_ZN_err  B2_ZN_err   (相对 %%)\n');
for k = [1 50 100 150 200 249]
    ff = 100+k; Z = Zt(ff);
    ZP_true = Z(1,1) - Z(1,2)*Z(2,1)/Z(2,2);
    ZN_true = Z(2,2) - Z(1,2)*Z(2,1)/Z(1,1);
    eff = @(M) [M(1,1)-M(1,2)*M(2,1)/M(2,2), M(2,2)-M(1,2)*M(2,1)/M(1,1)];
    eA = abs(eff(A2(:,:,k)) - [ZP_true ZN_true]) ./ abs([ZP_true ZN_true]);
    eB = abs(eff(B2(:,:,k)) - [ZP_true ZN_true]) ./ abs([ZP_true ZN_true]);
    fprintf('%4d  %8.2f%%  %8.2f%%  %8.2f%%  %8.2f%%\n', ff, eA(1)*100, eB(1)*100, eA(2)*100, eB(2)*100);
end
fprintf('TEST_MIMO_RECOVERY PASS (段1 精确；段2 误差如上，供评估)\n');
end

function Z = assemble(f_begin, f_end_plus1, f0, Vp1, Ip1, Vp_m1, Ip_m1, Vp2, Ip2, Vp_m2, Ip_m2)
% 与 calc_impedance_mimo 相同的组装，但返回完整 2x2（按 ff 索引）
f_list = f_begin : f_end_plus1-1;
Z = zeros(2,2,numel(f_list));
for k = 1:numel(f_list)
    Z(:,:,k) = [Vp1(k), Vp2(k); conj(Vp_m1(k)), conj(Vp_m2(k))] * ...
               inv([Ip1(k), Ip2(k); conj(Ip_m1(k)), conj(Ip_m2(k))]);
end
end
