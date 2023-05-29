function FolderCell = ZscanFolderSeqGen(p_cell, q_cell, sep)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%   Generate LVRT and HVRT cases folder according to prefix/case/postfix
tmp_cell = {};
tmp_idx = 1;
for p_idx = 1:length(p_cell)
	for q_idx = 1:length(q_cell)
		tmp_Folder = strcat(p_cell{p_idx}, sep, q_cell{q_idx});
		tmp_cell{tmp_idx} = tmp_Folder;
		tmp_idx = tmp_idx + 1;
	end
end

FolderCell = tmp_cell;
end

