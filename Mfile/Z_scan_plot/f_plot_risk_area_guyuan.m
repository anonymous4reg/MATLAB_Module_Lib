function [outputArg1,outputArg2] = f_plot_risk_area_guyuan(input_gca)
%F_PLOT_RISK_AREA_MMC_HVDC Summary of this function goes here
%   Detailed explanation goes here
% outputArg1 = inputArg1;
% outputArg2 = inputArg2;

% upper bound
FACE_ALPHA = 0.3;

upper_pos = @(x, y) [x(1), y(2), x(2)-x(1), abs(180-y(2))];
lower_pos = @(x, y) [x(1), -180, x(2)-x(1), abs(-180-y(1))];

freq_cell = {[0, 20]};
phase_cell = {[-90, 90]};


for idx = 1:length(freq_cell)

    rectangle('Position', upper_pos(freq_cell{idx}, phase_cell{idx}),'FaceColor',[0.8 0 0 FACE_ALPHA], ...
            'EdgeColor', [0.8 0 0 FACE_ALPHA],  'LineWidth',0.1)

    hold on

    rectangle('Position', lower_pos(freq_cell{idx}, phase_cell{idx}),'FaceColor',[0.8 0 0 FACE_ALPHA], ...
            'EdgeColor', [0.8 0 0 FACE_ALPHA],  'LineWidth',0.1)

end

end

