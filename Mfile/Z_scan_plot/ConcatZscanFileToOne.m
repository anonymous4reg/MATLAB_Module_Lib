% Concate 1~25kHz impedance scanning mat file in batch
% 
clear;clc

RootDir = 'D:\Travail\RE\HIL\[Routine] 阻抗专题\20210224_GW3.0D-PCS09_扫频\PLLvary\1-2500Hz\';
LowFreqDir = '1-250Hz\';
HighFreqDir = '250-2500Hz\';
OutDir = '1-2500Hz\';
common_file_name = 'DATA_ZP';
common_var_name = 'low_and_high';


KpSetArray = 1:2:29;
KiSetArray = 1:2:29;


KpSetCell = num2cell(KpSetArray);
KiSetCell = num2cell(KiSetArray);

FreqArray = [[1:249], [250:10:2500]]';
FreqCell = num2cell(FreqArray);


amp_mat = [[1:249], [250:10:2500]]';
phase_mat = amp_mat;

figure; hold on;
for kpset = 1:1
% for kpset = 1:length(KpSetCell)
    % for kiset = 1:1
    for kiset = 1:length(KiSetCell)
        
        case_name = strcat('KP', num2str(KpSetCell{kpset}, '%.1f'), '-KI', num2str(KiSetCell{kiset}, '%.1f'));
        disp(append('In folder: ', case_name, '...'))
        try
            load(strcat(RootDir, case_name, '\', common_file_name));
            tmp = eval(common_var_name);
            amp_mat = [amp_mat, tmp(:, 2)];
            phase_mat = [phase_mat, tmp(:, 3)];
            % plot(log10(tmp(:, 1)), 20*log10(tmp(:, 2)))
            % for freq = 1:length(FreqCell)
            %     amp_mat(freq, kpset, kiset) = tmp(freq, 1);
            %     phase_mat(freq, kpset, kiset) = tmp(freq, 2);
            % end
            
        catch ME
            disp('shit happened')
            rethrow(ME)
        end
%         break
    end
%     break
end

amp_table = table(amp_mat, 'VariableNames', )