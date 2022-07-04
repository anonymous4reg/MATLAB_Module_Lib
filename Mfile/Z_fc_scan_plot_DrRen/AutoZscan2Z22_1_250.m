function AutoZscan2ZP22()
clear
clc

RootDir = 'C:\Users\ym\Desktop\tmp\';
MatFilePrefix = "Hfile";

Field1 = {'VRT'};
Field2 = {'3ph', '2ph'};
Field3 = {'u130'};
Field4 = {'p1.0', 'p0.2'};

SubFolderCell_tmp = f_sequence_gen_recursive({Field1, Field2, Field3, Field4}, '_');
SubFolderCell = SubFolderCell_tmp{1};

SubFolderCell = {'P0.4-Q0.0'}

for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, SubFolderCell{each_folder}, "\");
	sub_folder_struct = dir(strcat(sub_folder_dir, '\', MatFilePrefix, '*') );
	
    
	if length(sub_folder_struct) == 1
		tmp_hfile_name = sub_folder_struct.name;
		url_Lfile_fc0 = strcat(sub_folder_struct.folder, '/', 'Lfile_fc0.mat');
		url_Lfile_fc1 = strcat(sub_folder_struct.folder, '/', 'Lfile_fc1.mat');
		url_Hfile 	  = strcat(sub_folder_struct.folder, '/',  tmp_hfile_name);

		NN = 50000; %仿真步长de倒数

		ResultSaveDir = strcat(sub_folder_struct.folder, '\', 'fc_result');
		mkdir(ResultSaveDir)

		Freq_begin = 1;
		Freq_end = 250;
		Freq_step = 1;

		Freq_begin_H = 250;
		Freq_end_H = 2490;

		% url_Lfile_fc0 = strcat(RootDir, 'Lfile_fc0.mat');
		% url_Lfile_fc1 = strcat(RootDir, 'Lfile_fc1.mat');
		% url_Hfile 	  = strcat(RootDir, 'Hfile_7.mat');

		Data1 = load(url_Lfile_fc0);%低频F
		Data2 = load(url_Lfile_fc1);%低频FC
		Data3 = load(url_Hfile);%高频

		ScanImpedance1(NN,Data1,Freq_begin,Freq_end,Freq_step, ResultSaveDir);
		ScanImpedance2(NN,Data2,Freq_begin,Freq_end,Freq_step, ResultSaveDir);
		ScanImpedance2plusV5(Freq_begin,Freq_end,Freq_step, ResultSaveDir);

		U_I_Z_F_10hz(NN,Data3,Freq_begin_H,Freq_end_H, ResultSaveDir);

		%%%%%%%
		clearvars -except ResultSaveDir;
		Data_L = load([ResultSaveDir, '/', 'ZP3'  '.mat']);
		Data_L = cell2mat(struct2cell(Data_L));
		Data_H = load([ResultSaveDir, '/', 'DATA_ZPD'  '.mat']);
		Data_H = cell2mat(struct2cell(Data_H));

		Data_freq = [Data_L(:,1);Data_H(:,1)];
		Data_Mag = [Data_L(:,2);Data_H(:,2)];
		Data_Pha = [Data_L(:,3);Data_H(:,3)];

		DATA_ZPD_FC = [Data_freq, Data_Mag, Data_Pha];
		save(strcat(ResultSaveDir, '\', 'DATA_ZPD_FC'), 'DATA_ZPD_FC')


		figure
		subplot(2,1,1);
		plot(Data_freq,20*log10(Data_Mag));
		xlabel('频率(Hz)');
		ylabel('幅值(dB)');
        grid on
		subplot(2,1,2);
		plot(Data_freq,Data_Pha);
		xlabel('频率(Hz)');
		ylabel('相角(度)');
        grid on
		f_savefig(ResultSaveDir, 'Freq-coupling-result(1-2500Hz)', {'fig', 'emf', 'png'}, 300);

		figure
		subplot(2,1,1);
		semilogx(Data_freq,20*log10(Data_Mag));
		xlabel('频率(Hz)');
		ylabel('幅值(dB)');
        grid on
		subplot(2,1,2);
		semilogx(Data_freq,Data_Pha);
		xlabel('频率(Hz)');
		ylabel('相角(度)');
        grid on
		f_savefig(ResultSaveDir, 'Freq-coupling-result-Log(1-2500Hz)', {'fig', 'emf', 'png'}, 300);

		close all

	else
		disp('There is multiple MatFile in this folder')
	end % if length(sub_folder_files) == 1

end % for each_folder=1:length(SubFolderCell)