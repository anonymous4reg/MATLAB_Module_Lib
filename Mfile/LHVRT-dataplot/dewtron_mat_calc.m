%% Calc fundamental component of dewtron data


%% code start
SrcDir = 'D:\Travail\RE\HIL\20230327_桃山湖明阳禾望\02-德维创数据导出\idle\';
DstDir = 'D:\Travail\RE\HIL\20230327_桃山湖明阳禾望\03-德维创数据转换结果\';
file_list = dir(SrcDir);
file_cell = {file_list(~[file_list.isdir]).name};
t_range = 15;
tsel_idx = int64(2.94/100e-6);

for idx = 1:length(file_cell)
    process_info_str = append('Processing ', num2str(idx), '/', num2str(length(file_cell)));
    disp(process_info_str)
    file_name = file_cell{idx};
    file_name_head = strsplit(file_name, '.');
    file_name_head = strjoin({file_name_head{1:end-1}}, '.');  % cut the extended name
    
    sub_folder_dir = append(DstDir, file_name_head);
    % create folder for each case
    mkdir(sub_folder_dir);
    file_path = strcat(SrcDir, file_name);

    disp('(1/4) Loading matfile')
    load(file_path)

    disp('(2/4) Rename vars')
    % 将dewtron导入的变量赋给对应的预设变量
    t = Data1_Time;
    ua1 = Data1_Ua;
    ub1 = Data1_Ub;
    uc1 = Data1_Uc;
    ia1 = Data1_Ia;
    ib1 = Data1_Ib;
    ic1 = Data1_Ic;

    disp('(3/4) Simulating...')
    warning off
    simout = sim('fundamental_component_calc');
    
    

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

        % figure
        % plot(m2t, m2ip,'r','LineWidth',3)
        % grid on;
        % hold on
        % plot(m2t, m2iq, 'b','LineWidth',3)
        % legend('Ip+', 'Iq+');
        % set(gca,'FontSize',18,'FontWeight','bold');
        % xlabel('m2t/s','fontsize',20);
        % ylabel('IpIq/In','fontsize',20);
        % axis_backup_1=axis;
        % axis([0 t_range axis_backup_1(3:4)]);
        % saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.fig') )
        % saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.emf') )
        % saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.png') )



        % figure
        % plot(m2t, m2p,'r','LineWidth',3)
        % grid on;
        % hold on
        % plot(m2t, m2q,'b','LineWidth',3)
        % legend('P+', 'Q+');
        % set(gca,'FontSize',18,'FontWeight','bold');
        % xlabel('m2t/s','fontsize',20);
        % ylabel('P/Qn','fontsize',20);
        % axis_backup_1=axis;
        % axis([0 t_range axis_backup_1(3:4)]);
        % saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.fig') )
        % saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.emf') )
        % saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.png') )


        % figure
        % plot(m2t, m2v,'r','LineWidth',3)
        % grid on;
        % legend('U+');
        % set(gca,'FontSize',18,'FontWeight','bold');
        % xlabel('m2t/s','fontsize',20);
        % ylabel('U/Un','fontsize',20);
        % axis_backup_1=axis;
        % axis([0 t_range axis_backup_1(3:4)]);
        % saveas( gca, strcat(sub_folder_dir, '\', 'U+.fig') )
        % saveas( gca, strcat(sub_folder_dir, '\', 'U+.emf') )
        % saveas( gca, strcat(sub_folder_dir, '\', 'U+.png') )
        
        close all
    % break
end