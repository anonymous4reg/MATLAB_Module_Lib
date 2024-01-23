%% verion 2.1 revised by Yamin
% This version, read csv as input, you have to specify the column of Uabc
% and Iabc
close all;clc

%% User define zone
MatUrl = 'Your csv file directory.csv';


% Define which column you select as Uabc and Iabc
USabcIdx = (1:3)+2;
ISabcIdx = (9:11)+2;
% which freq do you want to focus on
WHICH_FREQ = [43, 50, 57];
% Sampling frequency, must consist with CSV
SAMPLE_FREQ = int64(2e3);
T_SPAN = 1;  % signal real time span for selected window


RawData = table2array(readtable(MatUrl));
USabc = RawData(:, USabcIdx);
ISabc = RawData(:, ISabcIdx);



%% Don't touch the following code unless you know what are you doing
f_MagAngle2Imag = @(arg_mag, arg_angle) arg_mag .* exp(1i .* arg_angle);


% 1: Voltage only, 2: Current only, 3: Impedance computing
WORKING_MODE = 3;
%% Your data input here
uabc_iabc = [USabc, ISabc];

RAW_DATA = uabc_iabc;

SAMPLE_TIME = 1/SAMPLE_FREQ;


[RAW_DATA_RNum, RAW_DATA_CNum] = size(RAW_DATA);
assert(RAW_DATA_CNum == 6, 'Please make sure that your signal is n-by-6 matrix')

%% generate fake time array
t_array = 0:SAMPLE_TIME:(RAW_DATA_RNum-1)*SAMPLE_TIME;
t_array = t_array';

uabc = RAW_DATA(:, 1:3);
iabc = RAW_DATA(:, 4:6);


L = T_SPAN * SAMPLE_FREQ;  % lenght of signal


N = L;   % number of signal
scan = [t_array, uabc, iabc];
Uas = uabc(:, 1);
Ubs = uabc(:, 2);
Ucs = uabc(:, 3);

Ias = iabc(:, 1);
Ibs = iabc(:, 2);
Ics = iabc(:, 3);

[fa, umag_a, uang_a]  = f_fft_simple(Uas, SAMPLE_FREQ, N);
[fb, umag_b, uang_b]  = f_fft_simple(Ubs, SAMPLE_FREQ, N);
[fc, umag_c, uang_c]  = f_fft_simple(Ucs, SAMPLE_FREQ, N);

[fia, imag_a, iang_a] = f_fft_simple(Ias, SAMPLE_FREQ, N);
[fib, imag_b, iang_b] = f_fft_simple(Ibs, SAMPLE_FREQ, N);
[fic, imag_c, iang_c] = f_fft_simple(Ics, SAMPLE_FREQ, N);


u_mag = [umag_a, umag_b, umag_c];
% u_ang = [uang_a, uang_b, uang_c];
u_ang = [uang_a, uang_b, uang_c] + pi/2;
i_mag = [imag_a, imag_b, imag_c];
% i_ang = [iang_a, iang_b, iang_c];
i_ang = [iang_a, iang_b, iang_c] + pi/2;

%% convert fft result from mag/angle to complex
u_complex_array = f_MagAngle2Imag(u_mag, u_ang);
i_complex_array = f_MagAngle2Imag(i_mag, i_ang);

