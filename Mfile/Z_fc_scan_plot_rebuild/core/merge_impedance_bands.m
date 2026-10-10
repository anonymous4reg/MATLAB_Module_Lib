function M = merge_impedance_bands(R_low, R_high)
%MERGE_IMPEDANCE_BANDS 合并低频与高频结果，生成 1~2500Hz 连续曲线。
%
% 规则（用户确认）：
%   - 正/负序均取：低频 MIMO（f < 高频起始频率）+ 高频 SISO（f >= 高频起始频率）
%   - 低频 MIMO 缺失的频点（f=50/100 等镜像退化点）用低频 SISO 值填充
%   - 低频未开 MIMO 时退回低频 SISO
%
% 返回 M.ZPD / M.ZND：[f_hz, |Z|, phase°]，按频率升序，无 NaN。

f_hi0 = R_high.ZPD(1,1);   % 高频起始频率（如 250Hz）

if isempty(R_low.ZPD_MIMO)
    zp_low = R_low.ZPD_SISO;
    zn_low = R_low.ZND_SISO;
else
    zp_low = fill_holes(R_low.ZPD_MIMO, R_low.ZPD_SISO, f_hi0);
    zn_low = fill_holes(R_low.ZND_MIMO, R_low.ZND_SISO, f_hi0);
end
zp_low = zp_low(zp_low(:,1) < f_hi0, :);
zn_low = zn_low(zn_low(:,1) < f_hi0, :);

M.ZPD = [zp_low; R_high.ZPD];
M.ZND = [zn_low; R_high.ZND];
end

function Z = fill_holes(Z_mimo, Z_siso, f_hi0)
% 用 SISO 填充 MIMO 在报告范围内缺失的频点，再按频率升序
f_target = Z_siso(:,1);
f_target = f_target(f_target < f_hi0);
have = ismember(f_target, Z_mimo(:,1));
missing = f_target(~have);
if ~isempty(missing)
    siso_map = containers.Map(Z_siso(:,1), 1:size(Z_siso,1));
    for m = missing(:)'
        Z_mimo(end+1,:) = Z_siso(siso_map(m),:); %#ok<AGROW>
    end
end
Z = sortrows(Z_mimo);
end
