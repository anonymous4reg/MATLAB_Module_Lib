% 2020/9/23 - version 2: In this version Rename process is removed, program
% will recognize mat-file and variable automatically according to 
% __MatFilePrefix__ and __VarNamePrefix__, these two var act as
% regular expression
clear;clc
RootDir = "E:\HaiDe_DFIG_2MW_matfile\02-mat_file\";

% Mat file name prefix, program will search related files in each folder
MatFilePrefix = "myfile";
% Variable name prefix, after loading a .mat file, program will search related variable name
VarNamePrefix = "opvar";

% Idle case processing
PrefixCell = {'VRT'};
% PhaseCell = {'3ph'};
% DipCell = {'u20u130', 'u20u130x2'};
% PostfixCell = {'q69', 'q-69', 'q13.8', 'q-13.8'};
% PostfixCell = {'q29', 'q-29', 'q5.8', 'q-5.8'};
% PostfixCell = {'idle'};
% PostfixCell = {'q28', 'q-28', 'q5.6', 'q-5.6'};
% PostfixCell = {'idle'};
PostfixCell = {'p2.0', 'p0.4'};
% PostfixCell = {'q38.5', 'q-38.5', 'q7.7', 'q-7.7'};
% PostfixCell = {'q22', 'q-22', 'q4.4', 'q-4.4'};
% SubFolderCell1 = f_sequence_gen_recursive({PrefixCell, PhaseCell, DipCell, PostfixCell}, '_');

% DipCell = {'u20u130x2'};
% DipCell = {'u20', 'u50', 'u90'};
% DipCell = {'u130', 'u125', 'u120'};
% PostfixCell = {'Idle'};  

PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
% DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
DipCell = {'u75'};
PostfixCell = {'p2.0', 'p0.4'};
% PostfixCell = {'q69', 'q-69', 'q13.8', 'q-13.8'};

SubFolderCell2 = f_sequence_gen_recursive({PrefixCell, PhaseCell, DipCell, PostfixCell}, '_');

% SubFolderCell = [SubFolderCell1{1}, SubFolderCell2{1}];
SubFolderCell = SubFolderCell2{1};


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
			Ts=2e-5;
            t=data_1(1,:);
            t=t-t(1);
            t=t';
            Vabc_35kV = data_1(2:4,:)';
            Iabc_35kV = data_1(5:7,:)';
            Vabc_690V = data_1(8:10,:)';
            Iabc_690V = data_1(11:13,:)';
            V_pu_35kV = data_1(14,:)';
            P_pu_35kV = data_1(15,:)';
            Q_pu_35kV = data_1(16,:)';
            Ip_pu_35kV = data_1(17,:)';
            Iq_pu_35kV = data_1(18,:)';
            V_pu_690V = data_1(19,:)';
            P_pu_690V = data_1(20,:)';
            Q_pu_690V = data_1(21,:)';
            Ip_pu_690V = data_1(22,:)';
            Iq_pu_690V = data_1(23,:)';
            V_dc = data_1(24,:)';

            figure
            plot(t, Iq_pu_690V,'r','LineWidth',3)
            grid on;
            legend('Iq+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('Iq/In','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'Iq+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Iq+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Iq+.png') )


            figure
            plot(t, Q_pu_690V,'r','LineWidth',3)
            grid on;
            legend('Q+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('Q/Pn','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'Q+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q+.png') )

            figure
            plot(t, Ip_pu_690V,'r','LineWidth',3)
            grid on;
            legend('Ip+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('Ip/In','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'Ip+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Ip+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Ip+.png') )



            figure
            plot(t, P_pu_690V,'r','LineWidth',3)
            grid on;
            legend('P+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('P/Qn','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'P+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'P+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'P+.png') )


            figure
            plot(t,V_pu_690V,'r','LineWidth',3)
            grid on;
            legend('U+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('U/Un','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'U+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U+.png') )

            u1 = V_pu_690V;
            p1 = P_pu_690V;
            q1 = Q_pu_690V;
            ip1 = Ip_pu_690V;
            iq1 = Iq_pu_690V;
            save(strcat(sub_folder_dir, '\', 'data_t'), 't');
            save(strcat(sub_folder_dir, '\', 'data_u'), 'u1');
            save(strcat(sub_folder_dir, '\', 'data_P'), 'p1');
            save(strcat(sub_folder_dir, '\', 'data_Q'), 'q1');
            save(strcat(sub_folder_dir, '\', 'data_Ip'), 'ip1');
            save(strcat(sub_folder_dir, '\', 'data_Iq'), 'iq1');
            
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
