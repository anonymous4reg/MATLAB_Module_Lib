# 阻抗扫频计算工程（重构版）

读取电力电子设备（SVG/风机/光伏等）PCC 点三相电压电流录波数据，在考虑**频率耦合**的情况下
计算正/负序阻抗。基频 50Hz，扫频注入 1~350Hz（1Hz 步长）与 250~2500Hz（10Hz 步长），
每频点注入 1 秒。

> 原代码已归档在 `original/`（GBK 编码，仅做路径分隔符适配后可运行）。
> 重构历程与基线对比见 `_baseline_data/BASELINE_REPORT.md`。

## 目录结构

```
config/   impedance_scan_config.m      配置（注入范围/报告范围/电流符号等）
io/       load_scan_recording.m        读 .mat -> ScanRecording（频点->窗口映射）
          save_impedance_results.m     保存 .mat + 出图（唯一绘图处）
core/     extract_components.m         单窗口 FFT + 正负序 + 镜像 + 参考角（唯一提取点）
          seq_transform.m              abc -> 正/负序
          calc_impedance_siso.m        Z = V/I（无耦合）
          calc_impedance_mimo.m        2x2 频率耦合矩阵 + Schur 补
          wrap_phase_180.m             相位折算
pipeline/ run_low_band.m               低频：SISO + MIMO，报告 1~250Hz
          run_high_band.m              高频：SISO，报告 250~2500Hz
scripts/  run_all_cases.m              入口脚本
tests/    test_regression.m            P2 一致性测试
          test_p1_regression.m         P1 golden 回归测试（行为=原代码）
          test_mimo_recovery.m         合成数据验证 2x2 组装
original/ 原代码（未修改）
```

## 运行方法

### 批量处理（推荐）

```matlab
run_all_cases()                                   % 处理默认根目录下所有工况
run_all_cases('/path/to/data')                    % 指定数据根目录
run_all_cases('/path/to/data', {'Q1.0'})          % 只处理指定工况（按文件夹名）
```

数据根目录下每个子文件夹为一个工况，内含 `Lfile*.mat`（低频 10kHz）与 `Hfile*.mat`
（高频 50kHz），**文件名后缀不限**（`Lfile_1`/`Lfile_7` 均可，自动发现配对；
同文件夹多个文件按后缀配对，如 `Lfile_5` <-> `Hfile_5`）。

每个工况的输出（写入工况文件夹下）：

```
<工况>/
├── 1-250Hz/      低频：DATA_ZPD_SISO.mat / DATA_ZND_SISO.mat
│                 DATA_ZPD_MIMO.mat / DATA_ZND_MIMO.mat（含耦合）+ 图
├── 250-2500Hz/   高频：DATA_ZPD.mat / DATA_ZND.mat（SISO）+ 图
└── 1-2500Hz/     合并：DATA_ZPD.mat / DATA_ZND.mat
                  = 低频 MIMO(1~249Hz，50/100Hz 洞位用 SISO 填) + 高频 SISO(250~2500Hz)
```

采样率自动核对（从数据行1检测，与配置不符会警告）；频段/采样率默认
低频 1~349Hz 注入@1Hz、报告 1~250Hz、10kHz；高频 250~2500Hz@10Hz、50kHz，
可在 `run_all_cases.m` 的 `cfg` 处调整。

> 图形开关：`run_all_cases(..., save_figs)` 默认 true。MATLAB -batch 无头模式下
> 图形渲染偶发死锁，脚本/批量场景建议 `run_all_cases(root, {}, false)`（.mat 不受影响，
> 全 3 工况约 10~30 秒）；交互式 MATLAB 中可开 true。图已用 painters 渲染器加固。

### 单工况调试

```matlab
C1 = impedance_scan_config();
S1 = load_scan_recording('Lfile_1.mat', C1.sample_time_us, C1.f_begin, C1.f_end, C1.f_step);
R1 = run_low_band(C1, S1);          % R1.ZPD_SISO / R1.ZPD_MIMO ...
save_impedance_results(R1, 'out/low', 'low');
```

## 录波数据格式（重要）

