# 滑动窗 FFT 分析模板 — 使用手册

## 概述

本目录提供三套基于滑动窗 FFT 的电力系统数据分析模板，共享同一套底层架构（`f_sliding_window_generate` 生成滑动窗、`f_fft_simple` 做 FFT），分别面向不同的分析场景。

| 模板 | 用途 | 适用场景 |
|------|------|----------|
| `template_sliding_window_runner` | 通用骨架 | 快速搭建自定义滑动窗分析 |
| `template_sliding_window_runner_power_flow` | 正序功率计算 | 选定频率的 P/Q 时序分析 |
| `template_sliding_window_fft_spectrum` | 全频谱可视化 | 频谱随时间变化的 3D/瀑布图 |

---

## 共用架构

三个模板共享以下数据流：

```
CSV 加载 → 时间截取 → 通道提取 → 滑动窗生成 → 核心计算 → 可视化
```

### 滑动窗参数

窗的生成由三个参数控制，统一使用 `f_sliding_window_generate` 函数：

$$
N = \left\lfloor \frac{L - W}{\text{step}} \right\rfloor + 1
$$

| 参数 | 含义 | 单位 | 配置项 |
|------|------|------|--------|
| 窗长 `W` | 每个 FFT 窗包含的采样点数 | 采样点 | `cfg.t_span`（秒）× `cfg.sample_freq` |
| 步长 | 窗每次向前移动的距离 | 采样点 | `cfg.window_step` |
| 窗数 `N` | 自动从数据长度计算 | — | 无需手动指定 |
| 数据长度 `L` | 时间截取后的总采样点数 | 采样点 | 由 `cfg.t_start` / `cfg.t_end` 决定 |

### 频率分辨率

```
Δf = fs / window_width = 1 / t_span
```

- `t_span = 1 s` → Δf = 1 Hz，FFT bin 落在 0, 1, 2, … Hz
- `t_span = 10 s` → Δf = 0.1 Hz，bin 落在 0, 0.1, 0.2, … Hz

> **注意**：若目标频率不是 Δf 的整数倍，所选 bin 与真实频率存在偏差，会导致幅值振荡（scalloping loss）。详见 `doc_sliding_window_fft_sawtooth.md`。

---

## 1. template_sliding_window_runner — 通用骨架

### 用途

最简滑动窗框架，预置了数据加载和窗口循环，**核心计算和可视化留空**，适合快速搭建新的分析脚本。

### 配置参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `cfg.root_dir` | `'../data/'` | CSV 文件目录 |
| `cfg.file_name` | `'xxx.csv'` | CSV 文件名 |
| `cfg.sample_freq` | `1000` | 采样频率 (Hz) |
| `cfg.t_span` | `1` | 窗长时间 (s) |
| `cfg.t_start` | `0` | 数据截取起始 (s) |
| `cfg.t_end` | `60` | 数据截取结束 (s) |
| `cfg.uabc_idx_cell` | `{[1:3]}` | 电压通道索引（支持多组信号） |
| `cfg.iabc_idx_cell` | `{[1:3]+3}` | 电流通道索引 |
| `cfg.window_step` | `100` | 窗移动步长（采样点） |
| `cfg.which_freq` | `[44, 50, 56]` | 关注频率 (Hz)，与 `freq_limit` 二选一 |
| `cfg.freq_limit` | `[]` | 全频段上限 (Hz)，与 `which_freq` 二选一 |

### 循环结构

```matlab
for sig_idx = 1:n_signals
    for win_idx = 1:n_windows
        uabc_win = uabc_cell{sig_idx}(left:right, :);
        iabc_win = iabc_cell{sig_idx}(left:right, :);
        % TODO: 在此处添加你的计算逻辑
    end
end
```

每次迭代提供当前窗的三相电压 `uabc_win` 和电流 `iabc_win`（各 3 列）。

### 自定义方式

1. 在核心计算区（`%% 核心计算`）编写你的 FFT / 阻抗 / 功率计算
2. 在可视化区（`%% 可视化`）编写绘图逻辑
3. 如需支持 `uabc_idx` / `iabc_idx` 直接索引（非 cell 数组），可将通道提取替换为 `template_sliding_window_runner_power_flow` 的方式

---

## 2. template_sliding_window_runner_power_flow — 正序功率计算

### 用途

对每个滑动窗做三相 FFT → 序分量变换 → 提取指定频率的正序有功/无功功率，并绘制时序曲线。

### 线路配置

使用 `lines` cell 数组管理多条线路，通过 `line_sel` 一键切换：

