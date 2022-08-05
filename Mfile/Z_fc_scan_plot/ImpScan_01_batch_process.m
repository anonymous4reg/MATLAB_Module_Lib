%% 
clear; clc; close all

% User setting here
SrcFileDir  =   'C:\Users\ym\Desktop\test\';

FileName    =   'Lfile_1';
Freq_begin  =   1;
Freq_middle =   100;
Freq_end    =   350;
Freq_step   =   1;
SampleTimeMicroSecond  =   100; % Sample time of data(us)
SaveTempsFlag = true;

%% DON NOT Change this block !!!
CmdCell = {
	SrcFileDir, FileName, Freq_begin, Freq_middle, ...
	Freq_end, Freq_step, SampleTimeMicroSecond, SaveTempsFlag
};
%%


[ZPD_SISO, ZND_SISO] = AutoZscan2ZPN(CmdCell);

% [ZPD_SISO, ZND_SISO, ZPD_MIMO, ZND_MIMO] = AutoZscan2ZPN(CmdCell);

OutFileDir  = [SrcFileDir, '\1-250Hz'];

    figure
    subplot(2,1,1);
    plot(ZPD_SISO(:,1),20*log10(ZPD_SISO(:,2)),'k');
    hold on;
    title('Positive sequence')
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on
    set(gca, 'fontname', 'times new roman', 'fontsize', 14)

    subplot(2,1,2);
    plot(ZPD_SISO(:,1),ZPD_SISO(:,3),'k');
    hold on;
    xlabel('Frequency (Hz)');
    ylabel('Phase (deg)');
    grid on
    set(gca, 'fontname', 'times new roman', 'fontsize', 14)
    set(gcf, 'unit', 'centimeters', 'innerposition', [5, 5, 5+28, 5+14])
    f_savefig(OutFileDir, 'DATA_ZPD_SISO', {'fig', 'png'}, 300)

    
    figure
    subplot(2,1,1);
    plot(ZND_SISO(:,1),20*log10(ZND_SISO(:,2)),'k');
    hold on;
    title('Negative sequence')
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on
    set(gca, 'fontname', 'times new roman', 'fontsize', 14)

    subplot(2,1,2);
    plot(ZND_SISO(:,1),ZND_SISO(:,3),'k');
    hold on;
    xlabel('Frequency (Hz)');
    ylabel('Phase (deg)');
    grid on
    set(gca, 'fontname', 'times new roman', 'fontsize', 14)
    set(gcf, 'unit', 'centimeters', 'innerposition', [5, 5, 5+28, 5+14])
    f_savefig(OutFileDir, 'DATA_ZND_SISO', {'fig', 'png'}, 300)
