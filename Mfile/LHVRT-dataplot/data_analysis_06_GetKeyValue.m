clear;clc

RootDir = ''D:\RTLAB_File\TaiKai_SVG\03-mat_file\02-man_run_er\third_test;
OutDir = RootDir;

PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u50', 'u90', 'u120', 'u125', 'u130'};
% DipCell = {'u20'};
% DipCell = {'u20', 'u35', 'u50'};
% DipCell = {'u130', 'u125', 'u120'};
% PostfixCell = {'Idle'};  
PostfixCell = {'q69', 'q-69', 'q13.8', 'q-13.8'};
SubFolderCell = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');
% SubFolderCell = {'LVRT_3ph_u20_p2.0', 'LVRT_3ph_u20_p0.4'};
Ts = 20e-6;
t_before = 1.0/Ts;
t_after = 2.25/Ts;

ret_cell = {'Fault Type', 'u_before', 'Iq_before', ...
			'u_after', 'Iq_after'};

tic
for each_folder=1:length(SubFolderCell)
	clearvars u_before Iq_before Ip_before u_after Iq_after Ip_after tmp_cell
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , '] - ', ...
        'Working on :', SubFolderCell{each_folder}))
    sub_folder_dir = strcat(RootDir, SubFolderCell{each_folder});
    file_t = strcat(sub_folder_dir, '\', 'data_t.mat');
    file_u = strcat(sub_folder_dir, '\', 'data_u.mat');
%     file_Ip = strcat(sub_folder_dir, '\', 'data_Ip.mat');
    file_Iq = strcat(sub_folder_dir, '\', 'data_Iq.mat');

    load(file_t)
    load(file_u)
%     load(file_Ip)
    load(file_Iq)

    % before fault
    u_before = V35(int64(t_before));
    Iq_before = Iq35(int64(t_before));
%     Ip_before = ip1(int64(t_before));
    % after fault
    u_after = V35(int64(t_after));
    Iq_after = Iq35(int64(t_after));
%     Ip_after = ip1(int64(t_after));
    tmp_cell = {SubFolderCell{each_folder}, u_before, Iq_before, ...
    			u_after, Iq_after};
    
    ret_cell = [ret_cell; tmp_cell];
end

writetable(table(ret_cell), strcat(OutDir, PrefixCell{1}, '.xlsx'))

toc