
ZPD1_LEGEND = "已优化_35kV_无倍乘1台";
ZPD2_LEGEND = "已优化_35kV_有倍乘1台";
ZPD3_LEGEND = "已优化_35kV_有倍乘100台";
ZPD4_LEGEND = "已优化_35kV_有倍乘200台";


LEGEND_CELL = {ZPD1_LEGEND, ZPD2_LEGEND, ZPD3_LEGEND, ZPD4_LEGEND};
COLOR_MAP = 'prism';


FONT_NAME = "TimesNewRomanSimSun";
figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    plot(ZPD1(:,1), 20*log10(ZPD1(:,2)), 'linewidth', 1.0, 'color', f_getColor(1, 1, 4, COLOR_MAP));
    hold on
    plot(ZPD2(:,1), 20*log10(ZPD2(:,2)*1  ), 'linewidth', 1.0, 'color', f_getColor(2, 1, 4, COLOR_MAP));
    plot(ZPD3(:,1), 20*log10(ZPD3(:,2)*100), 'linewidth', 1.0, 'color', f_getColor(3, 1, 4, COLOR_MAP));
    plot(ZPD4(:,1), 20*log10(ZPD4(:,2)*200), 'linewidth', 1.0, 'color', f_getColor(4, 1, 4, COLOR_MAP));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title("阻抗幅值归一化")

    grid on
    legend(LEGEND_CELL, 'interpreter', 'none')
    set(gca, 'fontname', FONT_NAME)
    subplot(2,1,2);
    plot(ZPD1(:,1), ZPD1(:,3), 'linewidth', 1.0, 'color', f_getColor(1, 1, 4, COLOR_MAP));
    hold on
    plot(ZPD2(:,1), ZPD2(:,3), 'linewidth', 1.0, 'color', f_getColor(2, 1, 4, COLOR_MAP));
    plot(ZPD3(:,1), ZPD3(:,3), 'linewidth', 1.0, 'color', f_getColor(3, 1, 4, COLOR_MAP));
    plot(ZPD4(:,1), ZPD4(:,3), 'linewidth', 1.0, 'color', f_getColor(4, 1, 4, COLOR_MAP));
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', FONT_NAME)

    f_savefig("./", "DATA_ZPD_multiply", {'fig', 'png'}, 300)