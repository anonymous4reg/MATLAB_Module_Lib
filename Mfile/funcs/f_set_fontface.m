function f_set_fontface(input_gca, fontface_set)
%F_SET_FIG_SIZE Summary of this function goes here
%   Detailed explanation goes here

if isempty(fontface_set) == true
	tmp_fontface = 'simsun';
else
	tmp_fontface = fontface_set;
end
set(gca, 'fontname', tmp_fontface)

end
