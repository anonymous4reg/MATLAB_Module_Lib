% user setting here
VarNamePrefix = "opvar";
t_range = 15;
sub_folder_dir = '.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   Don't change here if you don't know what it is.   %%%%%%
var_name_found = who;
var_name_found = var_name_found(~cellfun(@isempty, regexpi(var_name_found, strcat(VarNamePrefix, '.*'))));
if length(var_name_found) == 1
    data_1 = eval(var_name_found{1});
else
    raise
end
%%%%%%%%%%%%%%%%%%%%%%%% Some handy funcs  %%%%%%%%%%%%%%%%%%%%%%
% standard test funcs for LHVRT
hf = @(x) 1.5*(x-1.1);
lf = @(x) 1.5*(0.9-x);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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


figure
plot(t, Q_pu_690V,'r','LineWidth',3)
grid on;
legend('Q+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('Q/Pn','fontsize',20);
axis_backup_1=axis;
axis([0 t_range axis_backup_1(3:4)]);

figure
plot(t, Ip_pu_690V,'r','LineWidth',3)
grid on;
legend('Ip+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('Ip/In','fontsize',20);
axis_backup_1=axis;
axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq35+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq35+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq35+.png') )



figure
plot(t, P_pu_690V,'r','LineWidth',3)
grid on;
legend('P+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('P/Qn','fontsize',20);
axis_backup_1=axis;
axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.png') )


figure
plot(t,V_pu_690V,'r','LineWidth',3)
grid on;
legend('U+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('U/Un','fontsize',20);
axis_backup_1=axis;
axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'U35+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'U35+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'U35+.png') )

% 
% figure
% plot(t,V230,'r','LineWidth',3)
% grid on;
% legend('U230+');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('U/Un','fontsize',20);
% axis_backup_1=axis;
% axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'U230+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'U230+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'U230+.png') )

% figure
% plot(t, Q230,'r','LineWidth',3)
% grid on;
% legend('Q230+');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('Q/Qn','fontsize',20);
% axis_backup_1=axis;
% axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'Q230+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Q230+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Q230+.png') )

% figure
% plot(t, Iq230,'r','LineWidth',3)
% grid on;
% legend('Iq230+');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('I/In','fontsize',20);
% axis_backup_1=axis;
% axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq230+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq230+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq230+.png') )



% save(strcat(sub_folder_dir, '\', 'data_t'), 't');
% save(strcat(sub_folder_dir, '\', 'data_u35'), 'V35');
% save(strcat(sub_folder_dir, '\', 'data_Q35'), 'Q35');
% save(strcat(sub_folder_dir, '\', 'data_Iq35'), 'Iq35');
% save(strcat(sub_folder_dir, '\', 'data_u230'), 'V230');
% save(strcat(sub_folder_dir, '\', 'data_Q230'), 'Q230');
% save(strcat(sub_folder_dir, '\', 'data_Iq230'), 'Iq230');

% clear;clc