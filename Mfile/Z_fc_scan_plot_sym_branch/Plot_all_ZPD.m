%% Description
% This file is a template for analyzing FFT spectrum with given data from
% the Fault recorder. You should first export csv from the Fault recorder,
% then feed it in to this program.
% Load CSV --> Select target column --> Plot result

close all; clear; clc

% Plot parameters
XaxisLimit = [0, 5];
YaxisLimit = [0, 400];
FONT_SIZE = 12;
LINEWIDTH = 1.3;
WIDTH_HEIGHT = [1.5, 5.8];
FigSaveFormat = {'fig', 'png'};
FigSaveResolution = 300;

tmp_mag = [];
tmp_ang = [];

%% User define zone
% 1. Where is your "xxx.mat" file?
RootDir = "F:\玉带湾扫频\1_2500Hz\";

% 文件夹路径
folder_path = RootDir; % 请将 YourFolderPath 替换为实际的文件夹路径

% 获取文件列表
file_list = dir(fullfile(folder_path, 'DATA_ZPD*.mat')); % 使用通配符 * 匹配所有的 .mat 文件

% 初始化存储变量
file_names = cell(1, numel(file_list));

data_cell = cell(1, numel(file_list));
% 读取符合条件的文件
for i = 1:numel(file_list)
    file_name = file_list(i).name;
    file_path = fullfile(folder_path, file_name);
    % 将文件名存储在 cell 数组中
    file_names{i} = file_name;
    data_cell{i} = importdata(file_path);
end

% 打印读取的文件个数
fprintf('共读取了 %d 个文件\n', numel(file_list));



% ZPD = ZPD_SISO;
figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
for f_idx = 1:length(file_list)
    tmp_mag = [tmp_mag, data_cell{f_idx}(:,2)];
    tmp_ang = [tmp_ang, data_cell{f_idx}(:,3)];

    subplot(2,1,1); hold on;
    plot(data_cell{f_idx}(:,1), 20*log10(data_cell{f_idx}(:,2)), 'linewidth', 1.0);
    
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');

    grid on

    set(gca, 'fontname', 'TimesNewRomanSimSun')
    set(gca, 'fontsize', FONT_SIZE)
    subplot(2,1,2); hold on
    plot(data_cell{f_idx}(:,1), f_phase_round_180(data_cell{f_idx}(:,3)), 'linewidth', 1.0);

    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', 'TimesNewRomanSimSun')
    set(gca, 'fontsize', FONT_SIZE)
    % break
end
subplot(2,1,1); 
legend(file_names, 'Interpreter', 'none')
% f_set_fontface(gca, 'times new roman')

f_savefig(RootDir, 'ALL_CASES', FigSaveFormat, FigSaveResolution)

% close all