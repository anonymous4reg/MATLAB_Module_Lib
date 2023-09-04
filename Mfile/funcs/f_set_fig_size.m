function [outputArg1] = f_set_fig_size(input_gcf, leftCornerPos, widthHeight)
%F_SET_FIG_SIZE Summary of this function goes here
%   Detailed explanation goes here
tmp_position = [leftCornerPos, leftCornerPos + widthHeight];
set(input_gcf,'unit','centimeters','position', tmp_position)
outputArg1 = 0;
end

