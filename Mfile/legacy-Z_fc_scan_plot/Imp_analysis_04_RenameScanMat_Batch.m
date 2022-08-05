% Generate ZukangScan.png in batch
clear;clc
RootDir = 'D:\RTLAB_File\TaiKai_SVG\03-mat_file\01-man_feng_sheng\Zscan\1-250Hz\';

% PsetCell = {'0.0', '0.75', '1.5', '2.25', '3.0'};
% QsetCell = {'0.0', '-0.4875', '-0.975', '0.4875', '0.975'};
% PsetCell = {'0.0', '1.05', '2.1', '3.15', '4.2'};
% QsetCell = {'0.0', '-1.0', '-2.0', '1.0', '2.0'};
% PsetCell = {'0.0', '0.75', '1.5', '2.25', '3.0'};
% QsetCell = {'0.0', '-0.75', '-1.5', '0.75', '1.5'};
PsetCell = {'0.95', '1.0', '1.05'};
QsetCell = {'0.0', '-0.5', '-1.0', '0.5', '1.0'};
SubFolderCell = {};

for pset = 1:length(PsetCell)
    for qset = 1:length(QsetCell)
        case_name = strcat('U', PsetCell{pset}, '_Q', QsetCell{qset});
        SubFolderCell = [SubFolderCell, case_name];
    end
end


tic
for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)), ']-',...
        'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, '\', SubFolderCell{each_folder}, '\');
	sub_folder_file_list = dir(strcat(sub_folder_dir, '\scan*') );
	if length(sub_folder_file_list) > 1
		disp(strcat('Multiple MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	elseif length(sub_folder_file_list) == 1
		mat_file_dir = strcat(sub_folder_dir, '\', sub_folder_file_list(1).name);
		mat_var_name = GetVarNameFromMatFile(mat_file_dir);
		mat_var_name = mat_var_name{1};
		dump = RenameFileAndVarName(mat_file_dir, 'scan.mat', 'scan');
        
	else
		disp(strcat('No MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
    end

%     break  % debug only
	
end
disp('Done')
toc
