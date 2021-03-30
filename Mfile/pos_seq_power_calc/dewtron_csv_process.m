%% Reading Dewtron csv file to workspace


%% code start
SrcDir = 'D:\Travail\RE\HIL\20210122_禾望-韩家庄\03-现场高穿数据\csvfile\';
file_list = dir(SrcDir);
file_cell = {file_list(~[file_list.isdir]).name};
var_col_name = {'t', 'ua1', 'ia1', 'ub1', 'ib1', 'uc1', 'ic1', ...
    'ua2', 'ia2', 'ub2', 'ib2', 'uc2', 'ic2'};

for idx = 1:length(file_cell)
    process_info_str = append('Processing ', num2str(idx), '/', num2str(length(file_cell)));
    disp(process_info_str)
    file_name = file_cell{idx};
    file_name_head = strsplit(file_name, '.');
    file_name_head = strjoin({file_name_head{1:end-1}}, '.');  % cut the extended name
    
    file_path = strcat(SrcDir, file_name);
    file_hand = readtable(file_path);
    t = file_hand.Time_s_;
    ua1 = file_hand.Ua__V_;
    ub1 = file_hand.Ub__V_;
    uc1 = file_hand.Uc__V_;
    ia1 = file_hand.Ia_A_;
    ib1 = file_hand.Ib_A_;
    ic1 = file_hand.Ic_A_;
    
    ua2 = file_hand.Ua__V__1;
    ub2 = file_hand.Ub__V__1;
    uc2 = file_hand.Uc__V__1;
    ia2 = file_hand.Ia_A__1;
    ib2 = file_hand.Ib_A__1;
    ic2 = file_hand.Ic_A__1;
    save(strcat(file_name_head, '.mat'), 't', 'ua1', 'ub1', 'uc1', 'ia1', 'ib1', 'ic1', ...
        'ua2', 'ub2', 'uc2', 'ia2', 'ib2', 'ic2'); 
%     break
end