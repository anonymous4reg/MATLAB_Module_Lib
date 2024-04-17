% 单频vs频耦结果
clear;close all; clc


RootDir = "D:\Travail\RE\HIL\[Routine] 沽源振荡\20240105_沽源振荡_华北捅国调\03-ADPSS仿真复现\01-扫频结果数据\";
SrcSubDir = '20240219_沽源大网_B机型_变压器问题-03-扫频结果600台（供FFT）';
SrcDir = fullfile(RootDir, SrcSubDir, 'process');

FileName = "DATA_ZPD.mat";
FileUrl = fullfile(SrcDir, FileName);

load(FileUrl)
ZPD = ZPD_SISO;
figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    plot(ZPD(:,1), 20*log10(ZPD(:,2)), 'linewidth', 1.0);
    
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');

    grid on

    % set(gca, 'fontname', 'Times new roman')
    subplot(2,1,2);
    plot(ZPD(:,1),ZPD(:,3), 'linewidth', 1.0);

    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    % set(gca, 'fontname', 'Times new roman')

f_savefig(RootDir, "DATA_ZPD", {'fig', 'png'}, 300)