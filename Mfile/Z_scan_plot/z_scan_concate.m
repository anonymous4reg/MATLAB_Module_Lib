PsetArray = 0:0.1:1;
QsetArray = -1:0.1:1;

%% User define zone [end]
PsetCell = num2cell(PsetArray);
QsetCell = num2cell(QsetArray);

RootDir = '';

%%
for p_idx = 1:length(PsetCell)
    for q_idx = 1:length(QsetCell)
        p_name = num2str(PsetCell{p_idx}, '%.1f');
        q_name = num2str(QsetCell{q_idx}, '%.1f');
        p_set = PsetArray(p_idx);
        q_set = QsetArray(q_idx);
        % --- 创建文件夹
        case_name = strcat('P', p_name, '-', 'Q', q_name);
        mkdir(strcat(RootDir, '\', case_name, '\')
        break
    break
    end
end
