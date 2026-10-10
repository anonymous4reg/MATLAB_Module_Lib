function C = impedance_scan_config(varargin)
%IMPEDANCE_SCAN_CONFIG 生成并校验扫频阻抗计算配置（P1：复现原代码行为）。
%
% 用法：C = impedance_scan_config()                    % 低频默认
%       C = impedance_scan_config('sample_time_us',20,'f_begin',250,'f_end',2500,'f_step',10);
%
% 字段说明：
%   f0            基频 (Hz)，默认 50
%   sample_time_us 仿真步长 (us)，采样率 fs = 1e6/sample_time_us
%   current_sign  电流参考方向：-1 表示录波电流反号（流入设备为正）。
%                 P1 为保持与基线一致，低频 SISO 路径暂不应用（保留原行为，
%                 见 run_low_band.m 的 FIX 注释）；P2 统一。
%   f_begin/f_end/f_step  注入频点列表 = f_begin:f_step:f_end。
%                 P1 低频 f_end=349（原代码 Freq_end=350 但循环到 349，第 350 段未被读取）；
%                 高频 f_end=2500。
%   f_report_begin/f_report_end  报告（输出裁剪）范围，P2 新增。
%                 低频默认 1~250Hz（注入到 349Hz 是为了给耦合处理提供配对数据）；
%                 高频用参数覆盖为 250~2500。
%   use_mimo      低频段是否计算 2x2 频率耦合阻抗
%   save_temps    是否保存中间量/结果/图
%   out_dir       输出根目录（空 = 数据所在目录，与原代码一致）

p = struct();
p.f0             = 50;
p.sample_time_us = 100;
p.current_sign   = -1;
p.f_begin        = 1;
p.f_end          = 349;     % 注入范围上界（P1 复现原代码 1..349）
p.f_step         = 1;
p.f_report_begin = 1;       % P2: 报告范围（低频最终结果 1~250Hz）
p.f_report_end   = 250;
p.use_mimo       = true;
p.save_temps     = true;
p.out_dir        = '';

for i = 1:2:numel(varargin)
    assert(i+1 <= numel(varargin), 'impedance_scan_config: 参数必须成对（name,value）');
    name = varargin{i};
    assert(isfield(p, name), 'impedance_scan_config: 未知字段 %s', name);
    p.(name) = varargin{i+1};
end

validateattributes(p.f0,             {'numeric'}, {'scalar','positive'});
validateattributes(p.sample_time_us, {'numeric'}, {'scalar','positive'});
validateattributes(p.f_end,          {'numeric'}, {'scalar','>=',p.f_begin});
validateattributes(p.f_step,         {'numeric'}, {'scalar','positive'});

C = p;
end
