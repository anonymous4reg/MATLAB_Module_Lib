

clear;clc
% 定义文件夹路径 
RootDir = "E:\tmp\";
folder_new = '\Zscan\';  
folder_old = '\Zscan_old';  
freq_sub_folder = '\1-250Hz\';  
filename = 'DATA_ZPD.mat';  

% PsetCell = {'P1.0'};
% QsetCell = {'Q0.0'};
% 
% SubFolderCell = {};
% SubFolderCell = f_sequence_gen_recursive({PsetCell, QsetCell}, '-');
% SubFolderCell = SubFolderCell{1};

SubFolderCell = {'P1.0-Q0.0'}; %修改成对应文件夹名称，程序自动计算并保存图片

setFontSize = 10;
ExportFig = true;
ExportEmf = true;
ExportPng = true;
ExportTiff = false;
ExportEps = false;
ExportSvg = false;
ExportResolution = '300'; %dpi

tic
for f_idx=1:length(SubFolderCell)
    case_sub_folder = SubFolderCell{f_idx};
    sub_out_folder = fullfile(RootDir, folder_old, case_sub_folder);
    file_new = fullfile(RootDir, folder_new, case_sub_folder, freq_sub_folder, filename);
    file_old = fullfile(RootDir, folder_old, case_sub_folder, freq_sub_folder, filename);
    zpd_new = importdata(file_new);
    zpd_old = importdata(file_old);

    figure
    set(gcf,'unit','centimeters','position',[10,5,18,20])
    subplot(3,1,1);
    plot(zpd_new(:,1), zpd_new(:,2)./zpd_old(:,2), 'color', 'b');
    hold on
    plot([0, 250], [0.8, 0.8])
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (Zpd-New/Zpd-Old)');
    legend({'Zpd-New/Zpd-Old', '80% limit'})
    title(case_sub_folder)

    grid on
    set(gca, 'fontname', 'Times new roman')
    set(gca, 'xlim', [0, 250])

    subplot(3,1,2);
    plot(zpd_old(:,1), zpd_old(:,2), 'color', 'b');
    hold on
    plot(zpd_new(:,1), zpd_new(:,2), 'color', 'r')
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (ohm)');
    legend({'Zpd-Old', 'Zpd-New'})

    grid on
    set(gca, 'fontname', 'Times new roman')
    set(gca, 'xlim', [0, 250])

    subplot(3,1,3);
    f_plot_risk_area_guyuan(gca)
    plot(zpd_old(:,1), zpd_old(:,3), 'color', 'b');
    hold on
    plot(zpd_new(:,1), zpd_new(:,3), 'color', 'r')
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    legend({'Zpd-Old', 'Zpd-New'})
    grid on
    set(gca, 'fontname', 'Times new roman')
    set(gca, 'xlim', [0, 250])
    f_savefig(sub_out_folder, 'ZP_AmpCmp80per', {'fig', 'png'}, 300)
end
