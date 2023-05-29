function  [ZP3,ZN3] = ScanImpedance2plusV5(Freq_begin,Freq_end,Freq_step,Ip1,Vp1,Ip_coupled1,Vp_coupled1,Ip2,Vp2,Ip_coupled2,Vp_coupled2)

% Freq_begin=1;
% Freq_end=100;
% Freq_step=1;

% load DATA_ZPD;
% ZP690=ZPD;
% ZP_scanSISO=ZP690([1:100],:);

% load Ip1;
% load Vp1;
% load Ip_coupled1;
% load Vp_coupled1;
% load Ip2;
% load Vp2;
% load Ip_coupled2;
% load Vp_coupled2;

f_start=Freq_begin;
f_end=Freq_end-1;
f_step=Freq_step;

f_num=(f_end-f_start)/f_step+1;

ZP3=zeros(f_num,3);
ZN3=zeros(f_num,3);
Zp_2by2 = zeros(2,2,f_num);
for ff=f_start:f_step:f_end   
    ff_coupled=2*50-ff;
    ff_num=(ff-f_start)/f_step+1; %��1��ʼ
    ff_num_coupled=(ff_coupled-f_start)/f_step+1; %��1��ʼ
    
    Zp_2by2(:,:,ff_num)=[Vp1(ff_num),Vp2(ff_num);conj(Vp_coupled1(ff_num)),conj(Vp_coupled2(ff_num))]*inv([Ip1(ff_num),Ip2(ff_num);conj(Ip_coupled1(ff_num)),conj(Ip_coupled2(ff_num))]);
    Zp_II(:,:,ff_num)=Zp_2by2(2,2,ff_num); 
    
    Zp11(ff_num)=Zp_2by2(1,1,ff_num);
    Zp12(ff_num)=Zp_2by2(1,2,ff_num);
    Zp21(ff_num)=Zp_2by2(2,1,ff_num);
    Zp22(ff_num)=Zp_2by2(2,2,ff_num);
    
    ZP(ff_num)=Zp11(ff_num)-Zp12(ff_num)*Zp21(ff_num)/Zp22(ff_num);
    ZN(ff_num)=Zp22(ff_num)-Zp12(ff_num)*Zp21(ff_num)/Zp11(ff_num);
    ZPshizai(ff_num)=Vp1(ff_num)/Ip1(ff_num);
    
    ZP_phase=angle(ZP(ff_num))*180/pi;
    if ZP_phase<-150
        ZP_phase = ZP_phase + 360;
    end
    if ZP_phase>210
        ZP_phase = ZP_phase - 360;
    end 
    ZP3(ff_num,:) = [ff,abs(ZP(ff_num)), ZP_phase];
    
    ZN_phase=angle(ZN(ff_num))*180/pi;
    if ZN_phase<-150
        ZN_phase = ZN_phase + 360;
    end
    if ZN_phase>210
        ZN_phase = ZN_phase - 360;
    end 
    ZN3(ff_num,:) = [ff-100,abs(ZN(ff_num)), ZN_phase];

%     ZP11_phase=angle(Zp11(ff_num))*180/pi;
%     if ZP11_phase<-150
%         ZP11_phase = ZP11_phase + 360;
%     end
%     if ZP11_phase>210
%         ZP11_phase = ZP11_phase - 360;
%     end 
%     ZP113(ff_num,:) = [ff,abs(Zp11(ff_num)), ZP11_phase];
% 
%     ZP12_phase=angle(Zp12(ff_num))*180/pi;
%     if ZP12_phase<-150
%         ZP12_phase = ZP12_phase + 360;
%     end
%     if ZP12_phase>210
%         ZP12_phase = ZP12_phase - 360;
%     end 
%     ZP123(ff_num,:) = [ff,abs(Zp12(ff_num)), ZP12_phase];
%     
%     ZP21_phase=angle(Zp21(ff_num))*180/pi;
%     if ZP21_phase<-150
%         ZP21_phase = ZP21_phase + 360;
%     end
%     if ZP21_phase>210
%         ZP21_phase = ZP21_phase - 360;
%     end 
%     ZP213(ff_num,:) = [ff,abs(Zp21(ff_num)), ZP21_phase];
% 
%     ZP22_phase=angle(Zp22(ff_num))*180/pi;
%     if ZP22_phase<-150
%         ZP22_phase = ZP22_phase + 360;
%     end
%     if ZP22_phase>210
%         ZP22_phase = ZP22_phase - 360;
%     end 
%     ZP223(ff_num,:) = [ff,abs(Zp22(ff_num)), ZP22_phase];
    
%     ZPshizai_phase=angle(ZPshizai(ff_num))*180/pi;
%     if ZPshizai_phase<-150
%         ZPshizai_phase = ZPshizai_phase + 360;
%     end
%     if ZPshizai_phase>210
%         ZPshizai_phase = ZPshizai_phase - 360;
%     end 
%     ZPshizai3(ff_num,:) = [ff,abs(ZPshizai(ff_num)), ZPshizai_phase];
    
