function [In2,Vn2,In_coupled2,Vn_coupled2] = ScanImpedance2(Freq_begin,Freq_end,Freq_step,NN,Data)

Data = cell2mat(struct2cell(Data));
scan_concat=Data;


N=NN*1;

f_start=Freq_begin;
f_end=Freq_end-1;
f_step=Freq_step;
f0=50;

f_num=(f_end-f_start)/f_step+1;

for ff =f_start:f_step:f_end   

    ff_coupled=2*50-(-ff);
    ff_num=(ff-f_start)/f_step; %从0开始
    ff_num_coupled=(ff_coupled-f_start)/f_step; %从0开始
    
    TT=scan_concat(1,(ff_num*NN+1):(ff_num*NN+N));

	UA=scan_concat(3,(ff_num*NN+1):(ff_num*NN+N));
	UB=scan_concat(4,(ff_num*NN+1):(ff_num*NN+N));
	UC=scan_concat(5,(ff_num*NN+1):(ff_num*NN+N));

	IA=-scan_concat(6,(ff_num*NN+1):(ff_num*NN+N));
	IB=-scan_concat(7,(ff_num*NN+1):(ff_num*NN+N));
	IC=-scan_concat(8,(ff_num*NN+1):(ff_num*NN+N));


	Uas=zeros(1,N );
	Uas_mag=zeros(1,1);
	Uas_phase=zeros(1,1);

 
	% 变量定义
	Uas=zeros(1,N );
	Ubs=zeros(1,N );
	Ucs=zeros(1,N );
	Ias=zeros(1,N );
	Ibs=zeros(1,N );
	Ics=zeros(1,N );
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

    Uas_fft=fft(Uas(1,:));
    magUas = abs(Uas_fft/N);
    magUas = magUas(1:N/2);
    magUas(2:end-1) = 2*magUas(2:end-1);
    phaseUas = angle(Uas_fft);
    Ias_fft=fft(Ias(1,:));
    magIas = abs(Ias_fft/N);
    magIas = magIas(1:N/2);
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
    
    Ua0_mag=magUas(f0 +1);
    Ua0_phase  = phaseUas(f0 +1);
    Ub0_mag=magUbs(f0 +1);
    Ub0_phase  = phaseUbs(f0 +1);
    Uc0_mag=magUcs(f0 +1);
    Uc0_phase  = phaseUcs(f0 +1);
    Ia0_mag=magIas(f0 +1);
    Ia0_phase  = phaseIas(f0 +1);
    Ib0_mag=magIbs(f0 +1);
    Ib0_phase  = phaseIbs(f0 +1);
    Ic0_mag=magIcs(f0 +1);
    Ic0_phase  = phaseIcs(f0 +1);

    Uas_mag  = magUas(ff +1);
    Uas_phase  = phaseUas(ff +1);
    Ubs_mag  = magUbs(ff +1);
    Ubs_phase  = phaseUbs(ff +1);
    Ucs_mag  = magUcs(ff +1);
    Ucs_phase  = phaseUcs(ff +1);
    Ias_mag  = magIas(ff+1);
    Ias_phase  = phaseIas(ff +1);
    Ibs_mag  = magIbs(ff +1);
    Ibs_phase  = phaseIbs(ff +1);
    Ics_mag  = magIcs(ff +1);
    Ics_phase  = phaseIcs(ff +1);

    Uas_coupled_mag  = magUas(ff_coupled +1);
    Uas_coupled_phase  = phaseUas(ff_coupled +1);
    Ubs_coupled_mag  = magUbs(ff_coupled +1);
    Ubs_coupled_phase  = phaseUbs(ff_coupled +1);
    Ucs_coupled_mag  = magUcs(ff_coupled +1);
    Ucs_coupled_phase  = phaseUcs(ff_coupled +1);
    Ias_coupled_mag  = magIas(ff_coupled+1);
    Ias_coupled_phase  = phaseIas(ff_coupled +1);
    Ibs_coupled_mag  = magIbs(ff_coupled +1);
    Ibs_coupled_phase  = phaseIbs(ff_coupled +1);
    Ics_coupled_mag  = magIcs(ff_coupled +1);
    Ics_coupled_phase  = phaseIcs(ff_coupled +1);


	% 数据格式 [Frequency, MagA, PhaseA, MagB, PhaseB, MagC, PhaseC]
    V0=[f0,Ua0_mag,Ua0_phase,Ub0_mag,Ub0_phase,Uc0_mag,Uc0_phase];
    I0=[f0,Ia0_mag,Ia0_phase,Ib0_mag,Ib0_phase,Ic0_mag,Ic0_phase];
	VACP = [ff,Uas_mag,Uas_phase,Ubs_mag,Ubs_phase,Ucs_mag,Ucs_phase];
	IACP = [ff,Ias_mag,Ias_phase,Ibs_mag,Ibs_phase,Ics_mag,Ics_phase];
	VACP_coupled = [ff_coupled,Uas_coupled_mag,Uas_coupled_phase,Ubs_coupled_mag,Ubs_coupled_phase,Ucs_coupled_mag,Ucs_coupled_phase];
	IACP_coupled = [ff_coupled,Ias_coupled_mag,Ias_coupled_phase,Ibs_coupled_mag,Ibs_coupled_phase,Ics_coupled_mag,Ics_coupled_phase];

	% 计算正、负序分量，p正序，n负序
    Ip0=(I0 (:,2).*exp(1i*I0 (:,3))+I0 (:,4).*exp(1i*(I0(:,5)+2*pi/3))+I0 (:,6).*exp(1i*(I0(:,7)-2*pi/3)))/3;
    Vp0=(I0 (:,2).*exp(1i*V0 (:,3))+V0 (:,4).*exp(1i*(V0(:,5)+2*pi/3))+V0 (:,6).*exp(1i*(V0(:,7)-2*pi/3)))/3;
    angle0=angle(Vp0);
	Ip(ff_num+1) = (IACP (:,2).*exp(1i*IACP (:,3))+IACP (:,4).*exp(1i*(IACP(:,5)+2*pi/3))+IACP (:,6).*exp(1i*(IACP(:,7)-2*pi/3)))/3;
	In(ff_num+1) = (IACP (:,2).*exp(1i*IACP (:,3))+IACP (:,4).*exp(1i*(IACP(:,5)-2*pi/3))+IACP (:,6).*exp(1i*(IACP(:,7)+2*pi/3)))/3;
	Vp(ff_num+1) = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)+2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)-2*pi/3)))/3;
	Vn(ff_num+1) = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)-2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)+2*pi/3)))/3;

	Ip_coupled(ff_num+1) = (IACP_coupled (:,2).*exp(1i*IACP_coupled (:,3))+IACP_coupled (:,4).*exp(1i*(IACP_coupled(:,5)+2*pi/3))+IACP_coupled (:,6).*exp(1i*(IACP_coupled(:,7)-2*pi/3)))/3;
	In_coupled(ff_num+1) = (IACP_coupled (:,2).*exp(1i*IACP_coupled (:,3))+IACP_coupled (:,4).*exp(1i*(IACP_coupled(:,5)-2*pi/3))+IACP_coupled (:,6).*exp(1i*(IACP_coupled(:,7)+2*pi/3)))/3;
	Vp_coupled(ff_num+1) = (VACP_coupled (:,2).*exp(1i*VACP_coupled (:,3))+VACP_coupled (:,4).*exp(1i*(VACP_coupled(:,5)+2*pi/3))+VACP_coupled (:,6).*exp(1i*(VACP_coupled(:,7)-2*pi/3)))/3;
	Vn_coupled(ff_num+1) = (VACP_coupled (:,2).*exp(1i*VACP_coupled (:,3))+VACP_coupled (:,4).*exp(1i*(VACP_coupled(:,5)-2*pi/3))+VACP_coupled (:,6).*exp(1i*(VACP_coupled(:,7)+2*pi/3)))/3;

    ff_count=ff_num+1;
    magIp=abs(Ip(ff_count));
    phaseIp=angle(Ip(ff_count))-angle0;
    magIp_coupled=abs(Ip_coupled(ff_count));
    phaseIp_coupled=angle(Ip_coupled(ff_count))-angle0;
    magVp=abs(Vp(ff_count));
    phaseVp=angle(Vp(ff_count))-angle0;
    magVp_coupled=abs(Vp_coupled(ff_count));
    phaseVp_coupled=angle(Vp_coupled(ff_count))-angle0;
    Ip(ff_count)=magIp*cos(phaseIp)+1i*magIp*sin(phaseIp);
    Ip_coupled(ff_count)=magIp_coupled*cos(phaseIp_coupled)+1i*magIp_coupled*sin(phaseIp_coupled);
    Vp(ff_count)=magVp*cos(phaseVp)+1i*magVp*sin(phaseVp);
    Vp_coupled(ff_count)=magVp_coupled*cos(phaseVp_coupled)+1i*magVp_coupled*sin(phaseVp_coupled);
    
    magIn=abs(In(ff_count));
    phaseIn=-angle(In(ff_count))-angle0;
    magIn_coupled=abs(In_coupled(ff_count));
    phaseIn_coupled=angle(In_coupled(ff_count))-angle0;
    magVn=abs(Vn(ff_count));
    phaseVn=-angle(Vn(ff_count))-angle0;
    magVn_coupled=abs(Vn_coupled(ff_count));
    phaseVn_coupled=angle(Vn_coupled(ff_count))-angle0;
    In(ff_count)=magIn*cos(phaseIn)+1i*magIn*sin(phaseIn);
    In_coupled(ff_count)=magIn_coupled*cos(phaseIn_coupled)+1i*magIn_coupled*sin(phaseIn_coupled);
    Vn(ff_count)=magVn*cos(phaseVn)+1i*magVn*sin(phaseVn);
    Vn_coupled(ff_count)=magVn_coupled*cos(phaseVn_coupled)+1i*magVn_coupled*sin(phaseVn_coupled);
    
