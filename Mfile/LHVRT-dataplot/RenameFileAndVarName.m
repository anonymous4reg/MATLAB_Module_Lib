function ret = RenameFileAndVarName(input_file, output_file_name, output_var_name)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


input_file_split = strsplit(input_file, '\');
input_file_split = input_file_split(1:end-1);
input_file_root_dir = join(input_file_split, '\');
input_file_root_dir = input_file_root_dir{1};


old_var_name = GetVarNameFromMatFile(input_file);
old_var_name = old_var_name{1};

load(input_file);
eval( strcat('opvar = ', old_var_name, ';') );
% disp(strcat('New file name: ', output_file_name))
% disp(strcat('New var name: ', output_var_name))
save(strcat(input_file_root_dir, '\', output_file_name), output_var_name);
ret = input_file_root_dir;
end