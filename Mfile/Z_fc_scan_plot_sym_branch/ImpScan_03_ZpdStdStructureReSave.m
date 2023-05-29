clear; clc
RootDir = 'F:\Data\20230301_鸿蒙3号地三一禾望6.25MW\02-Data\Zscan\';
TargetDir = 'C:\Users\ym\Desktop\鸿蒙3号地三一禾望6.25MW\';
PsetCell = {'P1.0', 'P0.9', 'P0.8', 'P0.7', 'P0.6', 'P0.5', ...
            'P0.4', 'P0.3', 'P0.2', 'P0.1', 'P0.0'};
QsetCell = {'Q0.0', 'Q1.0', 'Q-1.0'};


SubFolderCell = f_sequence_gen_recursive({PsetCell, QsetCell}, '-');
SubFolderCell = SubFolderCell{1};
SubFolderCell = [SubFolderCell, {'U1.05-P1.0-Q0.0', 'U0.95-P1.0-Q0.0'}];


TargetLowFreqDir = strcat(TargetDir, '\1-250Hz\');
TargetHighFreqDir = strcat(TargetDir, '\250-2500Hz\');

disp('Making target directories...')
mkdir(TargetLowFreqDir)
mkdir(TargetHighFreqDir)

for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	src_sub_low_dir = strcat(RootDir, SubFolderCell{each_folder}, "\", '1-250Hz\');
	src_sub_high_dir = strcat(RootDir, SubFolderCell{each_folder}, "\", '250-2500Hz\');
	tar_sub_low_dir = strcat(TargetLowFreqDir, "\", SubFolderCell{each_folder}, "\");
	tar_sub_high_dir = strcat(TargetHighFreqDir, "\", SubFolderCell{each_folder}, "\");
	mkdir(tar_sub_low_dir)
	mkdir(tar_sub_high_dir)
	copyfile(strcat(src_sub_low_dir, 'DATA_ZPD.mat'), tar_sub_low_dir)
	copyfile(strcat(src_sub_high_dir, 'DATA_ZPD.mat'), tar_sub_high_dir)

	copyfile(strcat(src_sub_low_dir, 'DATA_ZND.mat'), tar_sub_low_dir)
	copyfile(strcat(src_sub_high_dir, 'DATA_ZND.mat'), tar_sub_high_dir)
end