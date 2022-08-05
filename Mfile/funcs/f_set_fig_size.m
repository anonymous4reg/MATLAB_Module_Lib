function [outputArg1] = f_set_fig_size(input_gcf, width_set, height_set)
%F_SET_FIG_SIZE Summary of this function goes here
%   Detailed explanation goes here

default_position = [10, 5];
tmp_position = [default_position, default_position(1) + width_set, default_position(2) + height_set];
set(input_gcf,'unit','centimeters','innerposition', tmp_position)
outputArg1 = 0;
end

