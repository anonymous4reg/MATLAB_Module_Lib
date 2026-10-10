function f_add_max_datatip(search_range)
% F_ADD_MAX_DATATIP 在当前坐标轴的曲线中寻找绝对值最大值并标注
% 
% Usage:
%   f_add_max_datatip()          -> 使用当前坐标轴的 xlim 作为搜索范围
%   f_add_max_datatip([2.5, 4.5]) -> 指定时间范围 [2.5, 4.5] 内搜索
%

    % 1. 获取当前坐标轴对象
    ax = gca;
    
    % 2. 确定搜索的时间范围
    if nargin < 1 || isempty(search_range)
        t_limits = xlim(ax); % 默认使用当前视图范围
    else
        t_limits = search_range;
    end
    
    % 3. 获取坐标轴内所有的 Line 对象
    % 注意：plot(t, uabc) 会生成多个 line 对象
    lines = findobj(ax, 'Type', 'line');
    
    if isempty(lines)
        warning('当前坐标轴中没有发现曲线 (Line Object)。');
        return;
    end
    
    % 初始化变量，用于记录全局最大值
    global_max_abs_val = -1;
    target_line_handle = [];
    target_idx = [];
    
    % 4. 遍历每一条曲线 (处理 m*n 数据的情况)
    for k = 1:length(lines)
        % 获取该曲线的数据
        x_data = lines(k).XData;
        y_data = lines(k).YData;
        
        % 生成时间范围掩码 (Mask)
        mask = (x_data >= t_limits(1)) & (x_data <= t_limits(2));
        
        if ~any(mask)
            continue; % 如果该范围内无数据，跳过
        end
        
        % 提取感兴趣区域的数据
        y_roi = y_data(mask);
        
        % 寻找当前曲线在该范围内的绝对值最大值
        [max_val, loc_idx] = max(abs(y_roi));
        
        % 如果找到了更大的值，更新全局记录
        if max_val > global_max_abs_val
            global_max_abs_val = max_val;
            target_line_handle = lines(k);
            
            % 将局部索引映射回原始数据的全局索引
            indices = find(mask);
            target_idx = indices(loc_idx);
        end
    end
    
    % 5. 创建 DataTip
    if ~isempty(target_line_handle)
        % 删除该坐标轴上已有的旧 datatips (可选，防止重复堆叠)
        % delete(findobj(ax, 'Type', 'datatip')); 
        
        % 获取最大值点的实际坐标
        x_target = target_line_handle.XData(target_idx);
        y_target = target_line_handle.YData(target_idx);
        
        % 创建 datatip
        dt = datatip(target_line_handle, x_target, y_target);
        
        % 设置样式 (可选)
        dt.Location = 'northeast'; % 将标签置于点的右上方，避免遮挡
        
        % 如果需要自定义显示内容，可以修改 dt.String (R2021a+ 支持更好)
        % dt.DataTipTemplate.DataTipRows(1).Label = 'Time';
        % dt.DataTipTemplate.DataTipRows(2).Label = 'Max Val';
    end
    
end