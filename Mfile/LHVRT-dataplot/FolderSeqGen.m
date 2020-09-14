function FolderCell = FolderSeqGen(prefix_cell, phase_cell, dip_cell, power_cell, sep)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%   Generate LVRT and HVRT cases folder according to prefix/case/postfix
tmp_cell = {};
tmp_idx = 1;
for prefix_idx = 1:length(prefix_cell)
	for phase_idx = 1:length(phase_cell)
		for power_idx = 1:length(power_cell)
			for dip_idx = 1:length(dip_cell)
				tmp_Folder = strcat(prefix_cell{prefix_idx}, sep, phase_cell{phase_idx}, sep, ...
									dip_cell{dip_idx}, sep, power_cell{power_idx});
				tmp_cell{tmp_idx} = tmp_Folder;
				tmp_idx = tmp_idx + 1;
			end
		end
	end
end

FolderCell = tmp_cell;
end

