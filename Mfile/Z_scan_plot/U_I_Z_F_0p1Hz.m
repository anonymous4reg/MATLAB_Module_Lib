% close all
% clear
% clc
% load('Hfile_6.mat')
% scan_0 = Hscan_6;

clear;clc;close all
NN=50000;%%跟采样点数有关
N=NN*10;


f_start=1;
f_step = 0.1;
f_end=1.2;

%% test begin
TS = 1/NN;
TSPAN = 10;
TRest = 1;
uabc = [];
iabc = [];
scan_data = [];

harm_f = 1.1;
T_POINT = 1;
for ff = f_start:f_step:f_end
    fprintf("Freq = %f\n", ff)
    t_disturb = [T_POINT:TSPAN*NN+T_POINT-1];
    t_disturb = t_disturb';
    t_rest = t_disturb(end) + [1:TRest*NN];
    t_rest = t_rest';

    t_disturb = TS* t_disturb;
    t_rest = t_rest *TS;
    t_vector = [t_disturb; t_rest];

%     tmpuabc_disturb = [0.01*sin(ff*2*pi*t_disturb) + sin(100*pi*t_disturb), ...
%                        0.01*sin(ff*2*pi*t_disturb - 2*pi/3) + sin(100*pi*t_disturb - 2*pi/3), ...
%                        0.01*sin(ff*2*pi*t_disturb + 2*pi/3) + sin(100*pi*t_disturb + 2*pi/3)];
%     tmpiabc_disturb = 0.2*[sin(ff*2*pi*t_disturb), sin(ff*2*pi*t_disturb - 2*pi/3), sin(ff*2*pi*t_disturb + 2*pi/3)];
    tmpuabc_disturb = [sin(harm_f*2*pi*t_disturb), ...
                       sin(harm_f*2*pi*t_disturb - 2*pi/3), ...
                       sin(harm_f*2*pi*t_disturb + 2*pi/3)] + ...
                 10*[sin(ff*2*pi*t_disturb), ...
                       sin(ff*2*pi*t_disturb - 2*pi/3), ...
                       sin(ff*2*pi*t_disturb + 2*pi/3)];
    tmpiabc_disturb = 0.02*[sin(ff*2*pi*t_disturb), sin(ff*2*pi*t_disturb - 2*pi/3), sin(ff*2*pi*t_disturb + 2*pi/3)] + ...
                    10*[sin(harm_f*2*pi*t_disturb), sin(harm_f*2*pi*t_disturb - 2*pi/3), sin(harm_f*2*pi*t_disturb + 2*pi/3)];

    tmpuabc_rest = zeros(NN*TRest, 3);
    tmpiabc_rest = zeros(NN*TRest, 3);

    tmpuabc = [tmpuabc_disturb; tmpuabc_rest];
    tmpiabc = [tmpiabc_disturb; tmpiabc_rest];

    uabc = [uabc; tmpuabc];
    iabc = [iabc; tmpiabc];
    tmpdata = [t_vector, t_vector, tmpuabc, tmpiabc];
    scan_data = [scan_data; tmpdata];
    T_POINT = T_POINT + (TSPAN + TRest)*NN;
    
end
figure
pt = scan_data(:, 1);
puabc = scan_data(:, 3:5);
piabc = scan_data(:, 6:8);
plot(scan_data(:, 1), puabc(:, 1), 'b')
hold on
plot(scan_data(:, 1), puabc(:, 2), 'g')
plot(scan_data(:, 1), puabc(:, 3), 'r')
set(gca, 'ylim', [-2, 2])
%% test end
scan_0 = scan_data';

ZP=zeros(int64((f_end-f_start)/f_step)+1,3);
ZN=zeros(int64((f_end-f_start)/f_step)+1,3);

FF_VECTOR = f_start:f_step:f_end;
for ffidx = 1:length(FF_VECTOR)   
    ff = FF_VECTOR(ffidx);