%     
% 	% 阻抗矩阵
% 	Zp = Vp./Ip;
% 	Zn = Vn./In;
% 
% 	%Zp = abs(Uas_fft./Ias_fft);
% 
% 	Ia = IACP (:,2).*exp(1i*IACP (:,3));
% 	Va = VACP (:,2).*exp(1i*VACP (:,3));
% 	Za= Va./Ia;
% 	% 
% 	% Ib = IACP (:,4).*exp(1i*IACP (:,5));
% 	% Vb = VACP (:,4).*exp(1i*VACP (:,5));
% 	% Zb= Vb./Ib
% 	% 
% 	% Ic = IACP (:,6).*exp(1i*IACP (:,7));
% 	% Vc = VACP (:,6).*exp(1i*VACP (:,7));
% 	% Zc= Vc./Ic
% 
% 	% 阻抗相角折算至±180°之间
% 	Zpx_phase=angle(Zp)*180/pi;
% 	Znx_phase=angle(Zn)*180/pi;
% 	Zax_phase=angle(Za)*180/pi;
% 
% 	if ff<=50 & Zpx_phase<-110
% 	    Zpx_phase = Zpx_phase + 360;
% 	end
% 	if (ff>50 & ff<100) & Zpx_phase>120
% 	    Zpx_phase = Zpx_phase - 360;
% 	end    
% 
% 	%Zpx_phase=angle(Zp)*180/pi;
% 
% 	ZP(ff_num+1,:) = [ff,abs(Zp), Zpx_phase];
% 	ZN (ff_num+1,:)= [ff,abs(Zn), Znx_phase];
% 	ZA (ff_num+1,:)= [ff,abs(Za), Zax_phase];
%     
end

