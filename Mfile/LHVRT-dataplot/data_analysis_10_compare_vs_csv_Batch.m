% 2020/9/23 - version 2: In this version Rename process is removed, program
% will recognize mat-file and variable automatically according to 
% __MatFilePrefix__ and __VarNamePrefix__, these two var act as
% regular expression
clear;clc
RootDirNew = "D:\»ªÈñÎ¬ÚÐ-ScanData\LHVRT_20220627-v3\";
RootDirOld = "C:\Users\ym\Desktop\adpss\";

t_range = 15;
T_LHVRT_Iq_Test = 2.45;
setFontSize = 10;


% Idle case processing
Field1 = {'VRT'};
Field2 = {'3ph', '2ph'};
Field3 = {'u20', 'u130'};
Field4 = {'p1.0', 'p0.2'};



SubFolderCell2 = f_sequence_gen_recursive({Field1, Field2, Field3, Field4}, '_');
SubFolderCell = SubFolderCell2{1};

SubFolderCell = {'VRT_3ph_u20_p1.0'};

ExportFig = true;
ExportEmf = true;
ExportPng = true;
ExportTiff = false;
ExportEps = false;
ExportSvg = false;
ExportResolution = '300'; %dpi



tic
for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
    sub_folder_dir_old = strcat(RootDirOld, "\", SubFolderCell{each_folder}, ".csv");
    sub_folder_dir_new = strcat(RootDirNew, "\", SubFolderCell{each_folder}, "\");
    % clearvars -except RootDir Field1 Field2 DipCell PostfixCell SubFolderCell each_folder ...
    %                         sub_folder_dir sub_folder_files MatFilePrefix VarNamePrefix t_range ...
    %                         T_LHVRT_Iq_Test setFontSize ExportFig ExportEmf ExportPng ExportTiff ...
    %                         ExportEps ExportSvg ExportResolution
	% If only ONE suitable .mat file founded, then do it.
    tmp_csv = table2array(readtable(sub_folder_dir_old));
    told = tmp_csv(:, 1);
    tnew = load(strcat(sub_folder_dir_new, 'data_t'));
	Uold = tmp_csv(:, 2);
    Unew = load(strcat(sub_folder_dir_new, 'data_u'));

    Pold = tmp_csv(:, 3);
    Pnew = load(strcat(sub_folder_dir_new, 'data_P'));

    Qold = tmp_csv(:, 4);
    Qnew = load(strcat(sub_folder_dir_new, 'data_Q'));

    Ipold = tmp_csv(:, 5);
    Ipnew = load(strcat(sub_folder_dir_new, 'data_Ip'));

    Iqold = tmp_csv(:, 6);
    Iqnew = load(strcat(sub_folder_dir_new, 'data_Iq'));
    
%     told = told.t;
    tnew = tnew.t;
%     Uold = Uold.u1;
    Unew = Unew.u1;
%     Pold = Pold.p1;
    Pnew = Pnew.p1;
%     Qold = Qold.q1;
    Qnew = Qnew.q1;
%     Ipold = Ipold.ip1;
    Ipnew = Ipnew.ip1;
%     Iqold = Iqold.iq1;
    Iqnew = Iqnew.iq1;

        
			%%% User code start

            %% plot zone
            %% Unified plot
            this_file_path = append(sub_folder_dir_new, '\', 'Unified_Plot-Cmp');
            figure
            [ha, pos] = tight_subplot(3, 2, [0.04, 0.06], [0.03, 0.03], [0.06, 0.01]);
            set(gcf,'unit','centimeters','position',[0.5, 1, 45, 25])

            for hidx = 1:6
                axes(ha(hidx))
                switch hidx
                    case 1
                        plot(told, Uold,'b','LineWidth', 1.2);
                        grid on;
                        hold on;
                        plot(tnew, Unew,'r','LineWidth', 1.2);
                        legend({'U-Original', 'U-NEW'});
                        ylabel('U/Un');
                        title('\fontname{Times new roman} U+')
                        axis_backup_1=axis;
                        axis([0 t_range axis_backup_1(3:4)]);
                        set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    case 2
                        plot(told, Pold,'b','LineWidth', 1.2);
                        grid on;
                        hold on;
                        plot(tnew, Pnew,'r','LineWidth', 1.2);
                        legend({'P-Original', 'P-NEW'});
                        ylabel('P/p.u.');
                        title('\fontname{Times new roman} P+')
                        axis_backup_1=axis;
                        axis([0 t_range axis_backup_1(3:4)]);
                        set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    case 3
                        plot(told, Qold,'b','LineWidth', 1.2);
                        grid on;
                        hold on;
                        plot(tnew, Qnew,'r','LineWidth', 1.2);
                        legend({'Q-Original', 'Q-NEW'});
                        ylabel('Q/p.u.');
                        title('\fontname{Times new roman} Q+')
                        axis_backup_1=axis;
                        axis([0 t_range axis_backup_1(3:4)]);
                        set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    case 4
                        plot(told, Ipold,'b','LineWidth', 1.2);
                        grid on;
                        hold on;
                        plot(tnew, Ipnew,'r','LineWidth', 1.2);
                        legend({'Ip-Original', 'Ip-NEW'});
                        ylabel('Ip/p.u.');
                        title('\fontname{Times new roman} Ip+')
                        axis_backup_1=axis;
                        axis([0 t_range axis_backup_1(3:4)]);
                        set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    case 5
                        plot(told, Iqold,'b','LineWidth', 1.2);
                        grid on;
                        hold on;
                        plot(tnew, Iqnew,'r','LineWidth', 1.2);
                        legend({'Iq-Original', 'Iq-NEW'});
                        ylabel('Iq/p.u.');
                        title('\fontname{Times new roman} Iq+')
                        axis_backup_1=axis;
                        axis([0 t_range axis_backup_1(3:4)]);
                        set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    case 6
                        % plot(told, Uold,'b','LineWidth', 1.2);
                        % grid on;
                        % hold on;
                        % plot(tnew, Unew,'r','LineWidth', 1.2);
                        % legend({'U-Original', 'U-NEW'});
                        % ylabel('U/Un');
                        % title('\fontname{Times new roman} U+')
                        % axis_backup_1=axis;
                        % axis([0 t_range axis_backup_1(3:4)]);
                        % set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    % case 2
                    %     plot(t, P_pu_690V,'r','LineWidth', 1.2)
                    %     grid on;
                    %     legend('P+');
                    %     ylabel('P/Pn');
                    %     title('\fontname{Times new roman} P+')
                    %     axis_backup_1=axis;
                    %     axis([0 t_range axis_backup_1(3:4)]);
                    %     set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    
                    % case 3
                    %     plot(t, Q_pu_690V,'r','LineWidth', 1.2)
                    %     grid on;
                    %     legend('Q+');
                    %     ylabel('Q/Pn');
                    %     title('\fontname{Times new roman} Q+')
                    %     axis_backup_1=axis;
                    %     axis([0 t_range axis_backup_1(3:4)]);
                    %     set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    % case 4
                    %     plot(t, Ip_pu_690V,'r','LineWidth', 1.2)
                    %     grid on;
                    %     legend('Ip+');
                    %     ylabel('Ip/In');
                    %     title('\fontname{Times new roman} Ip+')
                    %     set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    % case 5
                    %     plot(t, Iq_pu_690V,'r','LineWidth', 1.2)
                    %     grid on;
                    %     hold on 
                    %     plot(t, val_LHVRT_Iq_Test_lim_vec, 'k', 'LineWidth', 1)
                    %     legend({'Iq+', 'Iq std limit'});
                    %     ylabel('Iq/In');
                    %     title('\fontname{Times new roman} Iq+')
                    %     axis_backup_1=axis;
                    %     axis([0 t_range axis_backup_1(3:4)]);
                    %     set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    % case 6
                    %     plot(t, Crowbar_drive, 'LineWidth', 1.2)
                    %     hold on
                    %     grid on
                    %     plot(t, Chopper_drive, 'LineWidth', 1.2)
                    %     legend({'CrowbarDrive', 'ChopperDrive'})
                    %     title('\fontname{Times new roman} Crowbar & Chopper Drive')
                    %     axis_backup_1=axis;
                    %     axis([0 t_range -0.5, 1.5]);
                    %     set(gca, 'xlim', [0, t_range], 'ylim', [-0.5, 1.5], 'fontname', 'times new roman', 'fontsize', setFontSize)
                    otherwise
                        disp('wrong')
                end

            end

            if ExportFig == true
                saveas(gcf, append(this_file_path, '.fig'))
            end 
            if ExportEmf == true
                saveas(gcf, append(this_file_path, '.emf'))
            end 
            if ExportEps == true
                saveas(gcf, this_file_path, 'epsc')
            end 
            if ExportPng == true
                print(this_file_path, '-dpng', append('-r', ExportResolution))
            end 
            if ExportTiff == true
                print(this_file_path, '-dtiff', append('-r', ExportResolution))
            end 


            % save(strcat(sub_folder_dir, '\', 'data_t'), 't');
            % save(strcat(sub_folder_dir, '\', 'data_u'), 'u1');
            % save(strcat(sub_folder_dir, '\', 'data_P'), 'p1');
            % save(strcat(sub_folder_dir, '\', 'data_Q'), 'q1');
            % save(strcat(sub_folder_dir, '\', 'data_Ip'), 'ip1');
            % save(strcat(sub_folder_dir, '\', 'data_Iq'), 'iq1');
            
            close all

        %%% User code end

	

	% break  % debug only
	
end
disp('Complete.')
toc
