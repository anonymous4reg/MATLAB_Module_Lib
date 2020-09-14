input_file_split = strsplit(input_file, '\');
input_file_split = input_file_split(1:end-1);
input_file_root_dir = join(input_file_split, '\');
input_file_root_dir = input_file_root_dir{1};

outputArg1 = input_file_root_dir;
load(input_file)

% file_input
% User input para here!!!
Vrms_ph_hv = 37e3;  % 没啥p用，可以乱填，但不可以不填
Vrms_ph_lv = 690;  % 没啥p用，可以乱填，但不可以不填
Ts = 20e-6;


% Don't change below if you don't know what it is.
t=opvar(1,:);
t=t-t(1);
t=t';

% High voltage side
vahv=opvar(2,:)';
vbhv=opvar(3,:)';
vchv=opvar(4,:)';

iahv=-opvar(5,:)';
ibhv=-opvar(6,:)';
ichv=-opvar(7,:)';

vabhv = vahv - vbhv;
vbchv = vbhv - vchv;
vcahv = vchv - vahv;


% Low voltage side
valv=opvar(8,:)';
vblv=opvar(9,:)';
vclv=opvar(10,:)';

ialv=-opvar(11,:)';
iblv=-opvar(12,:)';
iclv=-opvar(13,:)';

vablv = valv - vblv;
vbclv = vblv - vclv;
vcalv = vclv - valv;


warning('off', 'all')
% Sim and plot
sim('RTLAB_Sim_HVandLV',20);


Unom = 690;  % Volt
Sn = 4.2e6;  % VA


t1 = Pe1lv.time;
pe1 = Pe1lv.signals.values;
qe1 = Qe1lv.signals.values;
pe1 = pe1./Sn;%阳光
qe1 = qe1./Sn;
v1 =Vabct1lv.signals.values;
v1 =v1./Unom/sqrt(2);


ip1=Ip1lv.signals.values;
ip1=ip1./(Sn/Unom/sqrt(3));
iq1=Iq1lv.signals.values;
iq1=iq1./(Sn/Unom/sqrt(3));



figure
plot(t1,v1,'r','LineWidth',3)
grid on;
legend('U1+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('U/Un','fontsize',20);
axis_backup_1=axis;
axis([0 20 axis_backup_1(3:4)]);
saveas( gca, strcat(input_file_root_dir, '\', 'U1+.fig') )
saveas( gca, strcat(input_file_root_dir, '\', 'U1+.emf') )
saveas( gca, strcat(input_file_root_dir, '\', 'U1+.png') )

figure
plot(t1,pe1,'b',t1,qe1,'r','LineWidth',3)
grid on;
legend('P1+','Q1+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('P/Pn,Q/Qn','fontsize',20);
axis_backup_1=axis;
axis([0 20 axis_backup_1(3:4)]);
saveas( gca, strcat(input_file_root_dir, '\', 'PQ+.fig') )
saveas( gca, strcat(input_file_root_dir, '\', 'PQ+.emf') )
saveas( gca, strcat(input_file_root_dir, '\', 'PQ+.png') )

figure
plot(t1,ip1,'b',t1,iq1,'r','LineWidth',3)
grid on;
legend('Ip1+','Iq1+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('I/In','fontsize',20);
axis_backup_1=axis;
axis([0 20 axis_backup_1(3:4)]);
saveas( gca, strcat(input_file_root_dir, '\', 'IpIq+.fig') )
saveas( gca, strcat(input_file_root_dir, '\', 'IpIq+.emf') )
saveas( gca, strcat(input_file_root_dir, '\', 'IpIq+.png') )

save(strcat(input_file_root_dir, '\', 'data_t'), 't1');
save(strcat(input_file_root_dir, '\', 'data_u'), 'v1');
save(strcat(input_file_root_dir, '\', 'data_P'), 'pe1');
save(strcat(input_file_root_dir, '\', 'data_Q'), 'qe1');
save(strcat(input_file_root_dir, '\', 'data_Ip'), 'ip1');
save(strcat(input_file_root_dir, '\', 'data_Iq'), 'iq1');

close all

