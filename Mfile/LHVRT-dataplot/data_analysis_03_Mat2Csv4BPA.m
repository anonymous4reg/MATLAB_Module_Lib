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
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\07-chen_suo_liang\";
RootDir = "D:\Work\新能源工作\[Routine] 建模\20200923_佩特DFIG2.0MW\HaiDe_DFIG_2MW_matfile\02-mat_file\";

OutDir = strcat(RootDir, 'Csv4Bpa\');
mkdir(OutDir);
% RootDir锛? mat鏂囦欢鎵?鍦ㄦ枃浠跺す锛? OutDir锛歝sv鏂囦欢杈撳嚭鏂囦欢澶?



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
PostfixCell = {'p2.0', 'p0.4'};

SubFolderCell1 = f_sequence_gen_recursive({PrefixCell, PhaseCell, DipCell, PostfixCell}, '_');

PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};

SubFolderCell2 = f_sequence_gen_recursive({PrefixCell, PhaseCell, DipCell, PostfixCell}, '_');

% SubFolderCell = [SubFolderCell1{1}, SubFolderCell2{1}];
SubFolderCell = SubFolderCell2{1};


% 
CsvTableColumnName = {'t(s)', 'U1', 'P', 'Q', 'Ip', 'Iq'};
MatFileName = {'data_t', 'data_u', 'data_P', 'data_Ip', 'data_Q', 'data_Iq'};
MatFileVariableName = {'t', 'u1', 'p1', 'ip1', 'q1', 'iq1'};
ObjStruct = struct('CsvTableColumnName', CsvTableColumnName, ...
                   'MatFileName', MatFileName, ...
                   'MatFileVariableName', MatFileVariableName);
ObjStructLength = length(ObjStruct);
ResampleTs = 10e-3;



tic
for each_folder=1:length(SubFolderCell)
    clearvars -except OutDir each_folder RootDir PrefixCell ...
                      PhaseCell DipCell PostfixCell SubFolderCell ...
                      CsvTableColumnName ResampleTs ObjStruct ...
                      ObjStructLength MatFileVariableName MatFileName ...
                      
    disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)), ']-',...
        'Working on :', SubFolderCell{each_folder}))
    
    for struct_idx = 1:ObjStructLength
        load(strcat(RootDir, SubFolderCell{each_folder}, '\', ...
            ObjStruct(struct_idx).MatFileName) )
    end
    % load(strcat(RootDir, SubFolderCell{each_folder}, '\', ))
    % load(strcat(RootDir, SubFolderCell{each_folder}, '\data_u'))
    % % load(strcat(RootDir, SubFolderCell{each_folder}, '\data_P'))
    % load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Q'))
    % % load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Ip'))
    % load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Iq'))

    tmp_value = [];
    for struct_idx = 1:ObjStructLength
        tmp_value = [tmp_value, eval(ObjStruct(struct_idx).MatFileVariableName)];
    end
    t_resample = 0:ResampleTs:t(end);
    original_ts = timeseries(tmp_value(:, 2:end), t);
    resampled_ts = resample(original_ts, t_resample);

%   construct command str to list all time-series column
    data_col_num = length(MatFileVariableName) - 1; % time axis not included
    table_write_cmd_str_head = "table(resampled_ts.Time, ";
    table_write_cmd_str_body = "";
    table_write_cmd_str_tail = "'VariableNames', CsvTableColumnName)";

    for col_num = 1:data_col_num
        table_write_cmd_str_body = strcat(table_write_cmd_str_body, ...
            "resampled_ts.Data(:,", num2str(col_num), "), ");
    end
    
    table_write_cmd_str = strcat(table_write_cmd_str_head, ...
                                table_write_cmd_str_body, ...
                                table_write_cmd_str_tail);
                            
    Table2Write = eval(table_write_cmd_str);

    disp('Saving csv file...')
    writetable(Table2Write, strcat(OutDir, SubFolderCell{each_folder}, '.csv'), 'Delimiter', ',')
%     break  % debug only
end

toc
disp('Done')

