function ret = DataAnalysisRefactorMatFile(input_file, var_pattern)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
vars_list_old = whos();

load(input_file);

vars_list_new = whos();

vars_process_cell = {};
vars_process_idx = 1;

for idx_new = 1:length(vars_list_new)
	var_exist = 0;
	for idx_old = 1:length(vars_list_old)
		if strcmp(vars_list_new(idx_new).name, vars_list_old(idx_old).name) == 1
			var_exist = 1;
		end
	end
	if var_exist == 1
		continue
	elseif strcmp(vars_list_new(idx_new).name, 'vars_list_old') == 1
		% pass
	else		
		vars_process_cell{vars_process_idx} = vars_list_new(idx_new).name;
		vars_process_idx = vars_process_idx + 1;
	end
		
end

ret = vars_process_cell;
end
