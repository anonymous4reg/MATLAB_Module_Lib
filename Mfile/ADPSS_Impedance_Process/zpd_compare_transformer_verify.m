ZPD1_LEGEND = "已优化_230kV_12台主变2880MVA";
ZPD2_LEGEND = "已优化_230kV_主变5000MVA";
ZPD3_LEGEND = "已优化_525kV_倍乘600台";
ZPD4_LEGEND = "已优化_525kV_倍乘10台";
ZPD5_LEGEND = "已优化_525kV_倍乘300台";



LEGEND_CELL = {ZPD1_LEGEND, ...
               ZPD2_LEGEND, ...
               ZPD3_LEGEND,...
               ZPD4_LEGEND, ...
               ZPD5_LEGEND};

COLOR_COUNT = length(LEGEND_CELL);

COLOR_MAP = 'jet';


FONT_NAME = "TimesNewRomanSimSun";
figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    plot(ZPD1(:,1),  20*log10(ZPD1(:,2)*600),     'linewidth', 1.0, 'color',  f_getColor(1, 1, COLOR_COUNT, COLOR_MAP));
    hold on 
    plot(ZPD2(:,1),  20*log10(ZPD2(:,2)*600  ), 'linewidth', 1.0, 'color',  f_getColor(2, 1, COLOR_COUNT, COLOR_MAP));
    plot(ZPD3(:,1),  20*log10(ZPD3(:,2)*600), 'linewidth', 1.0, 'color',  f_getColor(3, 1, COLOR_COUNT, COLOR_MAP));
    plot(ZPD4(:,1),  20*log10(ZPD4(:,2)*10), 'linewidth', 1.0, 'color',  f_getColor(4, 1, COLOR_COUNT, COLOR_MAP));
    plot(ZPD5(:,1),  20*log10(ZPD5(:,2)*300), 'linewidth', 1.0, 'color',  f_getColor(5, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD6(:,1),  20*log10(ZPD6(:,2)*400), 'linewidth', 1.0, 'color',  f_getColor(6, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD7(:,1),  20*log10(ZPD7(:,2)*500), 'linewidth', 1.0, 'color',  f_getColor(7, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD8(:,1),  20*log10(ZPD8(:,2)*600), 'linewidth', 1.0, 'color',  f_getColor(8, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD9(:,1),  20*log10(ZPD9(:,2)*600), 'linewidth', 1.0, 'color',  f_getColor(9, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD10(:,1), 20*log10(ZPD10(:,2)*600), 'linewidth', 1.0, 'color', f_getColor(10, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD11(:,1), 20*log10(ZPD11(:,2)*600), 'linewidth', 1.0, 'color', f_getColor(11, 1, COLOR_COUNT, COLOR_MAP), 'linestyle', '--');
    % plot(ZPD12(:,1), 20*log10(ZPD12(:,2)*600), 'linewidth', 1.0, 'color', f_getColor(12, 1, COLOR_COUNT, COLOR_MAP), 'linestyle', '--');
    % plot(ZPD13(:,1), 20*log10(ZPD13(:,2)*600), 'linewidth', 1.0, 'color', f_getColor(13, 1, COLOR_COUNT, COLOR_MAP), 'linestyle', '--');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title("阻抗幅值归一化")

    grid on
    legend(LEGEND_CELL, 'interpreter', 'none')
    set(gca, 'fontname', FONT_NAME)
    subplot(2,1,2);
    plot(ZPD1(:,1),  ZPD1(:,3), 'linewidth', 1.0, 'color',  f_getColor(1, 1, COLOR_COUNT, COLOR_MAP));
    hold on
    plot(ZPD2(:,1),  ZPD2(:,3), 'linewidth', 1.0, 'color',  f_getColor(2, 1, COLOR_COUNT, COLOR_MAP));
    plot(ZPD3(:,1),  ZPD3(:,3), 'linewidth', 1.0, 'color',  f_getColor(3, 1, COLOR_COUNT, COLOR_MAP));
    plot(ZPD4(:,1),  ZPD4(:,3), 'linewidth', 1.0, 'color',  f_getColor(4, 1, COLOR_COUNT, COLOR_MAP));
    plot(ZPD5(:,1),  ZPD5(:,3), 'linewidth', 1.0, 'color',  f_getColor(5, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD6(:,1),  ZPD6(:,3), 'linewidth', 1.0, 'color',  f_getColor(6, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD7(:,1),  ZPD7(:,3), 'linewidth', 1.0, 'color',  f_getColor(7, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD8(:,1),  ZPD8(:,3), 'linewidth', 1.0, 'color',  f_getColor(8, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD9(:,1),  ZPD9(:,3), 'linewidth', 1.0, 'color',  f_getColor(9, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD10(:,1), ZPD10(:,3), 'linewidth', 1.0, 'color', f_getColor(10, 1, COLOR_COUNT, COLOR_MAP));
    % plot(ZPD11(:,1), ZPD11(:,3), 'linewidth', 1.0, 'color', f_getColor(11, 1, COLOR_COUNT, COLOR_MAP), 'linestyle', '--');
    % plot(ZPD12(:,1), ZPD12(:,3), 'linewidth', 1.0, 'color', f_getColor(12, 1, COLOR_COUNT, COLOR_MAP), 'linestyle', '--');
    % plot(ZPD13(:,1), ZPD13(:,3), 'linewidth', 1.0, 'color', f_getColor(13, 1, COLOR_COUNT, COLOR_MAP), 'linestyle', '--');
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', FONT_NAME)

    % f_savefig("./", "DATA_ZPD_multiply", {'fig', 'png'}, 300)