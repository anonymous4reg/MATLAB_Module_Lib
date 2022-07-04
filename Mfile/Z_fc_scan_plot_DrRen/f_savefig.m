function [outputArg1] = f_savefig(arg_save_dir, arg_file_name, arg_format_cell, arg_res)
%UNTITLED Summary of this function goes here
%   arg_save_dir: the folder you want to save these figs in
%	arg_file_name: file name, the real file path will be : 
%			arg_save_dir + '/' + arg_file_name
%	arg_format_cell: a cell specify format in string. e.g: {'fig', 'emf', 'shit', 'tif', 'jpg', 'eps'}
% 	arg_res: resolution for bitmap (jpg,png,tiff), e.g: 300
% 	example: f_savefig('.\', 'myplot', {'fig', 'emf', 'png', 'tif', 'jpg', 'eps'}, 300)
	ExportFig = false;
	ExportEmf = false;
	ExportEps = false;
	ExportPng = false;
	ExportJpg = false;
	ExportTif = false;

	ExportResolution = num2str(arg_res);

	assert(isa(arg_res, 'double'), 'resolution must be a Number! e.g: 300')

	file_url = strcat(arg_save_dir, '\', arg_file_name);

	len_format_cell = length(arg_format_cell);
	for idx = 1:len_format_cell
		this_format = arg_format_cell{idx};
		if strcmp(this_format, 'fig') == true
			ExportFig = true;
		elseif strcmp(this_format, 'emf') == true
			ExportEmf = true;
		elseif strcmp(this_format, 'eps') == true
			ExportEps = true;
		elseif strcmp(this_format, 'png') == true
			ExportPng = true;
		elseif strcmp(this_format, 'jpg') == true
			ExportJpg = true;
		elseif strcmp(this_format, 'tif') == true
			ExportTif = true;
		else
			fprintf("Unsupported format: %s, this will be ignored\n", this_format)
		end
	end

	fprintf('In folder: %s\n', arg_save_dir)
	if ExportFig == true
		fprintf('Saving %s ...\n', strcat(arg_file_name, '.fig'))
	    saveas(gcf, append(file_url, '.fig'))
	end 
	if ExportEmf == true
		fprintf('Saving %s ...\n', strcat(arg_file_name, '.emf'))
	    saveas(gcf, append(file_url, '.emf'))
	end 
	if ExportEps == true
		fprintf('Saving %s ...\n', strcat(arg_file_name, '.eps'))
	    saveas(gcf, file_url, 'epsc')
	end 
	if ExportPng == true
		fprintf('Saving %s ...\n', strcat(arg_file_name, '.png'))
	    print(file_url, '-dpng', append('-r', ExportResolution))
	end 
	if ExportJpg == true
		fprintf('Saving %s ...\n', strcat(arg_file_name, '.jpg'))
	    print(file_url, '-djpeg', append('-r', ExportResolution))
	end 
	if ExportTif == true
		fprintf('Saving %s ...\n', strcat(arg_file_name, '.tif'))
	    print(file_url, '-dtiff', append('-r', ExportResolution))
	end 

end