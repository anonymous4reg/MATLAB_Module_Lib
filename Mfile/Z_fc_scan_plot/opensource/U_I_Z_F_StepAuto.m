function [ZPD_SISO, ZND_SISO] = U_I_Z_F_StepAuto(InputCmdCell)

SrcFileDir  =   InputCmdCell{1};
NameMatrix  = { InputCmdCell{2} };
Freq_begin  =   InputCmdCell{3};
Freq_middle =   InputCmdCell{4}; % not used in this func
Freq_end    =   InputCmdCell{5};
Freq_step   =   InputCmdCell{6};
Step        =   InputCmdCell{7}; % Sample time of data(us)
SaveTempsFlag = InputCmdCell{8};

NN=int64(1e6/Step);
N=double(NN*1);

f_start=Freq_begin;
f_end=Freq_end;
f_step=Freq_step;

f_num=(f_end-f_start)/f_step+1;


OutSubDir = '250-2500Hz\';
filename = [NameMatrix{1}];
OutRoot=strcat(SrcFileDir, '\', OutSubDir, '\');
mkdir(OutRoot);
Data = load(strcat(SrcFileDir, '\', filename,  '.mat'));

scan_concat = cell2mat(struct2cell(Data));



ZP=zeros(f_num,3);
ZN=zeros(f_num,3);
ZA=zeros(f_num,3);

for ff =f_start:f_step:(f_end)   

    ff_num=(ff-f_start)/f_step; %从0开始
    
    TT=scan_concat(1,(ff_num*NN+1):(ff_num*NN+N));

	UA=scan_concat(3,(ff_num*NN+1):(ff_num*NN+N));
	UB=scan_concat(4,(ff_num*NN+1):(ff_num*NN+N));
	UC=scan_concat(5,(ff_num*NN+1):(ff_num*NN+N));

	IA=scan_concat(6,(ff_num*NN+1):(ff_num*NN+N));
	IB=scan_concat(7,(ff_num*NN+1):(ff_num*NN+N));
	IC=scan_concat(8,(ff_num*NN+1):(ff_num*NN+N));




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



	% 阻抗相角折算至±180°之间
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

	ZP(ff_num+1,:) = [ff,abs(Zp), Zpx_phase];
	ZN (ff_num+1,:)= [ff,abs(Zn), Znx_phase];
	ZA (ff_num+1,:)= [ff,abs(Za), Zax_phase];
end

    ZPD_SISO = ZP;
    ZND_SISO = ZN;

    if SaveTempsFlag == true
            save(strcat(OutRoot, 'DATA_ZPD_SISO.mat'), 'ZPD_SISO');
            save(strcat(OutRoot, 'DATA_ZND_SISO.mat'), 'ZND_SISO');
    end

end



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
% plot(ZA(:,1),20*log10(ZA(:,2)));
% xlabel('Frequency(Hz)');
% ylabel('Amplitude(dB)');
% subplot(2,1,2);
% plot(ZA(:,1),ZA(:,3));
% xlabel('Frequency(Hz)');
% ylabel('Phase(deg)');

% save([case_name, '/', 'DATA_ZP', '.mat'], 'ZP')
% saveas(gca, [case_name, '/', case_name, '.png'])
% saveas(gca, [case_name, '/', case_name, '.fig'])
% saveas(gca, [case_name, '/', case_name, '.emf'])

% close all


