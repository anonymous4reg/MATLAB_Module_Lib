clear;clc
RootDir = 'D:\Travail\RE\HIL\[Routine] 阻抗专题\20210224_GW3.0D-PCS09_扫频\PQvary\1-2500Hz\';
PsetArray = 0:0.1:1;
QsetArray = [-1];
% QsetArray = -1:0.1:1;

%% User define zone [end]
PsetCell = num2cell(PsetArray);
QsetCell = num2cell(QsetArray);


%%
figure;
for p_idx = 1:length(PsetCell)
    for q_idx = 1:length(QsetCell)
        clearvars low_and_high
        fcolor = double(p_idx) / double(length(PsetCell));
        p_name = num2str(PsetCell{p_idx}, '%.1f');
        q_name = num2str(QsetCell{q_idx}, '%.1f');
        p_set = PsetArray(p_idx);
        q_set = QsetArray(q_idx);
        % --- 创建文件夹
        case_name = strcat('P', p_name, '-', 'Q', q_name);
        mat_url = strcat(RootDir, '\', case_name, '\', 'DATA_ZP');
        load(mat_url)
        impdata = low_and_high;
        subplot(2,1,1);
        plot(impdata(:,1), 20*log10(impdata(:,2)), 'color', [fcolor, (1-fcolor), 0])
        grid on
        hold on
        set(gca, 'fontname', 'Times new roman', 'xlim', [0, 100])
        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)');

        subplot(2,1,2);
        impdata(:, 3) = phase_to_180(impdata(:, 3));
        plot(impdata(:,1), impdata(:,3), 'color', [fcolor, (1-fcolor), 0])
        grid on
        hold on
        set(gca, 'fontname', 'Times new roman', 'xlim', [0, 100])
        xlabel('Frequency (Hz)');
        ylabel('Phase (Deg)');

    end
end
set(gcf,'unit','centimeters','position',[10,5,18,11])