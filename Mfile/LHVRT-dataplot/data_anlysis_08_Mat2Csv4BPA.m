% Read me before using
% This file is used for extracting U, P, Q, Ip, Iq from postprocessed .mat
% files and save them in .csv format with column name. The output .csv file
% would be used by BPA plot app.
clear;clc
% RootDir： mat文件所在文件夹， OutDir：csv文件输出文件夹
RootDir = 'C:\Users\anony\Desktop\root\';
OutDir = RootDir;

% Idle case processing
PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
PostfixCell = {'p4.2', 'p0.84'};
SubFolderCell = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');
CsvTableColumnName = {'t(s)'; 'U1';  'Q';  'Iq'};
% CsvTableColumnName = {'t(s)'; 'U1'; 'P'; 'Q'; 'Ip'; 'Iq'};
MatFileVariableName = "t, V35, Q35, Iq35";
ResampleTs = 5e-3;


SubFolderCell = {"VRT_3ph_u20u130x2_q38.5"};
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
    disp('Save csv file')
	writetable(Table2Write, strcat(OutDir, SubFolderCell{each_folder}, '.csv'), 'Delimiter', ',')
    break
end
toc
disp('Done')
% % subplot(5,1,1)
