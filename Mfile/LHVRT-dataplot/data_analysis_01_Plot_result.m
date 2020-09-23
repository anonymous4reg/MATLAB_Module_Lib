% user setting here
VarNamePrefix = "data";
t_range = 30;
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
hf = @(x) 1.5*(x-1.1);
lf = @(x) 1.5*(0.9-x);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
V230=data_1(20,:);
Q230=data_1(21,:);
Iq230=data_1(22,:);

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
V230=V230';
Q230=Q230';
Iq230=Iq230';


figure
plot(t,V35,'r','LineWidth',3)
grid on;
legend('U35+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('U/Un','fontsize',20);
axis_backup_1=axis;
axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'U35+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'U35+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'U35+.png') )

figure
plot(t, Q35,'r','LineWidth',3)
grid on;
legend('Q35+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('Q/Qn','fontsize',20);
axis_backup_1=axis;
axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Q35+.png') )

figure
plot(t, Iq35,'r','LineWidth',3)
grid on;
legend('Iq35+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('I/In','fontsize',20);
axis_backup_1=axis;
axis([0 t_range axis_backup_1(3:4)]);
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq35+.fig') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq35+.emf') )
% saveas( gca, strcat(sub_folder_dir, '\', 'Iq35+.png') )

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