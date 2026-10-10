function AutoZscan2ZPN(InputCmdCell)
clear
clc

Step =50e-6; %仿真步长
%% 将扫频数据命名为下面矩阵名称形式
RootDir = "F:\玉带湾扫频\250-2500Hz\";

NamePattern = 'P*Q*.mat';
% SVG
% NameMatrix = {'U1.0-Q1.0' 'U1.0-Q0.5'  'U1.0-Q0.0'...
%               'U1.0-Q-0.5' 'U1.0-Q-1.0'};

% NameMatrix = {'U1.0-Q1.0'};
OutRoot_Dir = fullfile(RootDir, '1-250Hz\');

% 文件夹路径
folder_path = RootDir; % 请将 YourFolderPath 替换为实际的文件夹路径
% 获取文件列表
file_list = dir(fullfile(folder_path, NamePattern));
% 初始化存储变量
data_cell = cell(1, numel(file_list));
% 读取符合条件的文件
% for i = 1:numel(file_list)
%     file_name = file_list(i).name;
%     file_path = fullfile(folder_path, file_name);
%     % data = importdata(file_path); % 使用 load 函数读取 MAT 文件
%     % 这里可以对读取的数据进行进一步处理，例如将其存储到一个 cell 数组中
%     data_cell{i} = data;
% end

% 打印读取的文件个数
fprintf('共读取了 %d 个文件\n', numel(file_list));

OutRoot_Dir = fullfile(RootDir, '250-2500Hz\');

for f_idx=1:length(file_list)

    OutRoot= OutRoot_Dir;
    mkdir(OutRoot);
    fprintf("Processing %i/%i \r\n", f_idx, numel(file_list))
    this_file_name = file_list(f_idx).name;
    this_file_name_no_postfix = strsplit(this_file_name, '.');
    this_file_name_no_postfix = strjoin(this_file_name_no_postfix(1:end-1), '.');
    this_file_path = fullfile(file_list(f_idx).folder, file_list(f_idx).name);
    Data = importdata(this_file_path);
    
    [ZPD, ZND] = U_I_Z_F_10hz_250_2500(Step,Data,OutRoot);

    save(strcat(OutRoot, 'DATA_ZPD_', this_file_name_no_postfix, '.mat'), 'ZPD');
    save(strcat(OutRoot, 'DATA_ZND_', this_file_name_no_postfix, '.mat'), 'ZND');

    figure
    subplot(2,1,1);
    plot(ZPD(:,1),20*log(ZPD(:,2)));
    xlabel('频率（Hz)');
    ylabel('幅值（dB)');
    subplot(2,1,2);
    plot(ZPD(:,1),ZPD(:,3));
    xlabel('频率（Hz)');
    ylabel('相角（度)');
    saveas(gca, strcat(OutRoot, '正序阻抗_', this_file_name_no_postfix, '.fig'))
    saveas(gca, strcat(OutRoot, '正序阻抗_', this_file_name_no_postfix, '.png'))

end
