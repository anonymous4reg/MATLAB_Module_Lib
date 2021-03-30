%% Calc fundamental component of dewtron data


%% code start
SrcDir = 'D:\Travail\RE\HIL\20210122_禾望-韩家庄\03-现场高穿数据\matfile\';
DstDir = 'D:\Travail\RE\HIL\20210122_禾望-韩家庄\03-现场高穿数据\plotfile\';
file_list = dir(SrcDir);
file_cell = {file_list(~[file_list.isdir]).name};
t_range = 15;
tsel_idx = 2.95/100e-6;

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
    load(file_path)
    warning off
    simout = sim('fundamental_component_calc');
    
    m2t = simout.m2.time(tsel_idx:end);
    m2t = m2t - m2t(1);
    m2v = simout.m2.signals.values(tsel_idx:end,1);
    m2p = simout.m2.signals.values(tsel_idx:end,2);
    m2q = simout.m2.signals.values(tsel_idx:end,3);
    m2ip = simout.m2.signals.values(tsel_idx:end,4);
    m2iq = simout.m2.signals.values(tsel_idx:end,5);


        figure
        plot(m2t, m2ip,'r','LineWidth',3)
        grid on;
        hold on
        plot(m2t, m2iq, 'b','LineWidth',3)
        legend('Ip+', 'Iq+');
        set(gca,'FontSize',18,'FontWeight','bold');
        xlabel('m2t/s','fontsize',20);
        ylabel('IpIq/In','fontsize',20);
        axis_backup_1=axis;
        axis([0 t_range axis_backup_1(3:4)]);
        saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.fig') )
        saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.emf') )
        saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.png') )



        figure
        plot(m2t, m2p,'r','LineWidth',3)
        grid on;
        hold on
        plot(m2t, m2q,'b','LineWidth',3)
        legend('P+', 'Q+');
        set(gca,'FontSize',18,'FontWeight','bold');
        xlabel('m2t/s','fontsize',20);
        ylabel('P/Qn','fontsize',20);
        axis_backup_1=axis;
        axis([0 t_range axis_backup_1(3:4)]);
        saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.fig') )
        saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.emf') )
        saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.png') )


        figure
        plot(m2t, m2v,'r','LineWidth',3)
        grid on;
        legend('U+');
        set(gca,'FontSize',18,'FontWeight','bold');
        xlabel('m2t/s','fontsize',20);
        ylabel('U/Un','fontsize',20);
        axis_backup_1=axis;
        axis([0 t_range axis_backup_1(3:4)]);
        saveas( gca, strcat(sub_folder_dir, '\', 'U+.fig') )
        saveas( gca, strcat(sub_folder_dir, '\', 'U+.emf') )
        saveas( gca, strcat(sub_folder_dir, '\', 'U+.png') )
        
        close all
%     break
end