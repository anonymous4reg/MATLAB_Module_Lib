% Read me before using
% This file is used for extracting U, P, Q, Ip, Iq from postprocessed .mat
% files and save them in .csv format with column name. The output .csv file
% would be used by BPA plot app.
clear;clc
% 更改ResampleTs，从而得到不同采样率的CSV
ResampleTs = 10e-3;
% ResampleTs = 100e-6;
RootDir = "E:\RTLAB_Data_HeWang\ChaoYangWan_DW3000_HW\LVRT\";


% 

% Please change here as you wish
PrefixCell = {'VRT'};
PhaseCell = {'3PH', '2PH'};
DipCell = {'20', '35', '50', '75', '120', '125', '130'};
% DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
PostfixCell = {'DF', 'XF'};

SubFolderCell = f_sequence_gen_recursive({PrefixCell, DipCell, PostfixCell, PhaseCell}, '-');
SubFolderCell = SubFolderCell{1};


% Please change here as you wish 
CsvTableColumnName = {'t(s)', 'U1', 'P', 'Ip', 'Q', 'Iq'};
MatFileName = {'data_t', 'data_u', 'data_P', 'data_Ip', 'data_Q', 'data_Iq'};
% MatFileVariableName = {'t', 'u1', 'p1', 'ip1', 'q1', 'iq1'};
MatFileVariableName = {'t1', 'v1', 'pe1', 'ip1', 'qe1', 'iq1'};

ObjStruct = struct('CsvTableColumnName', CsvTableColumnName, ...
                   'MatFileName', MatFileName, ...
                   'MatFileVariableName', MatFileVariableName);
ObjStructLength = length(ObjStruct);



% auto change csv folder name according to ts
if (ResampleTs == 10e-3)
    csv_folder_name = "Csv4Bpa";
elseif (ResampleTs == 100e-6)
    csv_folder_name = "Csv4Adpss";
else
    csv_folder_name = "Csv4Other";
end

disp(strcat("Making folder: ", csv_folder_name))

OutDir = strcat(RootDir, csv_folder_name, "\");
mkdir(OutDir);


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
    
    % Using eval in case user's __t__ in various form
    eval(strcat("t_resample = 0:ResampleTs:", MatFileVariableName{1}, "(end);"))
    eval(strcat("timeseries(tmp_value(:, 2:end), ", MatFileVariableName{1}, ");"))
    eval(strcat("original_ts = timeseries(tmp_value(:, 2:end), ", MatFileVariableName{1}, ");"))
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

