clear;clc
RootDir = 'D:\GoldWind\03-MatFile-DLL\GW4.2MW\';


% Idle case processing
PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
% DipCell = {'u120', 'u125'};
% DipCell = {'u20', 'u35', 'u50', 'u75', 'u90'};
% PostfixCell = {'Idle'};  
PostfixCell = {'p4.2', 'p0.84'};
SubFolderCell = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');


tic
for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)), ']-',...
        'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, '\', SubFolderCell{each_folder}, '\');
	sub_folder_file_list = dir(strcat(sub_folder_dir, '\myfile*') );
	if length(sub_folder_file_list) > 1
		disp(strcat('Multiple MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	elseif length(sub_folder_file_list) == 1
		mat_file_dir = strcat(sub_folder_dir, '\', sub_folder_file_list(1).name);
		mat_var_name = GetVarNameFromMatFile(mat_file_dir);
		mat_var_name = mat_var_name{1};
		dump = RenameFileAndVarName(mat_file_dir, 'myfile.mat', 'opvar');
        
	else
		disp(strcat('No MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	end

	
end
disp('Done')
toc
