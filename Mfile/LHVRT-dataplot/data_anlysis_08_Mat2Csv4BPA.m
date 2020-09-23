% Read me before using
% This file is used for extracting U, P, Q, Ip, Iq from postprocessed .mat
% files and save them in .csv format with column name. The output .csv file
% would be used by BPA plot app.
clear;clc

% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\01-man_feng_sheng\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\02-man_run_er\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\03-man_yi_qi\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\04-man_hua_dian\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\05-man_fu_xin\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\06-bai_miao_tan\";
RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\07-chen_suo_liang\";

OutDir = strcat(RootDir, 'Csv4Bpa\');
mkdir(OutDir);
% RootDir： mat文件所在文件夹， OutDir：csv文件输出文件夹



% Idle case processing
PrefixCell = {'VRT'};
PhaseCell = {'3ph'};
DipCell = {'u20u130', 'u20u130x2'};
% PostfixCell = {'q38.5', 'q-38.5', 'q7.7', 'q-7.7'};
% PostfixCell = {'q69', 'q-69', 'q13.8', 'q-13.8'};
% PostfixCell = {'q49', 'q-49', 'q9.8', 'q-9.8'};
% PostfixCell = {'q29', 'q-29', 'q5.8', 'q-5.8'};
% PostfixCell = {'q28', 'q-28', 'q5.6', 'q-5.6'};
% PostfixCell = {'q25', 'q-25', 'q5.0', 'q-5.0'};
PostfixCell = {'q22', 'q-22', 'q4.4', 'q-4.4'};
SubFolderCell1 = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');


PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u50', 'u90', 'u120', 'u125', 'u130'};

SubFolderCell2 = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');

SubFolderCell = [SubFolderCell1, SubFolderCell2];


CsvTableColumnName = {'t(s)'; 'U1';  'Q';  'Iq'};
% CsvTableColumnName = {'t(s)'; 'U1'; 'P'; 'Q'; 'Ip'; 'Iq'};
MatFileVariableName = {'t', 'V35', 'Q35', 'Iq35'};
ResampleTs = 5e-3;



tic
for each_folder=1:length(SubFolderCell)
    clearvars -except OutDir each_folder RootDir PrefixCell ...
                      PhaseCell DipCell PostfixCell SubFolderCell ...
                      CsvTableColumnName ResampleTs
    disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)), ']-',...
        'Working on :', SubFolderCell{each_folder}))

    load(strcat(RootDir, SubFolderCell{each_folder}, '\data_t'))
    load(strcat(RootDir, SubFolderCell{each_folder}, '\data_u'))
    % load(strcat(RootDir, SubFolderCell{each_folder}, '\data_P'))
    load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Q'))
    % load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Ip'))
    load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Iq'))

    % Table2Write = table(t1, v1, pe1, qe1, ip1, iq1, ...
    %     'CsvTableColumnNames', CsvTableColumnName);

    t_resample = 0:ResampleTs:t(end);
    original_ts = timeseries([V35, Q35, Iq35], t);
    resampled_ts = resample(original_ts, t_resample);

    Table2Write = table(resampled_ts.Time, resampled_ts.Data(:,1), ...
                        resampled_ts.Data(:,2), resampled_ts.Data(:,3)...
                        , 'VariableNames', CsvTableColumnName);
    disp('Saving csv file...')
    writetable(Table2Write, strcat(OutDir, SubFolderCell{each_folder}, '.csv'), 'Delimiter', ',')
%     break  % debug only
end

toc
disp('Done')

