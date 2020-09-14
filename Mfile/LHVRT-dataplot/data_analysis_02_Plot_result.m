% figure
% plot(t,va,t,vb,t,vc);
% % figure;plot(t,vab,t,vbc,t,vca);
% figure
% plot(t,ia,t,ib,t,ic);

% figure
% plot(t,vdc);
% figure
% plot(t,igsca,t,igscb,t,igscc);
% figure
% plot(t,irsca,t,irscb,t,irscc);
Unom = 690;  % Volt
Sn = 4.2e6;  % VA


t1 = Pe1lv.time;
pe1 = Pe1lv.signals.values;
qe1 = Qe1lv.signals.values;
pe1 = pe1./Sn;%ั๔นโ
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
saveas(gca, 'U1+.fig')
saveas(gca, 'U1+.emf')
saveas(gca, 'U1+.png')
% figure
% plot(t1,v1_pp,t1,v1_nn,t1,v1_zz)
% grid on;
% legend('v1_p','v1_n','v1_zz');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('v1_p,v1_n,v1_z','fontsize',20);
figure
plot(t1,pe1,'b',t1,qe1,'r','LineWidth',3)
grid on;
legend('P1+','Q1+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('P/Pn,Q/Qn','fontsize',20);
axis_backup_1=axis;
axis([0 20 axis_backup_1(3:4)]);
saveas(gca, 'PQ+.fig')
saveas(gca, 'PQ+.emf')
saveas(gca, 'PQ+.png')


figure
plot(t1,ip1,'b',t1,iq1,'r','LineWidth',3)
grid on;
legend('Ip1+','Iq1+');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('I/In','fontsize',20);
axis_backup_1=axis;
axis([0 20 axis_backup_1(3:4)]);
saveas(gca, 'IpIq+.fig')
saveas(gca, 'IpIq+.emf')
saveas(gca, 'IpIq+.png')

save data_t t1;
save data_u v1;
save data_P pe1;
save data_Q qe1;
save data_Ip ip1;
save data_Iq iq1;

