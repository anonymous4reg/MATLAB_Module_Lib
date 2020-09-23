clear;clc

% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\01-man_feng_sheng\Stable\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\02-man_run_er\Stable\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\03-man_yi_qi\Stable\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\04-man_hua_dian\Stable\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\05-man_fu_xin\Stable\";
% RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\06-bai_miao_tan\Stable\";
RootDir = "D:\RTLAB_File\TaiKai_SVG\03-mat_file\07-chen_suo_liang\Stable\";


% Mat file name prefix, program will search related files in each folder
MatFilePrefix = "file";
% Variable name prefix, after loading a .mat file, program will search related variable name
VarNamePrefix = "data";

Vline_high = 230;
Vline_low = 37;
Capacity = 22;
% Idle case processing
SubFolderCell = {'01-svg_reactive_power_ctrl_ref_set', ...
                 '02-system_reactive_power_ctrl_ref_set', ...
                 '03-system_voltage_ctrl_ref_set', ...
                 '04-system_voltage_ctrl_under_disturbance', ...
                 '05-ctrl_mode_switch', ...
                 '06-ctrl_mode_switch'};

%

tic
for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, SubFolderCell{each_folder}, "\");
	% sub_folder_file_list = dir(strcat(sub_folder_dir, '\myfile*') );
	sub_folder_files = dir(sub_folder_dir);
	sub_folder_files = {sub_folder_files([sub_folder_files.isdir] == 0).name};
	sub_folder_files = sub_folder_files(~cellfun(@isempty, regexpi(sub_folder_files, strcat(MatFilePrefix, '.*(mat)'))));

	if length(sub_folder_files) == 1
	% If only ONE suitable .mat file founded, then do it.
		clearvars -except RootDir PrefixCell PhaseCell DipCell PostfixCell SubFolderCell each_folder ...
						sub_folder_dir sub_folder_files MatFilePrefix VarNamePrefix Vline_high ...
                        Vline_low Capacity
		disp(strcat("Loading ", sub_folder_files, " ..."))
		load(strcat(sub_folder_dir, sub_folder_files{1}))
		
		var_name_found = who;
		var_name_found = var_name_found(~cellfun(@isempty, regexpi(var_name_found, strcat(VarNamePrefix, '.*'))));
		if length(var_name_found) == 1
            % You may need to change the variable here in order to suit
            % your needs
        	data_1 = eval(var_name_found{1});
        
			% file_input
			% User input para here!!!
			% Plot code start here
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
            V220=data_1(20,:);
            Q220=data_1(21,:);
            Iq220=data_1(22,:);


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
            V220=V220';
            Q220=Q220';
            Iq220=Iq220';

            t_range = t(end);

            figure
            plot(t,V35 * Vline_low,'r','LineWidth',3)
            grid on;
            legend('U35+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('kV','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'U35+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U35+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U35+.png') )

            figure
            plot(t,V220 * Vline_high,'r','LineWidth',3)
            grid on;
            legend('U220+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('kV','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'U220+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U220+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'U220+.png') )

            figure
            plot(t, Q35 * Capacity,'r','LineWidth',3)
            grid on;
            legend('Q35+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('Mvar','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.png') )

            figure
            plot(t, Q220 * Capacity,'r','LineWidth',3)
            grid on;
            legend('Q220+');
            set(gca,'FontSize',18,'FontWeight','bold');
            xlabel('t/s','fontsize',20);
            ylabel('Mvar','fontsize',20);
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            saveas( gca, strcat(sub_folder_dir, '\', 'Q220+.fig') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q220+.emf') )
            saveas( gca, strcat(sub_folder_dir, '\', 'Q220+.png') )
            
            close all
    
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
disp('Compléter.')
toc




    




