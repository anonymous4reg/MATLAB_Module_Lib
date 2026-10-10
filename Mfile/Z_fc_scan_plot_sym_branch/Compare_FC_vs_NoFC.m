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



%% User define zone
% 1. Where is your "xxx.mat" file?
RootDir = "F:\玉带湾扫频\";

% 文件夹路径
folder_path = RootDir; % 请将 YourFolderPath 替换为实际的文件夹路径
NoFcSubDir = "\1-250Hz\1-250Hz\";
FcSubDir = "\1-250Hz\1-250Hz_NoFC\";
OutRoot_Dir = fullfile(RootDir, '1_250Hz_Compare_NoFc_vs_Fc\');
% 获取文件列表
NamePattern = 'DATA_ZPD*.mat';
file_list = dir(fullfile(folder_path, FcSubDir, NamePattern)); % 使用通配符 * 匹配所有的 .mat 文件

% 初始化存储变量
file_names = cell(1, numel(file_list));

data_cell = cell(1, numel(file_list));
% 读取符合条件的文件


% 打印读取的文件个数
fprintf('共读取了 %d 个文件\n', numel(file_list));




for f_idx = 1:length(file_list)
    OutRoot= OutRoot_Dir;
    mkdir(OutRoot);
    fprintf("Processing %i/%i \r\n", f_idx, numel(file_list))
    this_file_name = file_list(f_idx).name;
    this_file_name_no_postfix = strsplit(this_file_name, '.');
    this_file_name_no_postfix = strjoin(this_file_name_no_postfix(1:end-1), '.');
    this_file_path = fullfile(file_list(f_idx).folder, file_list(f_idx).name);

    DataNoFc = importdata(fullfile(RootDir, NoFcSubDir, this_file_name));
    DataFc = importdata(fullfile(RootDir, FcSubDir, this_file_name));

    marker_indices = transpose(mod(1:length(DataNoFc), 5) == 0);

    subplot(2,1,1); hold on;
    plot(DataNoFc(:,1), 20*log10(DataNoFc(:,2)), 'linewidth', 1.0, 'Color', [0, 0, 1]);
    plot(DataNoFc(marker_indices, 1), 20*log10(DataNoFc(marker_indices, 2)), 'Color', [0, 0, 1], 'Marker', '*');

    plot(DataFc(:,1), 20*log10(DataFc(:,2)), 'linewidth', 1.0, 'Color', [1, 0, 0]);

    

    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');

    grid on

    set(gca, 'fontname', 'TimesNewRomanSimSun')
    set(gca, 'fontsize', FONT_SIZE)
    subplot(2,1,2); hold on
    plot(DataNoFc(:,1), f_phase_round_180(DataNoFc(:,3)), 'linewidth', 1.0, 'Color', [0, 0, 1]);
    plot(DataNoFc(marker_indices, 1), f_phase_round_180(DataNoFc(marker_indices,3)), 'Color', [0, 0, 1], 'Marker', '*');

    plot(DataFc(:,1), f_phase_round_180(DataFc(:,3)), 'linewidth', 1.0, 'Color', [1, 0, 0]);

    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', 'TimesNewRomanSimSun')
    set(gca, 'fontsize', FONT_SIZE)
    % break

    f_savefig(OutRoot, this_file_name_no_postfix, ...
        FigSaveFormat, FigSaveResolution)

    close all
end



