function f_estimateRemainingTime(total_iterations, current_iteration)
    % 2025/02/14 修复版：增加持久化avg_time变量
    persistent timer_anchor;         % 时间锚点
    persistent time_records;         % 时间记录数组
    persistent smooth_factor;        % 平滑系数
    persistent avg_time;             % 新增持久化变量 <<< 关键修复
    
    % 初始化阶段
    if current_iteration == 1
        timer_anchor = tic;
        time_records = [];
        smooth_factor = 0.2;
        avg_time = 0;                % 初始化预测时间 <<< 重要补丁
        return;
    end
    
    % 计算当前迭代耗时
    current_elapsed = toc(timer_anchor);
    timer_anchor = tic;              % 重置时间锚点
    
    % 动态窗口策略（修复变量作用域）
    if current_iteration <= 10
        time_records(end+1) = current_elapsed;
        avg_time = mean(time_records);  % 更新持久化变量
    else
        % 指数平滑公式（使用持久化avg_time）
        avg_time = smooth_factor * current_elapsed + ...
                  (1 - smooth_factor) * avg_time;
    end
    
    % 剩余时间预测（修复零值保护）
    remaining_iter = total_iterations - current_iteration;
    if avg_time > 0
        estimated_time = avg_time * remaining_iter;
    else
        estimated_time = current_elapsed * remaining_iter;  % 应急策略
    end
    
    % 显示输出
    remaining_str = f_seconds_to_human_readable(estimated_time);
    fprintf('Progress: %d/%d (%.2f%%)\n', ...
            current_iteration, total_iterations, ...
            (current_iteration/total_iterations)*100);
    fprintf('Optimized Estimate: %s\n', remaining_str);
end