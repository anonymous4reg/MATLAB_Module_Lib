clear;clc
%% User could change here
RootDir = 'F:\Data\20230327_桃山湖明阳禾望1.5MW\02-data\5.24\vrt\Csv4Bpa\';
OutDir = RootDir;
OutFileName = 'KeyValue4Bpa';  % Output file name 输出文件名
Generator_Type = 'WT'; % 'WT' or 'SVG'

% Generating file names. 
% f_sequence_gen_recursive({cell1, cell2,...}, 'delimitor') is used for generating
% file name sequence. cell1, cell2... should be cell type, and all cells should be
% in a large cell, eg. {cell1, cell2, ...}. There is no limit of the cell amount, 
% the program will enumerate them recursively.
% f_sequence_gen_recursive({cell1, cell2,...}, '分隔符')用于生成全部文件名序列，
% 只要保证cell1、cell2...为元胞即可，字段数量没有限制，程序为递归调用。
% Field1 = {'VRT'};
% Field2 = {'3ph', '2ph'};
% Field3 = {'u20', 'u35', 'u50', 'u75', 'u120', 'u125', 'u130'};
% Field4 = {'p1.0', 'p0.2'};

Field1 = {'VRT'};
Field2 = {'3ph', '2ph'};
Field3 = {'u20', 'u35', 'u50', 'u75', 'u120', 'u125', 'u130'};
Field4 = {'p1.0', 'p0.2'};


SubFolderCell2 = f_sequence_gen_recursive({Field1, Field2, Field3, Field4}, '_');
SubFolderCell = SubFolderCell2{1};
% SubFolderCell = {'VRT_3ph_u50_p1.0'}

%% Sample time of your CSV time series data
% !!! 必须填正确 ！！！
% !!! ATTENTION: Set it properly !!!
Ts = 10e-3;

% Time point used for extracting key value
t_before = 1.0/Ts;  % before LHVRT happen
t_after = 2.14/Ts;  % during LHVRT

% Define each column of your CSV table, 
% this helps the program to know what's the meaning of each column
% TableHead = {'t', 'u', 'p', 'q', 'ip', 'iq'};
if strcmp(Generator_Type, 'WT') == true
    TableHead = {'t', 'u', 'p', 'q', 'ip', 'iq'};
elseif strcmp(Generator_Type, 'SVG') == true
    TableHead = {'t', 'U1', 'Q', 'Iq'};
else
    disp('Generator type must be: WT or SVG or ...')
end

which_col_is_u = 2;
which_col_is_iq = 6;
which_col_is_ip = 5;

%% table head for key value csv table
% 生成的关键数据表的表头，按需修改。 
% 风机光伏
if strcmp(Generator_Type, 'WT') == true
    ReturnTableHead = {'Fault Type', 'u_before', 'iq_before', 'ip_before' ...
			'u_after', 'iq_after', 'ip_after'};
elseif strcmp(Generator_Type, 'SVG') == true
% SVG
    ReturnTableHead = {'Fault Type', 'u_before', 'iq_before', ...
            'u_after', 'iq_after'};
else
    disp('Generator type must be: WT or SVG or ...')
end

ret_cell = {};

%% Main program here
tic
for each_file=1:length(SubFolderCell)
	clearvars u_before iq_before ip_before u_after iq_after ip_after tmp_cell
    file_table_head = TableHead;
	disp(strcat('[', num2str(each_file), '/', num2str(length(SubFolderCell)) , '] - ', ...
        'Working on: ', SubFolderCell{each_file}))
    % file_t = strcat(sub_folder_dir, '\', 'data_t.mat');
    csv_file_name = strcat(RootDir, SubFolderCell{each_file}, '.csv');
    csv_table = readtable(csv_file_name, 'ReadVariableNames', true);
    csv_array = csv_table.Variables;
    csv_table_head = csv_table.Properties.VariableNames;
    csv_table_head_len = length(csv_table_head);
    TableHead_len = length(TableHead);
    if csv_table_head_len > TableHead_len
        warning("Table head not consistent with buitin cell, maybe you use ..." + ...
            "the wrong Type or maybe your csv contains uabc/iabc column. ..." + ...
            "Please check carefully if the result does not match your prediction.")
        for idx = (TableHead_len+1):csv_table_head_len
            file_table_head{idx} = csv_table_head{idx};
        end
    end
    csv_table = array2table(csv_array, 'VariableNames', file_table_head);
    

    % before fault
    u_before = csv_table{t_before, TableHead{which_col_is_u}};
    iq_before = csv_table{t_before, TableHead{which_col_is_iq}};
    
    
    % after fault
    u_after = csv_table{t_after, TableHead{which_col_is_u}};
    iq_after = csv_table{t_after, TableHead{which_col_is_iq}};
    

    % 风机光伏
    if strcmp(Generator_Type, 'WT') == true
        ip_before = csv_table{t_before, TableHead{which_col_is_ip}};
        ip_after = csv_table{t_after, TableHead{which_col_is_ip}};
    end
    
    %% SVG

    
    if strcmp(Generator_Type, 'WT') == true
        %% WT ou PV
        tmp_cell = {SubFolderCell{each_file}, ...
                    u_before, iq_before, ip_before ...
    			    u_after, iq_after, ip_after};
    elseif strcmp(Generator_Type, 'SVG') == true
        %% SVG
        tmp_cell = {SubFolderCell{each_file}, ...
                    u_before, iq_before ...
                    u_after, iq_after};
    else
        disp('Generator type must be: WT or SVG or ...')
    end

    ReturnTableHead = [ReturnTableHead; tmp_cell];
%     break
end

ret_table = table(ReturnTableHead);

writetable(ret_table, strcat(OutDir, OutFileName, '.xlsx'), 'WriteVariableNames', false)

toc