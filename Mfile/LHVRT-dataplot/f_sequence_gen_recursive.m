function output_cell = f_sequence_gen_recursive(input_cell, deliminator)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


[row_sub_cell, col_sub_cell] = size(input_cell);
if col_sub_cell == 2
	tmp_cell = {};
	cell_i = input_cell{1};
	cell_j = input_cell{2};
	for idx_i = 1:length(cell_i)
		for idx_j = 1:length(cell_j)
			tmp_cell = strcat(cell_i(idx_i), deliminator, cell_j(idx_j));
		end
	end
	output_cell = tmp_cell;
else
	pop_out_cell = input_cell(1:2);
	leave_out_cell = input_cell(3:end);
	recursive_cell = f_sequence_gen_recursive(leave_out_cell, deliminator);
	output_cell = [recursive_cell, pop_out_cell];
end


