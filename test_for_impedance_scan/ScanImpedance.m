NN=1/50e-6;
N=NN*1;
f_start=1;
f_end=100;

ZP=zeros(f_end-f_start,3);
ZN=zeros(f_end-f_start,3);
ZA=zeros(f_end-f_start,3);

for ff =f_start:f_end   

    TT=scan1_a(1,((ff-f_start)*NN+1):((ff-f_start)*NN+N));

	UA=scan1_a(3,((ff-f_start)*NN+1):((ff-f_start)*NN+N));
	UB=scan1_a(4,((ff-f_start)*NN+1):((ff-f_start)*NN+N));
	UC=scan1_a(5,((ff-f_start)*NN+1):((ff-f_start)*NN+N));

	IA=scan1_a(6,((ff-f_start)*NN+1):((ff-f_start)*NN+N));
	IB=scan1_a(7,((ff-f_start)*NN+1):((ff-f_start)*NN+N));
	IC=scan1_a(8,((ff-f_start)*NN+1):((ff-f_start)*NN+N));




	Uas=zeros(1,N );
	Uas_mag=zeros(1,1);
	Uas_phase=zeros(1,1);

 
	% ��������
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


	% ���ݸ�ʽ [Frequency, MagA, PhaseA, MagB, PhaseB, MagC, PhaseC]
	VACP = [ff,Uas_mag,Uas_phase,Ubs_mag,Ubs_phase,Ucs_mag,Ucs_phase];
	IACP = [ff,Ias_mag,Ias_phase,Ibs_mag,Ibs_phase,Ics_mag,Ics_phase];

	% �����������������p����n����
	Ip = (IACP (:,2).*exp(1i*IACP (:,3))+IACP (:,4).*exp(1i*(IACP(:,5)+2*pi/3))+IACP (:,6).*exp(1i*(IACP(:,7)-2*pi/3)))/3;
	In = (IACP (:,2).*exp(1i*IACP (:,3))+IACP (:,4).*exp(1i*(IACP(:,5)-2*pi/3))+IACP (:,6).*exp(1i*(IACP(:,7)+2*pi/3)))/3;

	Vp = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)+2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)-2*pi/3)))/3;
	Vn = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)-2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)+2*pi/3)))/3;


	% �迹����
	Zp = Vp./Ip;
	Zn = Vn./In;

	%Zp = abs(Uas_fft./Ias_fft);

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



	% �迹�����������180��֮��
	Zpx_phase=angle(Zp)*180/pi;
	Znx_phase=angle(Zn)*180/pi;
	Zax_phase=angle(Za)*180/pi;

	if ff<=50 & Zpx_phase<-110
	    Zpx_phase = Zpx_phase + 360;
	end
	if (ff>50 & ff<100) & Zpx_phase>120
	    Zpx_phase = Zpx_phase - 360;
	end    

	%Zpx_phase=angle(Zp)*180/pi;

	ZP(ff-f_start+1,:) = [ff,abs(Zp), Zpx_phase];
	ZN (ff-f_start+1,:)= [ff,abs(Zn), Znx_phase];
	ZA (ff-f_start+1,:)= [ff,abs(Za), Zax_phase];
end
save ZP;
% save ZN;

% figure
% subplot(2,1,1);
% plot(ZP(:,1),ZP(:,2));
% xlabel('Ƶ�ʣ�Hz)');
% ylabel('��ֵ��Ohm)');
% subplot(2,1,2);
% plot(ZP(:,1),ZP(:,3));
% xlabel('Ƶ�ʣ�Hz)');
% ylabel('��ǣ���)');

figure
subplot(2,1,1);
plot(ZA(:,1),20*log(ZA(:,2)));
xlabel('Ƶ�ʣ�Hz)');
ylabel('��ֵ��dB)');
subplot(2,1,2);
plot(ZA(:,1),-ZA(:,3));
xlabel('Ƶ�ʣ�Hz)');
ylabel('��ǣ���)');

