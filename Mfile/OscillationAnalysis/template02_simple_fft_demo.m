%% Description
% This prog is used for FFT quick plot, you feed three-phase value or single phase value,
% FFT spectrum will be plotted. Of course, you should set sampling frequency and signal 
% selection manually.
close all;

iabc = [data.ia data.ib data.ic];
FS = int64(1/0.001);
IABC = iabc(FS*9:FS*10, :);

FONT_SIZE = 14;

[freq_ax mag_ax ph_ax cmp_ax] = f_fft_simple(IABC, FS, FS);


figure
subplot(2, 1, 1)
plot(IABC(:, 1))
ylabel('原始信号')
xlabel('Sample (Sa)')
grid on
f_set_fontface(gca, 'TimesNewRomanSimsun')
set(gca, 'fontsize', FONT_SIZE)

subplot(2, 1, 2)
plot(freq_ax, mag_ax(:, 1)/max(mag_ax(:, 1)))
set(gca, 'ylim', [-0.1, 1.1])
grid on
ylabel('振幅含量(%)')
xlabel('频率(Hz)')
f_set_fontface(gca, 'TimesNewRomanSimsun')
set(gca, 'fontsize', FONT_SIZE)
f_set_fig_size(gcf, [5, 5], [15, 4])