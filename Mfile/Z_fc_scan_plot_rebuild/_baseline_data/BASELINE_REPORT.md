# P0 Baseline Report — 原代码基线（golden）

生成日期：2026-09-01
数据：`/Users/ym/Downloads/siyuan_svg_56Mvar/Q1.0/Lfile_1.mat`, `Hfile_1.mat`
运行方式：MATLAB R2024a batch，使用 `/tmp/zscan_baseline/` 下原代码的 UTF-8 副本，
仅做**路径分隔符适配**（Windows `\` → `/`，仅字符串字面量），数学逻辑零改动。

## 1. 数据格式实测结论

- 两个 .mat 均为 **MAT v4**（20 字节头：type=0, rows=8, 单变量矩阵，变量名 `Lscan_1`/`Hscan_1`），
  与代码 `cell2mat(struct2cell(load(...)))` 的前提（单矩阵变量）兼容。
- 行布局（1-based）：行1 = 仿真时间（秒，Lfile 从 891.4s 起，Hfile 从 1661.4s 起——两次独立运行）；
  行2 = 50kHz 主时钟 tick（Lfile 10kHz 采样每点 +5，Hfile 50kHz 每点 +1）；
  行3-5 = UA/UB/UC；行6-8 = IA/IB/IC。**代码只读行1（仅注释掉的绘图用）与行3-8，行2忽略**。
- 分段：Lfile = 350 段 × 10000 点（10kHz，1~350Hz @1Hz）；Hfile = 226 段 × 50000 点（50kHz，250~2500Hz @10Hz）。
  每段 1 秒 → FFT 分辨率 1Hz，注入频率全为整数 → bin 精确对齐。

## 2. 原代码运行结果（golden 文件）

`_baseline_data/golden_outputs.mat`：retZPDSISO / retZNDSISO / retZPDMIMO / retZNDMIMO / retZPD / retZND
（格式均为 [f_hz, |Z|Ω, phase°]），另有每工况输出目录：
- `1-250Hz/Lfile_1/`：DATA_ZPD.mat、DATA_ZND.mat（MIMO）+ fig/png + Vp_coupled1-4、Ip_coupled1-4
- `250-2500Hz/Hfile_1/`：DATA_ZPD.mat、DATA_ZND.mat（SISO）+ fig/png
- 6 条曲线 CSV 导出：`retZ*.csv`

| 曲线 | 点数 | 频率范围 | 说明 |
|---|---|---|---|
| ZPD_SISO | 349 | 1..349 | 低频无耦合正序 |
| ZND_SISO | 349 | 1..349 | 低频无耦合负序 |
| ZPD_MIMO | 348 | 1..99 ∪ 101..349 | 2×2 耦合正序，**缺 100Hz**（镜像=DC） |
| ZND_MIMO | 348 | -99..-1 ∪ 1..249 | 负序，第一段用负频率标注（正序镜像） |
| ZPD/ZND（高频） | 216 | 350..2500 | **250~340Hz 被 `ZP(11:end)` 丢弃** |

## 3. 关键观测（供重构参考）

1. **SISO 与 MIMO 相位差严格 180°**（除 f=50 外，幅值一致）：低频 SISO 未取电流负号，
   MIMO 路径（ScanImpedanceP/N）取了负号（I 反号）。坐实符号约定不一致。
2. **f=50 不可靠**：基波处"扰动"与运行点不可分，Zp 出现深谷（SISO 22Ω / MIMO 12.5Ω，邻点 ~90Ω）。
3. **真实并联谐振**：Zp@350Hz≈335.7Ω（正序电流响应仅为邻点 1/30）、Zn@250Hz≈90~110Ω（负序电流被抑制 10 倍，
   低频、高频两段录波一致）。二者互为镜像对（350 p ↔ 250 n）。
4. **MIMO f=1 无异常**：录波电流存在 ~60~100A DC 偏置（DC bin 非零，矩阵不奇异），
   且弱耦合下 Schur 补 ≈ SISO，fliplr 的 off-by-one 偏差被掩盖——但 2×2 组装在原理上仍应修正（P2）。
5. **Lfile 第 350 段（350Hz 注入）从未被代码读取**（Freq_end=350 → 循环到 349Hz）。
6. **结果范围缺口**：低频 MIMO/SISO 输出到 349Hz，但用户口径"最终结果 1~250Hz"；
   高频丢弃 250~340Hz → 若低频截到 250，合并曲线 250~349Hz 为盲区（P2 需定夺）。
