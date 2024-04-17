
ZPD1_LEGEND = "海德P1.0-Q0.0";
ZPD2_LEGEND = "海德P0.2-Q0.0";
ZPD3_LEGEND = "海德P0.2-Q-0.33";
ZPD4_LEGEND = "远景P1.0-Q0.0";
ZPD5_LEGEND = "远景P0.2-Q0.0";
ZPD6_LEGEND = "远景P0.2-Q-0.33";




LEGEND_CELL = {'海德', '远景'};
XLIM = [0, 100];


FONT_NAME = "TimesNewRomanSimSun";
figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    % plot(ZPD1(:,1), ZPD1(:,2), 'linewidth', 1.0, 'color', 'r');
    hold on
    % plot(ZPD2(:,1), ZPD2(:,2), 'linewidth', 1.0, 'color', 'g');
    plot(ZPD3(:,1), ZPD3(:,2), 'linewidth', 1.0, 'color', 'r');

    % plot(ZPD4(:,1), ZPD4(:,2), 'linewidth', 1.0, 'color', 'r', 'linestyle', '--');
    % plot(ZPD5(:,1), ZPD5(:,2), 'linewidth', 1.0, 'color', 'g', 'linestyle', '--');
    plot(ZPD6(:,1), ZPD6(:,2), 'linewidth', 1.0, 'color', 'b', 'linestyle', '-');


    xlabel('Frequency (Hz)');
    % ylabel('Magnitude (dB)');
    ylabel('Magnitude (ohm)');

    grid on
    legend(LEGEND_CELL, 'interpreter', 'none')
    set(gca, 'fontname', FONT_NAME)
    set(gca, 'xlim', XLIM)
    subplot(2,1,2);
    % plot(ZPD1(:,1), ZPD1(:,3), 'linewidth', 1.0, 'color', 'r');
    hold on
    % plot(ZPD2(:,1), ZPD2(:,3), 'linewidth', 1.0, 'color', 'g');
    plot(ZPD3(:,1), ZPD3(:,3), 'linewidth', 1.0, 'color', 'r');

    % plot(ZPD4(:,1), ZPD4(:,3), 'linewidth', 1.0, 'color', 'r', 'linestyle', '--');
    % plot(ZPD5(:,1), ZPD5(:,3), 'linewidth', 1.0, 'color', 'g', 'linestyle', '--');
    plot(ZPD6(:,1), ZPD6(:,3), 'linewidth', 1.0, 'color', 'b', 'linestyle', '-');

    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', FONT_NAME)
    set(gca, 'xlim', XLIM)

    f_savefig("./", "DATA_ZPD_HaiDe", {'fig', 'png'}, 300)