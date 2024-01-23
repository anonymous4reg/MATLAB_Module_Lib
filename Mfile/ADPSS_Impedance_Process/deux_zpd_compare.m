
ZPD1_LEGEND = "不振荡(A+B+C)";
ZPD2_LEGEND = "振荡(A+B+C+B8)";
ZPD3_LEGEND = "振荡(置换全为B)";
ZPD4_LEGEND = "不振荡(置换全为D)";

FONT_NAME = "TimesNewRomanSimSun";
figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    plot(ZPD1(:,1), 20*log10(ZPD1(:,2)), 'linewidth', 1.0, 'color', 'k');
    hold on
    plot(ZPD2(:,1), 20*log10(ZPD2(:,2)), 'linewidth', 1.0, 'color', 'r');
    plot(ZPD3(:,1), 20*log10(ZPD3(:,2)), 'linewidth', 1.0, 'color', 'g');
    plot(ZPD4(:,1), 20*log10(ZPD4(:,2)), 'linewidth', 1.0, 'color', 'b');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');

    grid on
    legend({ZPD1_LEGEND, ZPD2_LEGEND, ZPD3_LEGEND, ZPD4_LEGEND})
    set(gca, 'fontname', FONT_NAME)
    subplot(2,1,2);
    plot(ZPD1(:,1),ZPD1(:,3), 'linewidth', 1.0, 'color', 'b');
    hold on
    plot(ZPD2(:,1), ZPD2(:,3), 'linewidth', 1.0, 'color', 'r');
    plot(ZPD3(:,1), ZPD3(:,3), 'linewidth', 1.0, 'color', 'g');
    plot(ZPD4(:,1), ZPD4(:,3), 'linewidth', 1.0, 'color', 'b');
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', FONT_NAME)

    f_savefig("./", "DATA_ZPD", {'fig', 'png'}, 300)