%% Calc fundamental component of dewtron data
% Step 1: Export Dewtron data to .mat format
% Step 2: Put those .mat file into structure folders, eg. VRT_2ph_u120_p0.2
% Step 3: Exec this prog.

%% code start
SrcDir = 'Z:\Travail\RE\HIL\20230804_悦梁三一禾望1.5MW双馈\04-德维创导出\';
% DstDir = '';

% Mat file name prefix, program will search related files in each folder
MatFilePrefix = '';
% Variable name prefix, after loading a .mat file, program will search related variable name
VarNamePrefix = 'opvar';

% Idle case processing
Field1 = {'VRT'};
Field2 = {'3ph', '2ph'};
Field3 = {'u120', 'u125', 'u130'};
Field4 = {'p1.0', 'p0.2'};



SubFolderCell2 = f_sequence_gen_recursive({Field1, Field2, Field3, Field4}, '_');
SubFolderCell = SubFolderCell2{1};


% file_list = dir(SrcDir);
% file_cell = {file_list(~[file_list.isdir]).name};
t_range = 15;
tsel_idx = int64(2.94/100e-6);


ExportFigureFormat = {'fig', 'png'};
ExportFig = true;
ExportEmf = true;
ExportPng = true;
ExportTiff = false;
ExportEps = false;
ExportSvg = false;
ExportResolution = 300; %dpi

for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(SrcDir, SubFolderCell{each_folder}, '\');
	% sub_folder_file_list = dir(strcat(sub_folder_dir, '\myfile*') );
	sub_folder_files = dir(sub_folder_dir);
	sub_folder_files = {sub_folder_files([sub_folder_files.isdir] == 0).name};
	sub_folder_files = sub_folder_files(~cellfun(@isempty, regexpi(sub_folder_files, strcat(MatFilePrefix, '.*(mat)'))));
    clearvars -except SrcDir Field1 Field2 DipCell PostfixCell SubFolderCell each_folder ...
                            sub_folder_dir sub_folder_files MatFilePrefix VarNamePrefix t_range ...
                            t_range setFontSize ExportFig ExportEmf ExportPng ExportTiff ...
                            ExportEps ExportSvg ExportResolution DstDir tsel_idx ExportFigureFormat
    if length(sub_folder_files) == 1
	% If only ONE suitable .mat file founded, then do it.
		disp(strcat('Loading', ' sub_folder_files', ' ...'))
		load(strcat(sub_folder_dir, sub_folder_files{1}))
        
        disp('(2/4) Rename vars')
        % Unify var name, avoiding openning the simulink to change var name
        % by hand
        t = Data1_Time;
        ua1 = Data1_Ua;
        ub1 = Data1_Ub;
        uc1 = Data1_Uc;
        ia1 = Data1_Ia;
        ib1 = Data1_Ib;
        ic1 = Data1_Ic;
    
        disp('(3/4) Simulating...')
        warning off
        simout = sim('fundamental_component_calc_r2022b');

        m1t = simout.m1.time(tsel_idx:end);
        m1t = m1t - m1t(1);
        m1v = simout.m1.signals.values(tsel_idx:end,1);
        m1p = simout.m1.signals.values(tsel_idx:end,2);
        m1q = simout.m1.signals.values(tsel_idx:end,3);
        m1ip = simout.m1.signals.values(tsel_idx:end,4);
        m1iq = simout.m1.signals.values(tsel_idx:end,5);

        disp('(4/4) Saving data...')
        save(strcat(sub_folder_dir, '\', 'data_t'), 'm1t');
        save(strcat(sub_folder_dir, '\', 'data_u'), 'm1v');
        save(strcat(sub_folder_dir, '\', 'data_P'), 'm1p');
        save(strcat(sub_folder_dir, '\', 'data_Q'), 'm1q');
        save(strcat(sub_folder_dir, '\', 'data_Ip'), 'm1ip');
        save(strcat(sub_folder_dir, '\', 'data_Iq'), 'm1iq');

        figure
        plot(m1t, m1ip,'r','LineWidth',3)
        grid on;
        hold on
        plot(m1t, m1iq, 'b','LineWidth',3)
        legend('Ip+', 'Iq+');
        set(gca,'FontSize',18,'FontWeight','bold');
        xlabel('m1t/s','fontsize',20);
        ylabel('IpIq/In','fontsize',20);
        axis_backup_1=axis;
        axis([0 t_range axis_backup_1(3:4)]);
        f_savefig(sub_folder_dir, 'IpIq', ExportFigureFormat, ExportResolution);



        figure
        plot(m1t, m1p,'r','LineWidth',3)
        grid on;
        hold on
        plot(m1t, m1q,'b','LineWidth',3)
        legend('P+', 'Q+');
        set(gca,'FontSize',18,'FontWeight','bold');
        xlabel('m1t/s','fontsize',20);
        ylabel('P/Qn','fontsize',20);
        axis_backup_1=axis;
        axis([0 t_range axis_backup_1(3:4)]);
        f_savefig(sub_folder_dir, 'PQ', ExportFigureFormat, ExportResolution);



        figure
        plot(m1t, m1v,'r','LineWidth',3)
        grid on;
        legend('U+');
        set(gca,'FontSize',18,'FontWeight','bold');
        xlabel('m1t/s','fontsize',20);
        ylabel('U/Un','fontsize',20);
        axis_backup_1=axis;
        axis([0 t_range axis_backup_1(3:4)]);
        f_savefig(sub_folder_dir, 'U', ExportFigureFormat, ExportResolution);

        close all
%         break
    end

end
