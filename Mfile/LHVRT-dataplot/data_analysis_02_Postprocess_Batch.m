% 2020/9/23 - version 2: In this version Rename process is removed, program
% will recognize mat-file and variable automatically according to 
% __MatFilePrefix__ and __VarNamePrefix__, these two var act as
% regular expression
clear;clc
RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\06-bai_miao_tan\";

% Mat file name prefix, program will search related files in each folder
MatFilePrefix = "file";
% Variable name prefix, after loading a .mat file, program will search related variable name
VarNamePrefix = "data";

% Idle case processing
PrefixCell = {'VRT'};
PhaseCell = {'3ph'};
DipCell = {'u20u130', 'u20u130x2'};
% PostfixCell = {'q69', 'q-69', 'q13.8', 'q-13.8'};
% PostfixCell = {'q29', 'q-29', 'q5.8', 'q-5.8'};
% PostfixCell = {'idle'};
% PostfixCell = {'q28', 'q-28', 'q5.6', 'q-5.6'};
PostfixCell = {'q25', 'q-25', 'q5.0', 'q-5.0'};
% PostfixCell = {'q38.5', 'q-38.5', 'q7.7', 'q-7.7'};
% PostfixCell = {'q22', 'q-22', 'q4.4', 'q-4.4'};
SubFolderCell1 = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');

% DipCell = {'u20u130x2'};
% DipCell = {'u20', 'u50', 'u90'};
% DipCell = {'u130', 'u125', 'u120'};
% PostfixCell = {'Idle'};  

PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u50', 'u90', 'u120', 'u125', 'u130'};
% PostfixCell = {'q69', 'q-69', 'q13.8', 'q-13.8'};

SubFolderCell2 = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');

SubFolderCell = [SubFolderCell1, SubFolderCell2];

t_range = 15;


tic
for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, SubFolderCell{each_folder}, "\");
	% sub_folder_file_list = dir(strcat(sub_folder_dir, '\myfile*') );
	sub_folder_files = dir(sub_folder_dir);
	sub_folder_files = {sub_folder_files([sub_folder_files.isdir] == 0).name};
	sub_folder_files = sub_folder_files(~cellfun(@isempty, regexpi(sub_folder_files, strcat(MatFilePrefix, '.*(mat)'))));
    clearvars -except RootDir PrefixCell PhaseCell DipCell PostfixCell SubFolderCell each_folder ...
                            sub_folder_dir sub_folder_files MatFilePrefix VarNamePrefix t_range
	if length(sub_folder_files) == 1
	% If only ONE suitable .mat file founded, then do it.
		
		disp(strcat("Loading ", sub_folder_files, " ..."))
		load(strcat(sub_folder_dir, sub_folder_files{1}))
		
		var_name_found = who;
		var_name_found = var_name_found(~cellfun(@isempty, regexpi(var_name_found, strcat(VarNamePrefix, '.*'))));
		if length(var_name_found) == 1
        	data_1 = eval(var_name_found{1});
        
			
			%%% User code start
			Ts=5e-5;
            t=data_1(1,:);
            t=t-t(1);
            t=t';
            va220=data_1(2,:);
            vb220=data_1(3,:);
            vc220=data_1(4,:);
            Ia220=data_1(5,:);
            Ib220=data_1(6,:);
            Ic220=data_1(7,:);
            va35=data_1(8,:);
            vb35=data_1(9,:);
            vc35=data_1(10,:);
            Ia35=data_1(11,:);
            Ib35=data_1(12,:);
            Ic35=data_1(13,:);

            vcapa=data_1(14,:);
            vcapb=data_1(15,:);
            vcapc=data_1(16,:);
            V35=data_1(17,:);
            Q35=data_1(18,:);
            Iq35=data_1(19,:);


            va220=va220';
            vb220=vb220';
            vc220=vc220';
            Ia220=Ia220';
            Ib220=Ib220';
            Ic220=Ic220';
            va35=va35';
            vb35=vb35';
            vc35=vc35';
            Ia35=Ia35';
            Ib35=Ib35';
            Ic35=Ic35';
            vcapa=vcapa';
            vcapb=vcapb';
            vcapc=vcapc';
            V35=V35';
            Q35=Q35';
            Iq35=Iq35';


            figure
            plot(t,V35,'r','LineWidth',3)
            grid on;
            legend('U1+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('U/Un','fontsize',20);
            axis_backup_1=axis;
            if strcmp(PostfixCell{1}, 'idle') == true
                axis([0 t_range 0 1.35]);
            else
                axis([0 t_range axis_backup_1(3:4)]);
            end
            saveas( gca, strcat(sub_folder_dir, '\', 'U1+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U1+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U1+.png') )

            figure
            plot(t, Q35,'r','LineWidth',3)
            grid on;
            legend('Q1+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('Q/Qn','fontsize',20);
            axis_backup_1=axis;
            if strcmp(PostfixCell{1}, 'idle') == true
                axis([0 t_range 0 1.35]);
            else
                axis([0 t_range axis_backup_1(3:4)]);
            end
            saveas( gca, strcat(sub_folder_dir, '\', 'Q+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q+.png') )

            figure
            plot(t, Iq35,'r','LineWidth',3)
            grid on;
            legend('Iq1+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('I/In','fontsize',20);
            axis_backup_1=axis;
            if strcmp(PostfixCell{1}, 'idle') == true
                axis([0 t_range 0 1.35]);
            else
                axis([0 t_range axis_backup_1(3:4)]);
            end
            saveas( gca, strcat(sub_folder_dir, '\', 'Iq+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Iq+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Iq+.png') )

            save(strcat(sub_folder_dir, '\', 'data_t'), 't');
            save(strcat(sub_folder_dir, '\', 'data_u'), 'V35');
            save(strcat(sub_folder_dir, '\', 'data_Q'), 'Q35');
            save(strcat(sub_folder_dir, '\', 'data_Iq'), 'Iq35');

            close all

            %%% User code end
		else
        	disp(strcat("Multiple variables found in ", sub_folder_dir, sub_folder_files{1}))
			disp(var_name_found)
			disp("Please check your mat file! Pass...")
		end				
	
	elseif length(sub_folder_files) > 1
	% If multiple .mat file founded, then leave this folder untouched.
		disp(strcat("Multiple ", MatFilePrefix, "*.mat files found in folder: ", sub_folder_dir))
		disp(sub_folder_files)
		disp('Please resolve them manually.')					
		
	elseif length(sub_folder_files) == 0
		disp(strcat('No MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	else
		disp("Shit happened")
	end
% 	break  % debug only
	
end
disp('Compl¨¦ter.')
toc