%% convert fft result from ABC complex form to positive-negative-zero form
u_pn0_array = f_seqconv(u_complex_array');
u_pn0_array = u_pn0_array';
i_pn0_array = f_seqconv(i_complex_array');
i_pn0_array = i_pn0_array';

z_pn0_array = u_pn0_array ./ i_pn0_array;

u_pn0_mag = abs(u_pn0_array);
u_pn0_ang = angle(u_pn0_array);
i_pn0_mag = abs(i_pn0_array);
i_pn0_ang = angle(i_pn0_array);
z_pn0_mag = abs(z_pn0_array);
z_pn0_ang = angle(z_pn0_array);

MemFreq = [];
MemUpMag = [];
MemUpArg = [];
MemIpMag = [];
MemIpArg = [];
MemR = [];
MemX = [];
MemP = [];
MemQ = [];
MemZimg = [];
AAAPastTable = table();
for fsel_idx = 1:length(WHICH_FREQ)
    %% Select specific freq value
    f_sel = WHICH_FREQ(fsel_idx);

    fprintf('FFT抽取%6.2f (Hz)频率，原始数据采样频率%i (Hz), 时间长度为%6.2f (sec)\n', ...
    f_sel, SAMPLE_FREQ, T_SPAN)

    f_select_logic_array = fa == f_sel;
    f_select_idx = find(f_select_logic_array);
    
    u_mag_sel = u_mag(f_select_idx, :);
    u_ang_sel = u_ang(f_select_idx, :);
    i_mag_sel = i_mag(f_select_idx, :);
    i_ang_sel = i_ang(f_select_idx, :);
    
    z_pn0_sel = z_pn0_array(f_select_idx, :);
    
    u_pn0_mag_sel = u_pn0_mag(f_select_idx, :);
    u_pn0_ang_sel = u_pn0_ang(f_select_idx, :);
    i_pn0_mag_sel = i_pn0_mag(f_select_idx, :);
    i_pn0_ang_sel = i_pn0_ang(f_select_idx, :);
    
    z_pn0_mag_sel = abs(z_pn0_sel);
    z_pn0_ang_sel = angle(z_pn0_sel);
    
    Pp = 1.5*u_pn0_mag_sel(1)*i_pn0_mag_sel(1)*cos(u_pn0_ang_sel(1) - i_pn0_ang_sel(1));
    Qp = 1.5*u_pn0_mag_sel(1)*i_pn0_mag_sel(1)*sin(u_pn0_ang_sel(1) - i_pn0_ang_sel(1));
    
    %% Data store zone
    MemFreq = [MemFreq; f_sel];
    MemUpMag = [MemUpMag; u_pn0_mag_sel(1)];
    MemUpArg = [MemUpArg; u_pn0_ang_sel(1)*180/pi];
    MemIpMag = [MemIpMag; i_pn0_mag_sel(1)];
    MemIpArg = [MemIpArg; i_pn0_ang_sel(1)*180/pi];
    MemR = [MemR; real(z_pn0_sel(1))];
    MemX = [MemX; imag(z_pn0_sel(1))];
    MemP = [MemP; Pp];
    MemQ = [MemQ; Qp];
    MemZimg = [MemZimg; z_pn0_sel(1)];
    %%
    eval(strcat('Freq_', num2str(f_sel), 'Hz = f_sel'))
    eval(strcat('UpMag_', num2str(f_sel), 'Hz = u_pn0_mag_sel(1);'))
    eval(strcat('UpArg_', num2str(f_sel), 'Hz = u_pn0_ang_sel(1)*180/pi;'))
    eval(strcat('IpMag_', num2str(f_sel), 'Hz = i_pn0_mag_sel(1);'))
    eval(strcat('IpArg_', num2str(f_sel), 'Hz = i_pn0_ang_sel(1)*180/pi;'))
    eval(strcat('R_', num2str(f_sel), 'Hz = real(z_pn0_sel(1));'))
    eval(strcat('X_', num2str(f_sel), 'Hz = imag(z_pn0_sel(1));'))
    eval(strcat('P_', num2str(f_sel), 'Hz = Pp;'))
    eval(strcat('Q_', num2str(f_sel), 'Hz = Qp;'))
    eval(strcat('Zimg_', num2str(f_sel), 'Hz = z_pn0_sel(1);'))

%     eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'Freq_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'UpMag_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'UpArg_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'IpMag_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'IpArg_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'R_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'X_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'P_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'Q_', num2str(f_sel), 'Hz);') )
    eval(strcat("AAAPastTable = addvars(AAAPastTable, ", 'Zimg_', num2str(f_sel), 'Hz);') )
    
    %% Print out zone
    disp("----- Sequence Result: Positive Negative Zero ------")
    fprintf("Up mag, angle(degree): %f, %f\n", u_pn0_mag_sel(1), u_pn0_ang_sel(1)*180/pi)
    fprintf("Ip mag, angle(degree): %f, %f\n", i_pn0_mag_sel(1), i_pn0_ang_sel(1)*180/pi)
    fprintf("P = %f, Q = %f\n", Pp, Qp)
    fprintf("Zp complex: %s\n", num2str(z_pn0_sel(1)))

