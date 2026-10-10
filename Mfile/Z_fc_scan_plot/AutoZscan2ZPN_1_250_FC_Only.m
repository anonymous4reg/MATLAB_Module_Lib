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
RootDir = "D:\Travail\RE\HIL\[Routine] 沽源振荡\20240331_沽源振荡_豆柳沟\02-HIL测试\zscan\350\";

NamePattern = 'p*q*.mat';
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


for f_idx=1:length(file_list)

    OutRoot= OutRoot_Dir;
    mkdir(OutRoot);
    fprintf("Processing %i/%i \r\n", f_idx, numel(file_list))
    this_file_name = file_list(f_idx).name;
    this_file_path = fullfile(file_list(f_idx).folder, file_list(f_idx).name);
    Data = importdata(this_file_path);
   %% 计算1~100Hz
    
    [Ip_f_1_350,Vp_f_1_350,Ip_coupled1_350,Vp_coupled1_350] = ScanImpedanceP(Freq_begin,Freq_end,Freq_step,NN,Data);
    Ip1 = Ip_f_1_350(1,Freq_begin:Freq_middle);
    Vp1 = Vp_f_1_350(1,Freq_begin:Freq_middle);
    Ip_coupled1 = Ip_coupled1_350(1,Freq_begin:Freq_middle);
    Vp_coupled1 = Vp_coupled1_350(1,Freq_begin:Freq_middle);
    Ip2 = fliplr(Ip_coupled1);
    Vp2 = fliplr(Vp_coupled1);
    Ip_coupled2 = fliplr(Ip1);
    Vp_coupled2 = fliplr(Vp1);
    [ZPD1_99,ZND_n99_n1]= ScanImpedance2plusV5(Freq_begin,Freq_middle,Freq_step,Ip1,Vp1,Ip_coupled1,Vp_coupled1,Ip2,Vp2,Ip_coupled2,Vp_coupled2);
    
    %% 计算101~250Hz
    Ip3 = Ip_f_1_350(1,Freq_middle+1:Freq_end-1);
    Vp3 = Vp_f_1_350(1,Freq_middle+1:Freq_end-1);
    Ip_coupled3 = Ip_coupled1_350(1,Freq_middle+1:Freq_end-1);
    Vp_coupled3 = Vp_coupled1_350(1,Freq_middle+1:Freq_end-1);
    [In4temp,Vn4temp,In_coupled4temp,Vn_coupled4temp] = ScanImpedanceN(Freq_begin,Freq_end,Freq_step,NN,Data);
    In4 = In4temp(1,Freq_begin:Freq_end-Freq_middle-1);
    Vn4 = Vn4temp(1,Freq_begin:Freq_end-Freq_middle-1);
    In_coupled4 = In_coupled4temp(1,Freq_middle:Freq_end-1);
    Vn_coupled4 = Vn_coupled4temp(1,Freq_middle:Freq_end-1);
    Ip4 = In_coupled4;
    Vp4 = Vn_coupled4;
    Ip_coupled4 = In4;
    Vp_coupled4 = Vn4;
    [ZPD100_349,ZND_1_249]= ScanImpedance2plusV5(Freq_middle+1,Freq_end,Freq_step,Ip3,Vp3,Ip_coupled3,Vp_coupled3,Ip4,Vp4,Ip_coupled4,Vp_coupled4);

%     ZPD = [ZPD1_99;ZPD100_349(1:149,:)];
%     ZND = [ZND_n99_n1;ZND_1_249];
    ZPD100 = [100,(ZPD1_99(99,2)+ZPD100_349(1,2))/2,(ZPD1_99(99,3)+ZPD100_349(1,3))/2];
    ZPD = [ZPD1_99;ZPD100;ZPD100_349(1:149,:)];
    ZND = ZND_1_249;
    save(strcat(OutRoot, 'DATA_ZPD_', this_file_name, '.mat'), 'ZPD');
    save(strcat(OutRoot, 'DATA_ZND_', this_file_name, '.mat'), 'ZND');
    %测试用，正序+负序处理程序形成SISO阻抗
    [ZPD_SISO,ZND_SISO]=U_I_Z_F_1hz_1_250(Freq_begin,Freq_end,Freq_step,NN,Data);
    
    figure
    subplot(2,1,1);
    plot(ZPD(:,1),20*log10(ZPD(:,2)),'r');
    hold on;
%     plot(ZPD_SISO(:,1),20*log10(ZPD_SISO(:,2)),'b');
    xlabel('频率(Hz)');
    ylabel('幅值(dB)');
%     legend('聚合new','正负序无耦合SISO')
    legend('聚合new')
    title('正序阻抗')
    subplot(2,1,2);
    hold on;
    plot(ZPD(:,1),ZPD(:,3),'r');
%     plot(ZPD_SISO(:,1),ZPD_SISO(:,3),'b');
    xlabel('频率(Hz)');
    ylabel('相角(度)');
    saveas(gca, strcat(OutRoot, '频耦正序阻抗_', this_file_name, '.fig'))
    saveas(gca, strcat(OutRoot, '频耦正序阻抗_', this_file_name, '.png'))

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