TT=scan_0(1,(int64((ff-f_start)/f_step)*(NN)+1):(int64((ff-f_start)/f_step)*(NN)+N) );

UA=scan_0(3,(int64((ff-f_start)/f_step)*(NN)+1):(int64((ff-f_start)/f_step)*(NN)+N) );
UB=scan_0(4,(int64((ff-f_start)/f_step)*(NN)+1):(int64((ff-f_start)/f_step)*(NN)+N) );
UC=scan_0(5,(int64((ff-f_start)/f_step)*(NN)+1):(int64((ff-f_start)/f_step)*(NN)+N) );

IA=-scan_0(6,(int64((ff-f_start)/f_step)*(NN)+1):(int64((ff-f_start)/f_step)*(NN)+N) );
IB=-scan_0(7,(int64((ff-f_start)/f_step)*(NN)+1):(int64((ff-f_start)/f_step)*(NN)+N) );
IC=-scan_0(8,(int64((ff-f_start)/f_step)*(NN)+1):(int64((ff-f_start)/f_step)*(NN)+N) );



Uas=zeros(1,(N ));
Uas_mag=zeros(1,1);
Uas_phase=zeros(1,1);

 
% 变量定义
Uas=zeros(1,(N ));
Ubs=zeros(1,(N ));
Ucs=zeros(1,(N ));
Ias=zeros(1,(N ));
Ibs=zeros(1,(N ));
Ics=zeros(1,(N ));
Uas_mag=zeros(1,1);
Uas_phase=zeros(1,1);
Ias_mag=zeros(1,1);
Ias_phase=zeros(1,1);
Ubs_mag=zeros(1,1);
Ubs_phase=zeros(1,1);
Ibs_mag=zeros(1,1);
Ibs_phase=zeros(1,1);
Ucs_mag=zeros(1,1);
Ucs_phase=zeros(1,1);
Ics_mag=zeros(1,1);
Ics_phase=zeros(1,1);



Uas=UA;
Ubs=UB;
Ucs=UC;

Ias=IA;
Ibs=IB;
Ics=IC;

% Uas_fft=fft(Uas(1,:));
% magUas = abs(Uas_fft/N);
% magUas = magUas(1:N/2);
% magUas(2:end-1) = 2*magUas(2:end-1);
% phaseUas = angle(Uas_fft);
% Uas_mag = magUas(2*ff+1)
% Uas_phase = phaseUas(2*ff+1)

    Uas_fft=fft(Uas(1,:));
    magUas = abs(Uas_fft/(N ));
    magUas = magUas(1:(N )/2);
    magUas(2:end-1) = 2*magUas(2:end-1);
    phaseUas = angle(Uas_fft);
    Ias_fft=fft(Ias(1,:));
    magIas = abs(Ias_fft/(N ));
    magIas = magIas(1:(N )/2);
    magIas(2:end-1) = 2*magIas(2:end-1);
    phaseIas = angle(Ias_fft);    
 
    Ubs_fft=fft(Ubs(1,:));
    magUbs = abs(Ubs_fft/(N ));
    magUbs = magUbs(1:(N )/2);
    magUbs(2:end-1) = 2*magUbs(2:end-1);
    phaseUbs = angle(Ubs_fft);
    Ibs_fft=fft(Ibs(1,:));
    magIbs = abs(Ibs_fft/(N ));
    magIbs = magIbs(1:(N )/2);
    magIbs(2:end-1) = 2*magIbs(2:end-1);
    phaseIbs = angle(Ibs_fft); 
    
    Ucs_fft=fft(Ucs(1,:));
    magUcs = abs(Ucs_fft/(N ));
    magUcs = magUcs(1:(N )/2);
    magUcs(2:end-1) = 2*magUcs(2:end-1);
    phaseUcs = angle(Ucs_fft);
    Ics_fft=fft(Ics(1,:));
    magIcs = abs(Ics_fft/(N ));
    magIcs = magIcs(1:(N )/2);
    magIcs(2:end-1) = 2*magIcs(2:end-1);
    phaseIcs = angle(Ics_fft);   
    
    
    Uas_mag  = magUas(ffidx +1);
    Uas_phase  = phaseUas(ffidx +1);
    Ubs_mag  = magUbs(ffidx +1);
    Ubs_phase  = phaseUbs(ffidx +1);
    Ucs_mag  = magUcs(ffidx +1);
    Ucs_phase  = phaseUcs(ffidx +1);
    Ias_mag  = magIas(ffidx+1);
    Ias_phase  = phaseIas(ffidx +1);
    Ibs_mag  = magIbs(ffidx +1);
    Ibs_phase  = phaseIbs(ffidx +1);
    Ics_mag  = magIcs(ffidx +1);
    Ics_phase  = phaseIcs(ffidx +1);