```matlab
lines = {
    '线路名', '母线', U列范围, I列范围, 'CSV文件名', 起始秒;
    ...
};
line_sel = 1;  % 改此数字切换线路
```

各字段自动派生 `cfg.file_name`、`cfg.t_start`、`uabc_idx`、`iabc_idx`。

### 独有配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `line_sel` | `1` | 选择第几条线路 |
| `cfg.which_freq` | `[26.6, 50, 73.5]` | 提取功率的目标频率 (Hz) |

### 计算流程

```
每窗: uabc_win, iabc_win
  → f_fft_simple (三相分别)
  → 相角修正 (+π/2, cosine→sine)
  → f_seqconv (ABC→正负零序)
  → 选定频率 bin → 正序 P = 1.5·Up·Ip·cos(θu−θi)
                   正序 Q = 1.5·Up·Ip·sin(θu−θi)
```

### 输出变量

| 变量 | 维度 | 内容 |
|------|------|------|
| `win_center_t` | `n_windows × 1` | 每个窗的中心时刻 (s) |
| `P_mat` | `n_windows × n_freq` | 正序有功功率 (MW) |
| `Q_mat` | `n_windows × n_freq` | 正序无功功率 (Mvar) |
| `Up_mag_mat` | `n_windows × n_freq` | 正序电压幅值 (kV) |
| `Ip_mag_mat` | `n_windows × n_freq` | 正序电流幅值 (kA) |
| `Uabc_mag_mat` | `n_windows × n_freq × 3` | 三相电压幅值 (A,B,C) |
| `Iabc_mag_mat` | `n_windows × n_freq × 3` | 三相电流幅值 (A,B,C) |

### 产出图表

| 图序 | 内容 | 说明 |
|------|------|------|
| 图1 | 正序有功功率 P(t) | 每个频率一条曲线 |
| 图2 | 正序无功功率 Q(t) | 同上 |
| 图3 | 正序电压幅值 | 同上 |
| 图4 | 正序电流幅值 | 同上 |
| 图5+ | 三相电压幅值 @ 各频率 | 每个频率一图，A/B/C 三线（黄/绿/红） |
| 图5+n_freq+ | 三相电流幅值 @ 各频率 | 同上 |

---

## 3. template_sliding_window_fft_spectrum — 全频谱可视化

### 用途

对每个窗的 6 个通道（三相 U + 三相 I）分别做 FFT，保存完整频谱（DC 到 `freq_limit`），以 3D surf 和频谱瀑布图展示频谱随时间的演化。

### 线路配置

与 `template_sliding_window_runner_power_flow` 相同的 `lines` + `line_sel` 方式。

### 独有配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `cfg.freq_limit` | `100` | 频谱显示范围 0~N Hz |
| `cfg.surf_phase` | `1` | 3D surf 展示哪一相 (1=A, 2=B, 3=C) |
| `cfg.notch_freq` | `50` | 瀑布图屏蔽中心频率 (Hz)，`[]` 关闭 |
| `cfg.notch_halfwidth` | `3` | 屏蔽半带宽，默认屏蔽 47~53 Hz |

### 计算流程

```
每窗: uabc_win, iabc_win
  → f_fft_simple (6 通道分别)
  → 存储全频谱 (DC ~ freq_limit)
  → U_mag, U_ang, I_mag, I_ang
```

### 输出变量

| 变量 | 维度 | 内容 |
|------|------|------|
| `win_center_t` | `n_windows × 1` | 每个窗的中心时刻 (s) |
| `freq_ax` | `n_bins × 1` | 频率轴 (Hz)，分辨率 = 1/t_span |
| `U_mag` | `n_windows × n_bins × 3` | 三相电压幅值谱 |
| `U_ang` | `n_windows × n_bins × 3` | 三相电压相位谱 (rad) |
| `I_mag` | `n_windows × n_bins × 3` | 三相电流幅值谱 |
| `I_ang` | `n_windows × n_bins × 3` | 三相电流相位谱 (rad) |
| `n_bins` | 标量 | = `round(freq_limit / Δf) + 1` |

### 产出图表

| 图序 | 类型 | 内容 |
|------|------|------|
| 图1 | 3D surf | 电压幅值谱（指定相），X=时间 Y=频率 Z=幅值 |
| 图2 | 3D surf | 电压相位谱（指定相），Z=相位 (°) |
| 图3 | 瀑布图 | 三相电压 A/B/C 各一个 subplot，`imagesc` 色图 |
| 图4 | 瀑布图 | 三相电流 A/B/C 各一个 subplot，`imagesc` 色图 |

瀑布图使用 `imagesc`：横轴时间、纵轴频率、颜色表示幅值。50 Hz 附近默认以 NaN 屏蔽（`notch_freq` / `notch_halfwidth` 控制），避免基波幅值过大淹没谐波。