% Ip1 = Ip;
% In1 = In;
% Vp1 = Vp;
% Vn1 = Vn;
% Ip_coupled1 = Ip_coupled;
% In_coupled1 = In_coupled;
% Vp_coupled1 = Vp_coupled;
% Vn_coupled1 = Vn_coupled;
% save Ip1 Ip1;
% % save In1 In1;
% save Vp1 Vp1;
% % save Vn1 Vn1;
% save Ip_coupled1 Ip_coupled1;
% % save In_coupled1 In_coupled1;% 
% save Vp_coupled1 Vp_coupled1;
% save Vn_coupled1 Vn_coupled1;

Ip2 = Ip;
In2 = In;
Vp2 = Vp;
Vn2 = Vn;
Ip_coupled2 = Ip_coupled;
In_coupled2 = In_coupled;
Vp_coupled2 = Vp_coupled;
Vn_coupled2 = Vn_coupled;
% save Ip2 Ip2;
% % save In2 In2;
% save Vp2 Vp2;
% % save Vn2 Vn2;
% save Ip_coupled2 Ip_coupled2;
% % save In_coupled2 In_coupled2;
% save Vp_coupled2 Vp_coupled2;
% % save Vn_coupled2 Vn_coupled2;






% save ZN;

% figure
% subplot(2,1,1);
% plot(ZP(:,1),ZP(:,2));
% xlabel('频率（Hz)');
% ylabel('幅值（Ohm)');
% subplot(2,1,2);
% plot(ZP(:,1),ZP(:,3));
% xlabel('频率（Hz)');
% ylabel('相角（度)');

% figure
% subplot(2,1,1);
% plot(ZA(:,1),20*log(ZA(:,2)));
% xlabel('频率（Hz)');
% ylabel('幅值（dB)');
% subplot(2,1,2);
% plot(ZA(:,1),ZA(:,3));
% xlabel('频率（Hz)');
% ylabel('相角（度)');
% 
% save([case_name, '/', 'DATA_ZP', '.mat'], 'ZP')
% saveas(gca, [case_name, '/', 'ImpedanceScan.png'])
% saveas(gca, [case_name, '/', 'ImpedanceScan.fig'])
% saveas(gca, [case_name, '/', 'ImpedanceScan.emf'])

% close all


