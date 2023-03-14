clear;clc
% User define zone [start]
ScanStartTime = 0.2;
Freq_begin = 1;
Freq_end = 250;
Freq_step = 1;

SimModel = 'pmsm_foc_impscan_r2016b_20221212';  % ���Բ���.mdl��׺
SimDuration = ScanStartTime + 1.6;  % ����ʱ�� = ģ�������������ȶ���ʱ�� + ɨ��һ�������ѵ�ʱ��
SaveTempFile = 0;


PsetArray = [1];
QsetArray = [0];

%% User define zone [end]
PsetCell = num2cell(PsetArray);
QsetCell = num2cell(QsetArray);

%%
for p_idx = 1:length(PsetCell)
    for q_idx = 1:length(QsetCell)
        p_name = num2str(PsetCell{p_idx}, '%.1f');
        q_name = num2str(QsetCell{q_idx}, '%.1f');
        p_set = PsetArray(p_idx);
        q_set = QsetArray(q_idx);
        % --- �����ļ���
        case_name = strcat('P', p_name, '-', 'Q', q_name);
        mkdir(case_name)

        % --- ������Ҫ�仯�Ĳ�������P��Q��
        set_param(SimModel, 'AccelVerboseBuild','on')

        % --- ɨƵ���� --- [start]
        tic
        warning('off')

        for freq = Freq_begin:Freq_step:Freq_end
            disp([num2str((p_idx-1)*length(PsetCell) + q_idx), '/', num2str(length(PsetCell)*length(QsetCell)), ' --- ', 'Scanning ', num2str(freq), ' Hz...'])
            tic
            sim(SimModel, SimDuration);
            toc
            movefile('scan.mat', ['scan_', num2str(freq), 'Hz.mat']);
        end
        
        disp('Enchainer fichier...')
        scan_concat = [];

        for freq = Freq_begin:Freq_step:Freq_end
            load(['scan_', num2str(freq), 'Hz.mat']);
            if SaveTempFile == 0
                delete(['scan_', num2str(freq), 'Hz.mat'])
            end
            scan_concat = [scan_concat, scan];
        end
        save([case_name, '/', case_name, '.mat'], 'scan_concat')
        toc
        % --- ɨƵ���� --- [end]
        
        % --- �迹�������� ---
        U_I_Z_F_StepAuto;
        close all
%         break  % debug only
    end
%     break  % debug only
end
disp('Done.')



