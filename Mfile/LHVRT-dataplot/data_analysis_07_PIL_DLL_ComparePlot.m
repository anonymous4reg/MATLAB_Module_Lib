clear;clc

% Idle case processing
PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
% DipCell = {'u120', 'u125'};
% DipCell = {'u20', 'u35', 'u50', 'u75', 'u90'};
% PostfixCell = {'Idle'};  
PostfixCell = {'p4.2', 'p0.84'};
SubFolderCell = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');

HIL_Dir = 'D:\GoldWind\02-MatFile-HIL\GW4.2\';
DL_Dir = 'D:\GoldWind\03-MatFile-DL\GW4.2MW\';
Out_Dir = 'D:\GoldWind\04-DL-HIL-ComparePlot\GW4.2MW\';
PlotVisibleOrNot = 'off';  % 'on' or 'off'

tic
for case_idx = 1:length(SubFolderCell)

    clearvars -except SubFolderCell  Out_Dir DL_Dir HIL_Dir case_idx PlotVisibleOrNot

    % data load
    load(strcat(DL_Dir, SubFolderCell{case_idx}, '\', 'data_u.mat'))
    load(strcat(DL_Dir, SubFolderCell{case_idx}, '\', 'data_P.mat'))
    load(strcat(DL_Dir, SubFolderCell{case_idx}, '\', 'data_Q.mat'))
    load(strcat(DL_Dir, SubFolderCell{case_idx}, '\', 'data_Ip.mat'))
    load(strcat(DL_Dir, SubFolderCell{case_idx}, '\', 'data_Iq.mat'))
    load(strcat(DL_Dir, SubFolderCell{case_idx}, '\', 'data_t.mat'))
    % avoiding variable collision
    t2 = t1;
    v2 = v1;
    pe2 = pe1;
    qe2 = qe1;
    ip2 = ip1;
    iq2 = iq1;

    load(strcat(HIL_Dir, SubFolderCell{case_idx}, '\', 'data_u.mat'))
    load(strcat(HIL_Dir, SubFolderCell{case_idx}, '\', 'data_P.mat'))
    load(strcat(HIL_Dir, SubFolderCell{case_idx}, '\', 'data_Q.mat'))
    load(strcat(HIL_Dir, SubFolderCell{case_idx}, '\', 'data_Ip.mat'))
    load(strcat(HIL_Dir, SubFolderCell{case_idx}, '\', 'data_Iq.mat'))
    load(strcat(HIL_Dir, SubFolderCell{case_idx}, '\', 'data_t.mat'))


    dir_name = strcat(Out_Dir, SubFolderCell{case_idx});
    mkdir(dir_name)
    disp(['(', int2str(case_idx), '/', num2str(length(SubFolderCell)) , ') - Current in: ', dir_name])

    % --------------plot zone-------------------
    if (mod(case_idx, 8) == 6)
        % HVRT - 120% - 10sec
        x_end = 20;
    else
        x_end = 9;
    end
    

    figure('Visible', PlotVisibleOrNot)
    disp('Plotting U')
    plot(t1,v1,'b',t2,v2,'r','LineWidth',4)
    grid on;
    legend(texlabel('U_{HIL}'),texlabel('U_{DL}'), 'Location', 'best');
    set(gca,'FontSize',18,'FontWeight','bold');
    xlabel('t/s','fontsize',20);
    ylabel('U/Un','fontsize',20);
    axis_backup_1=axis;
    axis([0.1 x_end axis_backup_1(3:4)]);

    file_name = strcat(dir_name, '\U.fig');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\U.emf');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\U.png');  
    saveas(gca, file_name)
    close



    figure('Visible', PlotVisibleOrNot)
    disp('Plotting P')
    plot(t1,pe1,'b',t2,pe2,'r','LineWidth',4)
    grid on;
    legend(texlabel('P_{HIL}'),texlabel('P_{DL}'), 'Location', 'best');
    set(gca,'FontSize',18,'FontWeight','bold');
    xlabel('t/s','fontsize',20);
    ylabel('P/Pn','fontsize',20);
    axis_backup_1=axis;
    axis([0.1 x_end axis_backup_1(3:4)]);

    file_name = strcat(dir_name, '\P.fig');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\P.emf');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\P.png');  
    saveas(gca, file_name)
    close


    figure('Visible', PlotVisibleOrNot)
    disp('Plotting Q')
    plot(t1,qe1,'b',t2,qe2,'r','LineWidth',4)
    grid on;
    legend(texlabel('Q_{HIL}'),texlabel('Q_{DL}'), 'Location', 'best');
    set(gca,'FontSize',18,'FontWeight','bold');
    xlabel('t/s','fontsize',20);
    ylabel('Q/Qn','fontsize',20);
    axis_backup_1=axis;
    axis([0.1 x_end axis_backup_1(3:4)]);

    file_name = strcat(dir_name, '\Q.fig');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\Q.emf');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\Q.png');  
    saveas(gca, file_name)
    close


    figure('Visible', PlotVisibleOrNot)
    disp('Plotting Ip')
    plot(t1,ip1,'b',t2,ip2,'r','LineWidth',4)
    grid on;
    legend(texlabel('Ip_{HIL}'),texlabel('Ip_{DL}'), 'Location', 'best');
    set(gca,'FontSize',18,'FontWeight','bold');
    xlabel('t/s','fontsize',20);
    ylabel('Ip/In','fontsize',20);
    axis_backup_1=axis;
    axis([0.1 x_end axis_backup_1(3:4)]);

    file_name = strcat(dir_name, '\Ip.fig');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\Ip.emf');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\Ip.png');  
    saveas(gca, file_name)
    close


    figure('Visible', PlotVisibleOrNot)
    disp('Plotting Iq')
    plot(t1,iq1,'b',t2,iq2,'r','LineWidth',4)
    grid on;
    legend(texlabel('Iq_{HIL}'),texlabel('Iq_{DL}'), 'Location', 'best');
    set(gca,'FontSize',18,'FontWeight','bold');
    xlabel('t/s','fontsize',20);
    ylabel('Iq/In','fontsize',20);
    axis_backup_1=axis;
    axis([0.1 x_end axis_backup_1(3:4)]);

    file_name = strcat(dir_name, '\Iq.fig');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\Iq.emf');  
    saveas(gca, file_name)
    file_name = strcat(dir_name, '\Iq.png');  
    saveas(gca, file_name)
    close

%     break

end
toc
disp('Done')