- `.mat` 内为**单一矩阵变量**（行 x 列），本工程读取行 3-8：
  - 行1：仿真时间（秒，仅原代码注释掉的绘图使用）
  - 行2：50kHz 主时钟 tick（未使用）
  - 行3-5：UA/UB/UC；行6-8：IA/IB/IC
- 每频点连续录 1 秒：采样数 = 1e6/步长(us)（低频 10kHz -> 1 万点，高频 50kHz -> 5 万点），
  按频率升序拼接。
- 每频点同时注入**正序与负序**电压扰动（幅值相同）。

## 核心方法

1. **逐频点提取**：每 1 秒窗口 FFT（分辨率 1Hz，注入频率为整数，bin 精确对齐），
   单边幅值谱 ×2，提取正/负序在 `f`、镜像 `2f0-f`（正序）与 `2f0+f`（负序）处的复相量，
   并以基波正序电压相角为参考旋转（dq 同步）。
2. **SISO**：Zp = Vp/Ip、Zn = Vn/In（忽略耦合）。
3. **MIMO（低频段，考虑耦合）**：每频点 f 组 2x2 矩阵
   `[Vp(f); conj(Vp(2f0-f))] = Z·[Ip(f); conj(Ip(2f0-f))]`，
   两列来自 f 与镜像频点的两次扫描；有效阻抗用 Schur 补
   `ZP = Z11 - Z12*Z21/Z22`、`ZN = Z22 - Z12*Z21/Z11`。
   - 段1（f=1..99）：镜像为正频率，2x2 可精确恢复（合成数据验证 ~1e-15）。
   - 段2（f=101..349）：镜像为负频率，等效为正序 f ↔ 负序 f-100 配对；
     两窗口法存在固有近似（合成数据：有效 ZP 误差 <0.4%，ZN ~28-47%）。
   - f=50（镜像=自身）与 f=100（镜像=DC）为退化点，MIMO 不输出（报告范围留洞）。
4. **结果**：低频报告 1~250Hz（MIMO 缺 50/100Hz），高频报告 250~2500Hz（10Hz 步长）。

## 输出

- `DATA_ZPD.mat / DATA_ZND.mat`：三列 `[f_hz, |Z|Ω, phase°]`
- `DATA_ZPD.fig/png、DATA_ZND.fig/png`：幅值(dB)+相角(deg) 双子图
- 低频附带中间量 `Vp_coupled1-4.mat / Ip_coupled1-4.mat`

## 与重构前的差异（均有 FIX/OLD 注释标记）

| 项目 | 原代码 | 重构后 |
|---|---|---|
| 电流符号 | MIMO/高频取负号，低频 SISO 不取（相差 180°） | 统一取负号（流入设备） |
| MIMO 段1 第2列 | fliplr（off-by-one，k=1 混入 DC bin） | 按镜像频点索引直取（精确） |
| MIMO 段2 第2列 | 误用 n@200..448Hz（频率错位 100Hz） | n@(f-100) 正确映射 + 共轭 |
| f=50 MIMO | fliplr 错位侥幸给出值（无意义） | 显式跳过（退化点） |
| 高频段 250~340Hz | 被 `ZP(11:end)` 丢弃 | 保留 250~2500Hz 全部 |
| 低频结果范围 | 输出到 349Hz | 报告 1~250Hz（注入仍到 349Hz 供耦合） |
| Vp0 参考角 | 误用电流幅值×电压相位 | 改用电压幅值 |

## 测试

```matlab
addpath('tests');   % 或直接 run
test_regression()       % P2 一致性（范围/无 NaN/SISO-MIMO 弱耦合一致）
test_p1_regression()    % P1 golden 对比（重构前行为，P2 后预期部分失败）
test_mimo_recovery()    % 合成数据验证 2x2 组装（段1 精确、段2 报告近似误差）
```

## 已知限制

- **f=50Hz 不可靠**：基波处"扰动"与运行点不可分，SISO/MIMO 在该点均有深谷；
- **低频段 MIMO 负序（ZN）**：段2 两窗口法固有近似（见上表），建议结合实测或
  其他方法交叉验证；
- **设备并联谐振**：本数据在 p@350Hz（≈335Ω）与 n@250Hz（≈90-110Ω）存在真实谐振
  （镜像对），非测量伪影。