end
% save Zp_II Zp_II;
% save ZP ZP;
% save ZP3 ZP3;
% 
% save Zp11 Zp11;
% save ZP113 ZP113;
% save Zp12 Zp12;
% save ZP123 ZP123;
% 
% save Zp21 Zp21;
% save ZP213 ZP213;
% save Zp22 Zp22;
% save ZP223 ZP223;
% 
% for ff=f_start:f_step:f_end   
%     ZP3_RX(ff,1)=ZP3(ff,1);
%     ZP3_RX(ff,2)=ZP3(ff,2)*sin(ZP3(ff,3)/180*pi);
%     ZP3_RX(ff,3)=ZP3(ff,2)*cos(ZP3(ff,3)/180*pi);    
% 
%     ZP113_RX(ff,1)=ZP113(ff,1);
%     ZP113_RX(ff,2)=ZP113(ff,2)*sin(ZP113(ff,3)/180*pi);
%     ZP113_RX(ff,3)=ZP113(ff,2)*cos(ZP113(ff,3)/180*pi);    
% 
%     ZP123_RX(ff,1)=ZP123(ff,1);
%     ZP123_RX(ff,2)=ZP123(ff,2)*sin(ZP123(ff,3)/180*pi);
%     ZP123_RX(ff,3)=ZP123(ff,2)*cos(ZP123(ff,3)/180*pi);    
% 
%     ZP213_RX(ff,1)=ZP213(ff,1);
%     ZP213_RX(ff,2)=ZP213(ff,2)*sin(ZP213(ff,3)/180*pi);
%     ZP213_RX(ff,3)=ZP213(ff,2)*cos(ZP213(ff,3)/180*pi);    
% 
%     ZP223_RX(ff,1)=ZP223(ff,1);
%     ZP223_RX(ff,2)=ZP223(ff,2)*sin(ZP223(ff,3)/180*pi);
%     ZP223_RX(ff,3)=ZP223(ff,2)*cos(ZP223(ff,3)/180*pi);    
% end

% ZP_shizai=ZP690([1:99],:);
% figure
% subplot(2,1,1);
% plot(ZP3(:,1),20*log(ZP3(:,2)),'r',ZP_shizai(:,1),20*log(ZP_shizai(:,2)));
% xlabel('Ƶ��(Hz)');
% ylabel('��ֵ(dB)');
% subplot(2,1,2);
% plot(ZP3(:,1),ZP3(:,3),'r',ZP_shizai(:,1),ZP_shizai(:,3));
% xlabel('Ƶ��(Hz)');
% ylabel('���(��)');

% % % figure
% % % subplot(2,1,1);
% % % plot(ZP3(:,1),ZP3(:,2),'r',ZPshizai3(:,1),ZPshizai3(:,2),'b',ZP113(:,1),ZP113(:,2),'g',ZP123(:,1),ZP123(:,2),'y',ZP213(:,1),ZP213(:,2),'m',ZP223(:,1),ZP223(:,2),'c',ZP_scanSISO(:,1),ZP_scanSISO(:,2),'k');
% % % ylim([-1,7]);
% % % grid on;
% % % legend('Ƶ�������迹Zp','���������迹Zp','Ƶ���迹Zp11','Ƶ���迹Zp12','Ƶ���迹Zp21','Ƶ���迹Zp22','ԭ��Ƶ�迹Zp');
% % % xlabel('Ƶ��(Hz)');
% % % ylabel('��ֵ(om)');
% % % subplot(2,1,2);
% % % plot(ZP3(:,1),ZP3(:,3),'r',ZPshizai3(:,1),ZPshizai3(:,3),'b',ZP113(:,1),ZP113(:,3),'g',ZP123(:,1),ZP123(:,3),'y',ZP213(:,1),ZP213(:,3),'m',ZP223(:,1),ZP223(:,3),'c',ZP_scanSISO(:,1),ZP_scanSISO(:,3),'k');
% % % grid on;
% % % legend('Ƶ�������迹Zp','���������迹Zp','Ƶ���迹Zp11','Ƶ���迹Zp12','Ƶ���迹Zp21','Ƶ���迹Zp22','ԭ��Ƶ�迹Zp');
% % % xlabel('Ƶ��(Hz)');
% % % ylabel('���(��)');
% % % saveas(gca, 'Ƶ���Ƶ��Ա�����_7��.fig')
% % % saveas(gca, 'Ƶ���Ƶ��Ա�����_7��.emf')
% % % saveas(gca, 'Ƶ���Ƶ��Ա�����_7��.png')
% % % 
figure
subplot(2,1,1);
plot(ZP3(:,1),20*log10(ZP3(:,2)),'r');
% ylim([-1,7]);
grid on;
legend('Ƶ�������迹Zp');
xlabel('Ƶ��(Hz)');
ylabel('��ֵ(om)');
subplot(2,1,2);
plot(ZP3(:,1),ZP3(:,3),'r');
grid on;
legend('Ƶ�������迹Zp');
xlabel('Ƶ��(Hz)');
ylabel('���(��)');
saveas(gca, 'Ƶ������.fig')
saveas(gca, 'Ƶ������.tiff')
% saveas(gca, 'Ƶ��.emf')