end

AAATable = table(MemFreq, MemUpMag, MemUpArg, MemIpMag, MemIpArg, ...
				MemR, MemX, MemP, MemQ, MemZimg)
% disp("-------")
% fprintf("Zp mag, angle(degree): %f, %f\n", z_pn0_mag_sel(1), z_pn0_ang_sel(1)*180/pi)



% fprintf("Un mag, angle(degree): %f, %f\n", u_pn0_mag_sel(2), u_pn0_ang_sel(2)*180/pi)
% fprintf("In mag, angle(degree): %f, %f\n", i_pn0_mag_sel(2), i_pn0_ang_sel(2)*180/pi)
% fprintf("Zn mag, angle(degree): %f, %f\n", z_pn0_sel(2), z_pn0_sel(2)*180/pi)
% fprintf("Zn complex: %s\n", num2str(z_pn0_sel(2)))
% 
% fprintf("U0 mag, angle(degree): %f, %f\n", u_pn0_mag_sel(3), u_pn0_ang_sel(3)*180/pi)
% fprintf("I0 mag, angle(degree): %f, %f\n", i_pn0_mag_sel(3), i_pn0_ang_sel(3)*180/pi)
% fprintf("Z0 mag, angle(degree): %f, %f\n", z_pn0_sel(3), z_pn0_sel(2)*180/pi)
% fprintf("Z0 complex: %s\n", num2str(z_pn0_sel(3)))



% convert ABC to positive-negative-zero sequence


%% Figure plot zone
LEFT_POSITION = 5;
BOTTOM_POSITION = 1;
WIDTH_NUM = 12;
HEIGHT_NUM = 15;

POSITION_SET = [LEFT_POSITION, BOTTOM_POSITION, WIDTH_NUM, HEIGHT_NUM];

% Plot Voltage
figure;
subplot(3, 1, 1)
plot(fa, umag_a, 'LineWidth', 1.5)
xlabel('频率 (Hz)')
ylabel('U (kV)')
title('Ua')
grid on
set(gca, 'XLim', [0, 100])
subplot(3, 1, 2)
plot(fb, umag_b, 'LineWidth', 1.5)
xlabel('频率 (Hz)')
ylabel('U (kV)')
title('Ub')
grid on
set(gca, 'XLim', [0, 100])
subplot(3, 1, 3)
plot(fc, umag_c, 'LineWidth', 1.5)
xlabel('频率 (Hz)')
ylabel('U (kV)')
title('Uc')
grid on
set(gca, 'XLim', [0, 100])
set(gcf,'unit','centimeters','position', POSITION_SET)

% Plot Current
figure
subplot(3, 1, 1)
plot(fia, imag_a, 'LineWidth', 1.5)
xlabel('频率 (Hz)')
ylabel('I (kA)')
title('Ia')
grid on
set(gca, 'XLim', [0, 100])
subplot(3, 1, 2)
plot(fib, imag_b, 'LineWidth', 1.5)
xlabel('频率 (Hz)')
ylabel('I (kA)')
title('Ib')
grid on
set(gca, 'XLim', [0, 100])
subplot(3, 1, 3)
plot(fic, imag_c, 'LineWidth', 1.5)
xlabel('频率 (Hz)')
ylabel('I (kA)')
title('Ic')
grid on
set(gca, 'XLim', [0, 100])
set(gcf,'unit','centimeters','position', POSITION_SET)




