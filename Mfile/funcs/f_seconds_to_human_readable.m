function time_str = f_seconds_to_human_readable(total_seconds)
% 2024/12/05: created with Claude 3.5 by Yamin
% This function should be called by f_estimateRemainingTime
    % Convert total seconds to more readable format
    
    % Constants for time conversion
    seconds_per_minute = 60;
    seconds_per_hour = 3600;
    seconds_per_day = 86400;
    seconds_per_month = 2592000;  % Approximate
    seconds_per_year = 31536000;  % Non-leap year
    
    % Calculate years
    years = floor(total_seconds / seconds_per_year);
    total_seconds = mod(total_seconds, seconds_per_year);
    
    % Calculate months
    months = floor(total_seconds / seconds_per_month);
    total_seconds = mod(total_seconds, seconds_per_month);
    
    % Calculate days
    days = floor(total_seconds / seconds_per_day);
    total_seconds = mod(total_seconds, seconds_per_day);
    
    % Calculate hours
    hours = floor(total_seconds / seconds_per_hour);
    total_seconds = mod(total_seconds, seconds_per_hour);
    
    % Calculate minutes
    minutes = floor(total_seconds / seconds_per_minute);
    seconds = mod(total_seconds, seconds_per_minute);
    
    % Format the time string
    time_str = sprintf('%04d/%02d/%02d %02d:%02d:%02d', ...
        years, months, days, hours, minutes, floor(seconds));
end