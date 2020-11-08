function output_cell = f_sequence_gen_recursive(input_cell, deliminator)
% Generate delminator seperated sequence recursively, ver 1.0, by Yamin
% without using input_cell length limit
%   __input_cell__ must be a cell of cell, 
%  eg: {{'VRT'},{'3ph', '2ph'}, {'u20', 'u35', 'u50'}, {'p2.0', 'p0.4'}},
%  two-pair of '{}' is a must.
% 

[row_sub_cell, col_sub_cell] = size(input_cell);
if col_sub_cell == 2
	tmp_cell = {};
	cell_i = input_cell{1};
	cell_j = input_cell{2};
	for idx_i = 1:length(cell_i)
		for idx_j = 1:length(cell_j)
			tmp_cell = [tmp_cell strcat(cell_i(idx_i), deliminator, cell_j(idx_j))];
		end
	end
	output_cell = {tmp_cell};
else
	pop_out_cell = input_cell(end);
	leave_out_cell = input_cell(1:end-1);
	recursive_cell = f_sequence_gen_recursive(leave_out_cell, deliminator);
	output_cell = f_sequence_gen_recursive({recursive_cell{1}, pop_out_cell{1}}, deliminator);
end