% figure;
% 
% subplot(2, 6, 1)
% plot(fa, u_pn0_mag(:, 1))
% title('U Pos mag')
% subplot(2, 6, 2)
% plot(fa, u_pn0_ang(:, 1)*180/pi)
% title('U Pos phase')
% 
% subplot(2, 6, 3)
% plot(fa, u_pn0_mag(:, 2))
% title('U Neg mag')
% subplot(2, 6, 4)
% plot(fa, u_pn0_ang(:, 2)*180/pi)
% title('U Neg phase')
% 
% subplot(2, 6, 5)
% plot(fa, i_pn0_mag(:, 1))
% title('I Pos mag')
% subplot(2, 6, 6)
% plot(fa, i_pn0_ang(:, 1)*180/pi)
% title('I Pos phase')
% 
% subplot(2, 6, 7)
% plot(fa, i_pn0_mag(:, 2))
% title('I Neg mag')
% subplot(2, 6, 8)
% plot(fa, i_pn0_ang(:, 2)*180/pi)
% title('I Neg phase')
% 
% subplot(2, 6, 9)
% plot(fa, i_pn0_mag(:, 1))
% title('Z Pos mag')
% subplot(2, 6, 10)
% plot(fa, i_pn0_ang(:, 1)*180/pi)
% title('Z Pos phase')
% 
% subplot(2, 6, 11)
% plot(fa, i_pn0_mag(:, 2))
% title('Z Neg mag')
% subplot(2, 6, 12)
% plot(fa, i_pn0_ang(:, 2)*180/pi)
% title('Z Neg phase')
% set(gcf, "Position", [20, 20, 18, 6])


XLIM = [0, 100];
SUBPLOT_FONT_SIZE = 10;
figure
[ha, pos] = tight_subplot(4, 3, [0.06, 0.04], [0.03, 0.03], [0.04, 0.01]);
set(gcf,'unit','centimeters','position',[0.5, 1, 45, 20])
axes(ha(1))
title('test')
for hidx = 1:12
	axes(ha(hidx))
	switch hidx
		%% positive
		case 1
			plot(fa, u_pn0_mag(:, 1))
			grid on
			title('U Pos Mag')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 4
			plot(fa, u_pn0_ang(:, 1)*180/pi)
			grid on
			title('U Pos Phase')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 7
			plot(fa, i_pn0_mag(:, 1))
			grid on
			title('I Pos Mag')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 10
			plot(fa, i_pn0_ang(:, 1)*180/pi)
			grid on
			title('I Pos Phase')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		
		%% negative
		case 2
			plot(fa, u_pn0_mag(:, 2))
			grid on
			title('U Neg Mag')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 5
			plot(fa, u_pn0_ang(:, 2)*180/pi)
			grid on
			title('U Neg Phase')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 8
			plot(fa, i_pn0_mag(:, 2))
			grid on
			title('I Neg Mag')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 11
			plot(fa, i_pn0_ang(:, 2)*180/pi)
			grid on
			title('I Neg Phase')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)


		case 3
			plot(fa, z_pn0_mag(:, 1))
			grid on
			title('Z Pos Mag')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 6
			plot(fa, z_pn0_ang(:, 1)*180/pi)
			grid on
			title('Z Pos Phase')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 9
			plot(fa, z_pn0_mag(:, 2))
			grid on
			title('Z Neg Mag')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		case 12
			plot(fa, z_pn0_ang(:, 2)*180/pi)
			grid on
			title('Z Neg Phase')
			set(gca,'XLim', XLIM, 'fontname', 'times new roman', 'fontsize', SUBPLOT_FONT_SIZE)
		otherwise
			disp('wrong')
	end
end
