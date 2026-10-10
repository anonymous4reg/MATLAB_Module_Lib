clear
clc

Freq_begin=1;
Freq_middle = 100;
Freq_end=350;
Freq_step=1;
Step = 100; %仿真步长单位us,举例如果仿真步长是20us,输入20即可
NN=1/Step*10^6;
%% 将扫频数据命名为下面矩阵名称形式
% 风机或者光伏
RootDir = "F:\玉带湾扫频\1-250Hz";

NamePattern = 'P*Q*.mat';

OutRoot_Dir = fullfile(RootDir, '1-250Hz_NoFC\');

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


for f_idx=1:length(file_list)

    OutRoot= OutRoot_Dir;
    mkdir(OutRoot);
    fprintf("Processing %i/%i \r\n", f_idx, numel(file_list))
    this_file_name = file_list(f_idx).name;
    this_file_name_no_postfix = strsplit(this_file_name, '.');
    this_file_name_no_postfix = strjoin(this_file_name_no_postfix(1:end-1), '.');
    this_file_path = fullfile(file_list(f_idx).folder, file_list(f_idx).name);
    Data = importdata(this_file_path);
    %% Calc 1-350

    
    %测试用，正序+负序处理程序形成SISO阻抗
    [ZPD_SISO,ZND_SISO]=U_I_Z_F_1hz_1_250(Freq_begin,Freq_end,Freq_step,NN,Data);

    ZPD = ZPD_SISO;
    ZND = ZND_SISO;
    save(strcat(OutRoot, 'DATA_ZPD_', this_file_name_no_postfix, '.mat'), 'ZPD');
    save(strcat(OutRoot, 'DATA_ZND_', this_file_name_no_postfix, '.mat'), 'ZND');
    
    figure
    subplot(2,1,1);
    plot(ZPD(:,1),20*log10(ZPD(:,2)),'r');
    hold on;
%     plot(ZPD_SISO(:,1),20*log10(ZPD_SISO(:,2)),'b');
    xlabel('频率(Hz)');
    ylabel('幅值(dB)');
%     legend('聚合new','正负序无耦合SISO')
    legend('正序无频耦')
    title('正序阻抗')
    subplot(2,1,2);
    hold on;
    plot(ZPD(:,1),ZPD(:,3),'r');
%     plot(ZPD_SISO(:,1),ZPD_SISO(:,3),'b');
    xlabel('频率(Hz)');
    ylabel('相角(度)');
    saveas(gca, strcat(OutRoot, '正序阻抗无频耦_', this_file_name_no_postfix, '.fig'))
    saveas(gca, strcat(OutRoot, '正序阻抗无频耦_', this_file_name_no_postfix, '.png'))

    % break
%     
%     figure
%     subplot(2,1,1);
%     plot(ZND(:,1),20*log10(ZND(:,2)),'r');
%     hold on;
%     plot(ZND_SISO(:,1),20*log10(ZND_SISO(:,2)),'b');
%     xlabel('频率(Hz)');
%     ylabel('幅值(dB)');
%     legend('聚合new','正负序无耦合SISO')
%     title('负序阻抗')
%     subplot(2,1,2);
%     plot(ZND(:,1),ZND(:,3),'r');
%     hold on;
%     plot(ZND_SISO(:,1),ZND_SISO(:,3),'b');
%     xlabel('频率(Hz)');
%     ylabel('相角(度)');
%     saveas(gca, '频耦负序阻抗.fig')
%     saveas(gca, '频耦负序阻抗.tiff') 

end