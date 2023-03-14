%% User could change here
SrcDir = 'D:\Envision3p3\Envision_JJL_3p3_data\11-lvrt-20220826\';  % Your .mat file location
DstDir = SrcDir;  % where your doc will be generated

TimeStampStr = cellstr(datetime('now', 'Format', 'yyyy-MM-dd HH-mm-ss-SSS'));
TimeStampStr = TimeStampStr{1};
WordFileName = strcat('LHVRT-comparison-', TimeStampStr, '.docx');  % your doc name
WordFileUrl = strcat(DstDir, WordFileName); 
WordTitle = 'Ô¶¾°3.3MW';   % title of your report

Field1 = {'VRT'};
Field2 = {'3ph', '2ph'};
Field3 = {'u20', 'u75', 'u120', 'u130'};
Field4 = {'p1.0', 'p0.2'};
SubFolderCell1 = f_sequence_gen_recursive({Field1, Field2, Field3, Field4}, '_');
SubFolderCell = SubFolderCell1{1};


%% Main program here
tic
fun_word_title(WordTitle, 32, WordFileUrl)
for file_idx=1:length(SubFolderCell)
	sub_folder_name = SubFolderCell{file_idx};
    sub_folder_dir = [SrcDir, '\', sub_folder_name];
    fun_word_title(sub_folder_name, 15, WordFileUrl)
    
	disp(strcat('[', num2str(file_idx), '/', num2str(length(SubFolderCell)) , '] - ', ...
        'Working on: ', SubFolderCell{file_idx}))
    
    fig_url = strcat(sub_folder_dir, '\', 'Unified_Plot-Cmp.png');
    fun_word_figure(fig_url, 'Unified_Plot', WordFileUrl)
    
%     fig_url = strcat(sub_folder_dir, '\', 'U+.emf');
%     fun_word_figure(fig_url, 'U+', WordFileUrl)
    
%     fig_url = strcat(sub_folder_dir, '\', 'PQ+.emf');
%     fun_word_figure(fig_url, 'PQ+', WordFileUrl)
%     
%     fig_url = strcat(sub_folder_dir, '\', 'IpIq+.emf');
%     fun_word_figure(fig_url, 'IpIq+', WordFileUrl)
    
%     break

end
toc