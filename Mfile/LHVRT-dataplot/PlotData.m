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

figure
plot(t,V35,'r','LineWidth',4)
grid on;
legend('35kV电压');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('U/pu','fontsize',20);
title('35kV电压');

figure
plot(t,Q35,'r','LineWidth',4)
grid on;
legend('SVG无功功率');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('Q/pu','fontsize',20);
title('SVG无功功率');

figure
plot(t,Iq35,'r','LineWidth',4)
grid on;
legend('SVG无功电流');
set(gca,'FontSize',18,'FontWeight','bold');
xlabel('t/s','fontsize',20);
ylabel('Iq/pu','fontsize',20);
title('SVG无功电流');



% figure
% plot(t,va220,t,vb220,t,vc220);
% 
% figure
% plot(t,va35,t,vb35,t,vc35);
% % % 
% figure
% plot(t,Vdca,t,Vdcb,t,Vdcc);
% % % 
% % figure
% % plot(t,vab35,t,vbc35,t,vca35);
% % 
% % figure
% figure
% plot(t,Ia35,t,Ib35,t,Ic35);
% t1=Pe110.time;
% t1=t1;
% % t1=0.02:0.0001:12;
% P_110=Pe110.signals.values/1000000;%MW
% Q_110=Qe110.signals.values/1000000;%Mvar
% %
% P_SVG=P_SVG.signals.values;%MW
% Q_SVG=Q_SVG.signals.values/1000000;%Mvar
% % Iq_SVG=Iq_SVG.signals.values;%A
% %
% v110=V_110kV.signals.values;
% v110=v110./1000/sqrt(2);%kV
% % v111=v110(2100,:);
% % t2=t1(2100,:);
% %
% v35=V_35kV.signals.values;
% v35_pu=v35./36500/sqrt(2);%kV
% 
% Iq_SVG=(1000000*sqrt(2/3)).*Q_SVG./v35;
% vab35_rms=vab35RMS.signals.values/1000;
% % vbc35_rms=vab35RMS.signals.values;
% % vca35_rms=vab35RMS.signals.values;
% 
% vab110_rms=vab110RMS.signals.values/1000;
% % vbc110_rms=vbc110RMS.signals.values;
% % vca110_rms=vca110RMS.signals.values;
% 
% %U35kV  U+
% % figure
% % plot(t1,v35_pu,'r','LineWidth',4)
% % grid on;
% % legend('35kV母线电压正序');
% % set(gca,'FontSize',18,'FontWeight','bold');
% % xlabel('t/s','fontsize',20);
% % ylabel('U/Un','fontsize',20);
% 
% %SVG Qout
% figure
% plot(t1,Q_SVG,'r','LineWidth',4)
% grid on;
% legend('SVG无功功率');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('Q/Mvar','fontsize',20);
% title('SVG无功功率');
% 
% %SVG Iq
% % figure
% % plot(t1,Iq_SVG,'r','LineWidth',4)
% % grid on;
% % legend('SVG无功电流');
% % set(gca,'FontSize',18,'FontWeight','bold');
% % xlabel('t/s','fontsize',20);
% % ylabel('Iq/A','fontsize',20);
% 
% %
% % figure
% % plot(t,Vdca,t,Vdcb,t,Vdcc,'LineWidth',4)
% % grid on;
% % legend('直流母线电压');
% % set(gca,'FontSize',18,'FontWeight','bold');
% % xlabel('t/s','fontsize',20);
% % ylabel('Udc/V','fontsize',20);
% 
% % %
% figure
% plot(t1,v110,'LineWidth',4)
% grid on;
% legend('110kV电压有效值');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('Uabc/kV','fontsize',20);
% title('风电场并网点电压');
% % axis([0 12 36 37]);
% % 
% % %
% % figure
% % plot(t1,vab35_rms,'LineWidth',4)
% % grid on;
% % legend('35kV电压有效值');
% % set(gca,'FontSize',18,'FontWeight','bold');
% % xlabel('t/s','fontsize',20);
% % ylabel('Uab/kV','fontsize',20);
% 
% 
% %windfarm Pout
% figure
% plot(t1,P_110,t1,Q_110,'r','LineWidth',4)
% grid on;
% legend('P/MW');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('P/MW','fontsize',20);
% title('风电场有功/无功功率');
% 
% figure
% plot(t1,Q_SVG,'r',t1,v110,'g','LineWidth',4)
% grid on;
% legend('SVG无功功率');
% set(gca,'FontSize',18,'FontWeight','bold');
% xlabel('t/s','fontsize',20);
% ylabel('Q/Mvar','fontsize',20);
% title('SVG无功功率');
