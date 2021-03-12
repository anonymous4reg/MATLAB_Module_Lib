PosThreePhaseGen = @(amp, freq, t) amp.*[sin(2*pi*freq.*t);  sin(2*pi*freq.*t - 2*pi/3); sin(2*pi*freq.*t + 2*pi/3)]';
NegThreePhaseGen = @(amp, freq, t) amp.*[sin(2*pi*freq.*t);  sin(2*pi*freq.*t + 2*pi/3); sin(2*pi*freq.*t - 2*pi/3)]';

Fs = 1e4;  % sampling freq
T = 1/Fs;	% sampling period
Tspan = 10;  % simulation frequency
L = Tspan * Fs;  % lenght of signal
N = L;
t = (0:L-1)*T;  % time vector;

Pos50Hz = PosThreePhaseGen(1, 50, t);
Neg58Hz = NegThreePhaseGen(0.5, 58, t);
uabc = Pos50Hz + Neg58Hz;

% scan = [t'; uabc'; iabc'];
Uas = uabc(:,1);
Ubs = uabc(:,2);
Ucs = uabc(:,3);
t=t(:,1);
% plot(t,Uas)


Uas_fft=fft(Uas);
magUas = abs(Uas_fft/N);
magUas = magUas(1:N/2);
magUas(2:end-1) = 2*magUas(2:end-1);
phaseUas = angle(Uas_fft);

Ubs_fft=fft(Ubs);
magUbs = abs(Ubs_fft/N);
magUbs = magUbs(1:N/2);
magUbs(2:end-1) = 2*magUbs(2:end-1);
phaseUbs = angle(Ubs_fft);

Ucs_fft=fft(Ucs);
magUcs = abs(Ucs_fft/N);
magUcs = magUcs(1:N/2);
magUcs(2:end-1) = 2*magUcs(2:end-1);
phaseUcs = angle(Ucs_fft);



freq = 0:0.1:length(magUas)/10-0.1;
freq = freq(2:end)';
f_start=0.1;
f_step=0.1;
f_end=length(magUas)/10-0.1;


% freq1 = 0:0.1:length(magUas)/10;
% freq1 = freq1(2:end)';
% figure;
% plot(freq1, magUas);
% figure;
% plot(freq1, magUbs);
% figure;
% plot(freq1, magUcs);



for ff = f_start:f_step:f_end   
ff_num=(ff-f_start)/f_step+1; %从1开始
ff_num= int64(ff_num) ;

    Uas_mag  = magUas(ff_num+1);
    Uas_phase  = phaseUas(ff_num+1);
    Ubs_mag  = magUbs(ff_num+1);
    Ubs_phase  = phaseUbs(ff_num+1);
    Ucs_mag  = magUcs(ff_num+1);
    Ucs_phase  = phaseUcs(ff_num+1);


VACP = [ff,Uas_mag,Uas_phase,Ubs_mag,Ubs_phase,Ucs_mag,Ucs_phase];
Vp(ff_num) = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)+2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)-2*pi/3)))/3;
Vn(ff_num) = (VACP (:,2).*exp(1i*VACP (:,3))+VACP (:,4).*exp(1i*(VACP(:,5)-2*pi/3))+VACP (:,6).*exp(1i*(VACP(:,7)+2*pi/3)))/3;
Vp_mag(ff_num) =abs(Vp(ff_num));
Vn_mag(ff_num) =abs(Vn(ff_num));

end


% figure;
% plot(freq, Vp_mag)
% figure;
% plot(freq, Vn_mag)

figure
subplot(2,1,1);
plot(freq, Vp_mag, 'LineWidth',1.5)
xlabel('频率(Hz)');
ylabel('幅值(kV)');
title('正序分量');
axis([0,100,0,200])
subplot(2,1,2);
plot(freq, Vn_mag, 'LineWidth',1.5)
xlabel('频率(Hz)');
ylabel('幅值(kV)');
title('负序分量');
axis([0,100,0,20])