figure
subplot(2,1,1);
plot(ZN3(:,1),20*log10(ZN3(:,2)),'r');
% ylim([-1,7]);
grid on;
legend('Ƶ����迹Zn');
xlabel('Ƶ��(Hz)');
ylabel('��ֵ(om)');
subplot(2,1,2);
plot(ZN3(:,1),ZN3(:,3),'r');
grid on;
legend('Ƶ����迹Zn');
xlabel('Ƶ��(Hz)');
ylabel('���(��)');
saveas(gca, 'Ƶ���.fig')
saveas(gca, 'Ƶ���.tiff')
% figure
% subplot(2,1,1);
% plot(ZP113(:,1),ZP113(:,2),'g',ZP123(:,1),ZP123(:,2),'y',ZP213(:,1),ZP213(:,2),'m',ZP223(:,1),ZP223(:,2),'c');
% % ylim([-0.1,0.4]);
% grid on;
% legend('Ƶ���迹Zp11','Ƶ���迹Zp12','Ƶ���迹Zp21','Ƶ���迹Zp22');
% xlabel('Ƶ��(Hz)');
% ylabel('��ֵ(om)');
% subplot(2,1,2);
% plot(ZP113(:,1),ZP113(:,3),'g',ZP123(:,1),ZP123(:,3),'y',ZP213(:,1),ZP213(:,3),'m',ZP223(:,1),ZP223(:,3),'c');
% grid on;
% legend('Ƶ���迹Zp11','Ƶ���迹Zp12','Ƶ���迹Zp21','Ƶ���迹Zp22');
% xlabel('Ƶ��(Hz)');
% ylabel('���(��)');
% saveas(gca, 'Ƶ���ά�迹4������.fig')
% saveas(gca, 'Ƶ���ά�迹4������.emf')
% saveas(gca, 'Ƶ���ά�迹4������.png')

% % % %RX
% % % figure
% % % subplot(2,1,1);
% % % plot(ZP3_RX(:,1),ZP3_RX(:,2),'r',ZP113_RX(:,1),ZP113_RX(:,2),'g',ZP123_RX(:,1),ZP123_RX(:,2),'y',ZP213_RX(:,1),ZP213_RX(:,2),'m',ZP223_RX(:,1),ZP223_RX(:,2),'c');
% % % % ylim([-0.1,0.4]);
% % % grid on;
% % % legend('Ƶ�������迹Zp','Ƶ���迹Zp11','Ƶ���迹Zp12','Ƶ���迹Zp21','Ƶ���迹Zp22');
% % % xlabel('Ƶ��(Hz)');
% % % ylabel('�翹(om)');
% % % subplot(2,1,2);
% % % plot(ZP3_RX(:,1),ZP3_RX(:,3),'r',ZP113_RX(:,1),ZP113_RX(:,3),'g',ZP123_RX(:,1),ZP123_RX(:,3),'y',ZP213_RX(:,1),ZP213_RX(:,3),'m',ZP223_RX(:,1),ZP223_RX(:,3),'c');
% % % grid on;
% % % legend('Ƶ�������迹Zp','Ƶ���迹Zp11','Ƶ���迹Zp12','Ƶ���迹Zp21','Ƶ���迹Zp22');
% % % xlabel('Ƶ��(Hz)');
% % % ylabel('����(om)');
% % % % saveas(gca, 'Ƶ���ά�迹4������.fig')
% % % % saveas(gca, 'Ƶ���ά�迹4������.emf')
% % % % saveas(gca, 'Ƶ���ά�迹4������.png')


% figure
% subplot(2,1,1);
% plot(ZP3(:,1),20*log(ZP3(:,2)));
% xlabel('Ƶ��(Hz)');
% ylabel('��ֵ(dB)');
% subplot(2,1,2);
% plot(ZP3(:,1),ZP3(:,3));
% xlabel('Ƶ��(Hz)');
% ylabel('���(��)');
% 
% figure
% subplot(2,1,1);
% plot(ZP113(:,1),20*log(ZP113(:,2)));
% xlabel('Ƶ��(Hz)');
% ylabel('��ֵ(dB)');
% subplot(2,1,2);
% plot(ZP113(:,1),ZP113(:,3));
% xlabel('Ƶ��(Hz)');
% ylabel('���(��)');
% 
% figure
% subplot(2,1,1);
% plot(ZP123(:,1),20*log(ZP123(:,2)));
% xlabel('Ƶ��(Hz)');
% ylabel('��ֵ(dB)');
% subplot(2,1,2);
% plot(ZP123(:,1),ZP123(:,3));
% xlabel('Ƶ��(Hz)');
% ylabel('���(��)');



% saveas(gca, 'ZukangScanBode_pp.fig')
% saveas(gca, 'ZukangScanBode_pp.emf')
% saveas(gca, 'ZukangScanBode_pp.png')


