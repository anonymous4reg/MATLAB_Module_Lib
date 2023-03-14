clear;clc; close all

RootDir = 'D:\Envision3p3\Envision_JJL_3p3_data\12-SP-20220826\';

PsetCell = {'P1.0', 'P0.9', 'P0.8', 'P0.7', 'P0.6', 'P0.5', 'P0.4', 'P0.3', 'P0.2', 'P0.1', 'P0.0'};
QsetCell = {'Q0.0', 'Q1.0', 'Q-1.0'};


SubFolderCell = {};

SubFolderCell = f_sequence_gen_recursive({PsetCell, QsetCell}, '');
SubFolderCell = SubFolderCell{1};
SubFolderCell = [SubFolderCell, 'U0.95P1.0Q0.0', 'U1.05P1.0Q0.0']

figure
set(gcf,'unit','centimeters','position',[10,5,18,8+3])
subplot(2, 1, 2)
f_plot_risk_area_mmc_hvdc(gca);
hold on
for idx = 1:length(SubFolderCell)
    
    tmp_color = f_getColor(idx, 1, length(SubFolderCell));
    sub_dir = SubFolderCell{idx};
    if strcmp(sub_dir, 'P0.0Q1.0') || strcmp(sub_dir, 'P0.0Q-1.0') 
        continue;
    end
    mat_file_url = strcat(RootDir, '\', sub_dir, '\1-2500Hz\', 'DATA_ZPD.mat');
    tmp_mat = load(mat_file_url);
    tmp_mat = cell2mat(struct2cell(tmp_mat));
    ZPD_all = tmp_mat;
    

    subplot(2,1,1);
%     semilogx(ZPD_all(:,1), 20*log10(ZPD_all(:,2)), 'color', tmp_color, ...
% 	    'linewidth', 1.0);
    plot(ZPD_all(:,1), 20*log10(ZPD_all(:,2)), 'color', tmp_color, ...
	    'linewidth', 1.0);
    hold on
    set(gca, 'fontname', 'Times new roman')

    subplot(2,1,2);
%     semilogx(ZPD_all(:,1),ZPD_all(:,3), 'color', tmp_color, ...
% 	    'linewidth', 1.0);
    plot(ZPD_all(:,1),ZPD_all(:,3), 'color', tmp_color, ...
	    'linewidth', 1.0);
    hold on
    grid on
    set(gca, 'fontname', 'Times new roman')
   
%     break;

end
subplot(2,1,1);
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
title('All cases')
grid on
set(gca, 'fontname', 'Times new roman')

subplot(2,1,2);
xlabel('Frequency (Hz)');
ylabel('Phase (Deg)');
grid on
set(gca, 'fontname', 'Times new roman')
legend(SubFolderCell)

% f_savefig(RootDir, 'ZP_BodePlot_Log', {'fig', 'png'}, 300)
