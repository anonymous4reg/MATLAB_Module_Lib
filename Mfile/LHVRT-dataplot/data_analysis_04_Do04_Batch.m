clear;clc
RootDir = "D:\GoldWind\02-MatFile\GW4.2\LHVRT_NoLoad\";


PrefixCell = {"LVRT"};
PhaseCell = {"3ph"};
DipCell = {"u20", "u35", "u50", "u75", "u90"}
PostfixCell = {"NoLoad"};
SubFolderCell = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');



for each_folder=1:length(SubFolderCell)
	sub_folder_dir = strcat(RootDir, '\', SubFolderCell{each_folder}, '\');
	sub_folder_file_list = dir(strcat(sub_folder_dir, '\myfile*') );
	if length(sub_folder_dir) > 1
		disp(strcat('Multiple MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	elseif length(sub_folder_dir) == 1
		mat_file_dir = strcat(sub_folder_dir, '\', sub_folder_file_list(1).name);
		mat_var_name = GetVarNameFromMatFile(mat_file_dir);
		mat_var_name = mat_var_name{1};
		load(mat_file_dir)
		opvar = eval(mat_var_name);
		clear(mat_var_name)
		save(strcat(sub_folder_dir, '\myfile'), 'opvar')
	else
		disp(strcat('No MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	end

	break
end
