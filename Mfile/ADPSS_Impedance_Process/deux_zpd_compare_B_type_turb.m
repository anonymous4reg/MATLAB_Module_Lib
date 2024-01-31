
ZPD1_LEGEND = "不振荡(A+B+C)";
ZPD2_LEGEND = "振荡(A+B+C+B8)";
ZPD3_LEGEND = "振荡(置换全为B)";
ZPD4_LEGEND = "不振荡(置换全为D)";
ZPD5_LEGEND = "单扫D日风";
ZPD6_LEGEND = "单扫B已优化";
ZPD7_LEGEND = "不振荡(置换全为B)-100台";
ZPD8_LEGEND = "振荡(置换全为B)删除无关";
ZPD9_LEGEND = "不振荡(置换全为B)删除无关-台数降2/3";
ZPD10_LEGEND = "修改倍乘模块参数-585台";
ZPD11_LEGEND = "远景5MW-已优化_01_35kV_无倍乘1台";
ZPD12_LEGEND = "远景5MW-已优化_01_35kV_有倍乘1台";

% LEGEND_CELL = {ZPD1_LEGEND, ZPD2_LEGEND, ZPD3_LEGEND, ZPD4_LEGEND, ...
%                ZPD5_LEGEND, ZPD6_LEGEND, ZPD7_LEGEND, ZPD8_LEGEND, ...
%                ZPD9_LEGEND};
LEGEND_CELL = {ZPD3_LEGEND, ...
               ZPD6_LEGEND, ZPD7_LEGEND, ZPD8_LEGEND, ...
               ZPD9_LEGEND, ZPD10_LEGEND, ZPD11_LEGEND, ZPD12_LEGEND};


FONT_NAME = "TimesNewRomanSimSun";
figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    % plot(ZPD1(:,1), 20*log10(ZPD1(:,2)), 'linewidth', 1.0, 'color', 'k');
    hold on
    % plot(ZPD2(:,1), 20*log10(ZPD2(:,2)), 'linewidth', 1.0, 'color', 'r');
    plot(ZPD3(:,1), 20*log10(ZPD3(:,2)), 'linewidth', 1.0, 'color', 'g');
    % plot(ZPD4(:,1), 20*log10(ZPD4(:,2)), 'linewidth', 1.0, 'color', 'b');
    % plot(ZPD5(:,1), 20*log10(ZPD5(:,2)), 'linewidth', 1.0, 'color', 'magenta');
    plot(ZPD6(:,1), 20*log10(ZPD6(:,2)), 'linewidth', 1.0, 'color', 'cyan', 'LineStyle', '--');
    plot(ZPD7(:,1), 20*log10(ZPD7(:,2)), 'linewidth', 1.0, 'color', "#D95319", 'LineStyle', '-.');
    plot(ZPD8(:,1), 20*log10(ZPD8(:,2)), 'linewidth', 1.0, 'color', "#0072BD", 'LineStyle', '-.');
    plot(ZPD9(:,1), 20*log10(ZPD9(:,2)), 'linewidth', 1.0, 'color', "#7E2F8E", 'LineStyle', '-.');
    plot(ZPD10(:,1), 20*log10(ZPD10(:,2)), 'linewidth', 1.0, 'color', 'r', 'LineStyle', '-');
    plot(ZPD11(:,1), 20*log10(ZPD11(:,2)), 'linewidth', 1.0, 'color', 'b', 'LineStyle', '-');
    plot(ZPD12(:,1), 20*log10(ZPD12(:,2)), 'linewidth', 1.0, 'color', 'k', 'LineStyle', '-');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');

    grid on
    legend(LEGEND_CELL, 'interpreter', 'none')
    set(gca, 'fontname', FONT_NAME)
    subplot(2,1,2);
    % plot(ZPD1(:,1),ZPD1(:,3), 'linewidth', 1.0, 'color', 'b');
    hold on
    % plot(ZPD2(:,1), ZPD2(:,3), 'linewidth', 1.0, 'color', 'r');
    plot(ZPD3(:,1), ZPD3(:,3), 'linewidth', 1.0, 'color', 'g');
    % plot(ZPD4(:,1), ZPD4(:,3), 'linewidth', 1.0, 'color', 'b');
    % plot(ZPD5(:,1), ZPD5(:,3), 'linewidth', 1.0, 'color', 'magenta');
    plot(ZPD6(:,1), ZPD6(:,3), 'linewidth', 1.0, 'color', 'cyan', 'LineStyle', '--');
    plot(ZPD7(:,1), ZPD7(:,3), 'linewidth', 1.0, 'color', "#D95319", 'LineStyle', '-.');
    plot(ZPD8(:,1), ZPD8(:,3), 'linewidth', 1.0, 'color', "#0072BD", 'LineStyle', '-.');
    plot(ZPD9(:,1), ZPD9(:,3), 'linewidth', 1.0, 'color', "#7E2F8E", 'LineStyle', '-.');
    plot(ZPD10(:,1), ZPD10(:,3), 'linewidth', 1.0, 'color', 'r', 'LineStyle', '-');
    plot(ZPD11(:,1), ZPD11(:,3), 'linewidth', 1.0, 'color', 'b', 'LineStyle', '-');
    plot(ZPD12(:,1), ZPD12(:,3), 'linewidth', 1.0, 'color', 'k', 'LineStyle', '-');
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', FONT_NAME)

    f_savefig("./", "DATA_ZPD_tmp", {'fig', 'png'}, 300)