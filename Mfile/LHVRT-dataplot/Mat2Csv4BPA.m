% Read me before using
% This file is used for extracting U, P, Q, Ip, Iq from postprocessed .mat
% files and save them in .csv format with column name. The output .csv file
% would be used by BPA plot app.
clear;clc
% RootDir： mat文件所在文件夹， OutDir：csv文件输出文件夹
RootDir = 'D:\Work\新能源工作\[Routine] 建模\20200519_金风GW\04-RTLAB_Data_MatFile\GW4.2\';
OutDir = RootDir;

% Idle case processing
PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
PostfixCell = {'p4.2', 'p0.84'};
SubFolderCell = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');
VariableName = {'t(s)'; 'U1'; 'P'; 'Q'; 'Ip'; 'Iq'};
tic
for each_folder=1:length(SubFolderCell)
	clearvars -except OutDir each_folder RootDir PrefixCell PhaseCell DipCell PostfixCell SubFolderCell VariableName
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)), ']-',...
        'Working on :', SubFolderCell{each_folder}))

	load(strcat(RootDir, SubFolderCell{each_folder}, '\data_t'))
	load(strcat(RootDir, SubFolderCell{each_folder}, '\data_u'))
	load(strcat(RootDir, SubFolderCell{each_folder}, '\data_P'))
	load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Q'))
	load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Ip'))
	load(strcat(RootDir, SubFolderCell{each_folder}, '\data_Iq'))

	Table2Write = table(t1, v1, pe1, qe1, ip1, iq1, ...
	    'VariableNames', VariableName);
    disp('Save csv file')
	writetable(Table2Write, strcat(OutDir, SubFolderCell{each_folder}, '.csv'), 'Delimiter', ',')
    break
end
toc
disp('Done')
% % subplot(5,1,1)