% 数据格式 [Frequency, MagA, PhaseA, MagB, PhaseB, MagC, PhaseC]
VACP = [ff,Uas_mag,Uas_phase,Ubs_mag,Ubs_phase,Ucs_mag,Ucs_phase];
IACP = [ff,Ias_mag,Ias_phase,Ibs_mag,Ibs_phase,Ics_mag,Ics_phase];

% 计算正、负序分量，p正序，n负序
Ip = (IACP (:,2).*exp(1i*IACP (:,3))+IACP (:,4).*exp(1i*(IACP(:,5)+2*pi/3))+IACP (:,6).*exp(1i*(IACP(:,7)-2*pi/3)))/3;
In = (IACP (:,2).*exp(1i*IACP (:,3))+IACP (:,4).*exp(1i*(IACP(:,5)-2*pi/3))+IACP (:,6).*exp(1i*(IACP(:,7)+2*pi/3)))/3;

Vp = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)+2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)-2*pi/3)))/3;
Vn = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)-2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)+2*pi/3)))/3;


% 阻抗矩阵
Zp = Vp./Ip;
Zn = Vn./In;

Ia = IACP (:,2).*exp(1i*IACP (:,3));
Va = VACP (:,2).*exp(1i*VACP (:,3));
Za= Va./Ia;
% 
% Ib = IACP (:,4).*exp(1i*IACP (:,5));
% Vb = VACP (:,4).*exp(1i*VACP (:,5));
% Zb= Vb./Ib
% 
% Ic = IACP (:,6).*exp(1i*IACP (:,7));
% Vc = VACP (:,6).*exp(1i*VACP (:,7));
% Zc= Vc./Ic



% 阻抗相角折算至±180°之间
Zpx_phase=angle(Zp)*180/pi;
Znx_phase=angle(Zn)*180/pi;


ZP(ffidx,:) = [ff,abs(Zp), Zpx_phase];
ZN(ffidx,:)= [ff,abs(Zn), Znx_phase];


end
% save ZP;
% save ZN;
figure
subplot(2,1,1);
plot(ZP(:,1),ZP(:,2));
xlabel('频率（Hz)');
ylabel('幅值（ohm)');
subplot(2,1,2);
plot(ZP(:,1),ZP(:,3));
xlabel('频率（Hz)');
ylabel('相角（度)');
% saveas(gca, 'ZukangScanBode.fig')
% saveas(gca, 'ZukangScanBode.emf')
% saveas(gca, 'ZukangScanBode.png')

% ZPD=ZP;
% save DATA_ZPD ZPD;


% figure
% subplot(2,1,1);
% plot(ZN(:,1),20*log(ZN(:,2)));
% xlabel('频率（Hz)');
% ylabel('幅值（dB)');
% subplot(2,1,2);
% plot(ZN(:,1),ZN(:,3));
% xlabel('频率（Hz)');
% ylabel('相角（度)');
% saveas(gca, 'ZukangScanBode.fig')
% saveas(gca, 'ZukangScanBode.emf')
% saveas(gca, 'ZukangScanBode.png')

% ZND=ZN;
% save DATA_ZND ZND;