---

## 公共配置速查

### 所有模板共用

| 参数 | 类型 | 单位 | 说明 |
|------|------|------|------|
| `cfg.root_dir` | string | — | CSV 文件所在目录 |
| `cfg.sample_freq` | int64 | Hz | 采样频率 |
| `cfg.t_span` | double | s | 窗长时间，频率分辨率 Δf = 1/t_span |
| `cfg.window_width` | int64 | 采样点 | = t_span × sample_freq，自动派生 |
| `cfg.t_start` | double | s | 数据截取起始时刻 |
| `cfg.t_end` | double | s | 数据截取结束时刻 |
| `cfg.window_step` | int | 采样点 | 窗每次移动距离 |
| `cfg.font_size` | int | pt | 图表字体大小 |
| `cfg.verbose` | logical | — | 是否在循环中打印进度 |

### power_flow / fft_spectrum 共用

| 参数 | 说明 |
|------|------|
| `line_sel` | 选择第几条线路（1-based） |
| `lines` | 线路配置 cell 数组，格式见各模板注释 |
| `cfg.root_dir` | 默认 `'../02-fault_recorder/'` |

### 频率设定（runner / power_flow 共用）

| 参数 | 说明 |
|------|------|
| `cfg.which_freq` | 指定频率向量 `[f1, f2, ...]`，非空时生效 |
| `cfg.freq_limit` | 全频段 `1:N` Hz，仅 `which_freq` 为空时生效 |

---

## 依赖函数

三个模板依赖以下共享函数，需在同一目录或 MATLAB 路径中：

| 函数 | 用途 |
|------|------|
| `f_sliding_window_generate` | 按步长自动生成滑动窗索引 |
| `f_fft_simple` | 单通道 FFT，返回单边谱 |
| `f_seqconv` | ABC → 正负零序分量变换 |
| `f_getColor` | 从 colormap 取色（仅 power_flow 使用） |

---

## 典型工作流

### 场景 A：查看某线路的谐波功率时序

1. 打开 `template_sliding_window_runner_power_flow.m`
2. 设 `line_sel` 为目标线路编号
3. 设 `cfg.which_freq` 为关注频率
4. 设 `cfg.t_span`（窗长）和 `cfg.window_step`（步长）
5. 运行，查看 P/Q 时序图和三相幅值图

### 场景 B：扫频查看频谱全貌

1. 打开 `template_sliding_window_fft_spectrum.m`
2. 设 `line_sel` 为目标线路
3. 设 `cfg.freq_limit` 为关注频段上限
4. 设 `cfg.t_span = 10` 获得 0.1 Hz 分辨率
5. 运行，3D surf 看整体趋势，瀑布图定位谐波变化时刻

### 场景 C：自定义分析

1. 复制 `template_sliding_window_runner.m`
2. 在核心计算区编写自己的 FFT/阻抗/功率逻辑
3. 在可视化区编写自己的绘图
4. 按需改用 `lines` + `line_sel` 线路配置

---

## 常见问题

### Q: 谐波幅值锯齿状振荡？

A: 目标频率不在 FFT bin 上，加上矩形窗旁瓣泄漏。详见 `doc_sliding_window_fft_sawtooth.md`。临时缓解：增大 `t_span` 使 Δf 更细；根本解决：加窗函数或插值 FFT。

### Q: 瀑布图频率轴只显示到 10 Hz？

A: 旧的 `n_bins = freq_limit + 1` 假设 Δf = 1 Hz，已修复为 `round(freq_limit / Δf) + 1`。如仍遇到，检查是否用了旧版代码。

### Q: t_span 改大后图谱看起来还是 1 Hz 一格？

A: 数据分辨率确实是 0.1 Hz（用 `diff(freq_ax(1:5))` 验证），是 `imagesc` 像素压缩导致的视觉错觉。已为瀑布图设置了更大的图形高度（28 cm），如仍不够可调大 `WATERFALL_HEIGHT`。

### Q: 如何添加新线路？

A: 在 `lines` cell 数组中新增一行：`{'线路名', '母线', U列范围, I列范围, 'CSV文件名', 起始秒}`，U/I 列范围是相对于数据列的（第 1 个数据列 = 1），加载时自动 +2。

### Q: 如何让相邻窗有重叠？

A: 设 `cfg.window_step < cfg.window_width`。例如 `t_span=1`（1000 点）、`window_step=100`，相邻窗重叠 90%。`window_step=window_width` 时各窗邻接无重叠。`window_step > window_width` 时窗间有间隙。
